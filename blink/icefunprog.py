import sys
import serial
import serial.tools.list_ports

class iceFUNprog:
    DONE = 0xB0
    GET_VER = 0xB1
    RESET_FPGA = 0xB2
    ERASE_CHIP = 0xB3
    ERASE_64K = 0xB4
    PROG_PAGE = 0xB5
    READ_PAGE = 0xB6
    VERIFY_PAGE = 0xB7
    GET_CDONE = 0xB8
    RELEASE_FPGA = 0xB9
    FLASHSIZE = 1048576
    ser = serial.Serial()

    def list(self):
        ports = serial.tools.list_ports.comports()
        for port, desc, hwid in sorted(ports):
            print("{}: {} [{}]".format(port, desc, hwid))

    def get_version(self, ser):
        written = ser.write(bytes([self.GET_VER]))
        response = ser.read(2)
        if (len(response) == 0):
            print("No response")
        else:
            if (response[0] == 38):
                print("iceFUN Programmer, V{}".format(response[1]))
            else:
                print("Unknown response")

    def reset(self):
        written = self.ser.write(bytes([self.RESET_FPGA]))
        response = self.ser.read(3)
        if (len(response) == 0):
            print("No response")
        else:
            print("Flash ID {} {} {}".format(hex(response[0]), hex(response[1]), hex(response[2])))

    def release(self):
        written = self.ser.write(bytes([self.RELEASE_FPGA]))
        response = self.ser.read(1)
        if (len(response) == 0):
            print("No response")
        else:
            print("Release response {}".format(hex(response[0])))

    def flash(self, filename):
        try:
            self.reset()
            with open(filename, 'rb') as bstream:
                data = bstream.read()
                print("Program length {}".format(len(data)))
                erasePages = (len(data) >> 16) + 1;
                print("Erase pages {}".format(erasePages))
                for page in range(erasePages):
                    print("Erasing sector {}0000".format(hex(page)))
                    written = self.ser.write(bytes([self.ERASE_64K, page]))
                    response = self.ser.read(1)
                    if (len(response) == 0):
                        print("No response")
                    else:
                        print("Erase sector response {}".format(hex(response[0])))
                addr = 0

                while (addr < len(data)):
                    payload = bytearray([self.PROG_PAGE, 0xFF & (addr >> 16), 0xFF & (addr >> 8), 0xFF & addr])
                    if ((addr + 256) < len(data)):
                        payload.extend(bytes(data[addr:addr + 256]))
                    else:

                        payload.extend(bytes(data[addr:]))
                        # Write transactions take 255 bytes, last block in data might not be so long, will pad with zeros
                        padding = 256 - (len(data) - addr)
                        payload.extend(bytes([0] * padding))
                    written = self.ser.write(bytes(payload))
                    response = self.ser.read(4)
                    if (len(response) == 0):
                        print("No response")
                    else:
                        if (response[0] != 0):
                            print("Write failed")
                        else:
                            print('#', end='')
                    addr += 256
                    # break
                print("\n\rFlash ok")
                self.release()
        except IOError as e:
            errno, strerror = e.args
            print("I/O error({0}): {1}".format(errno, strerror))

    def init(self, portname):
        self.ser.port = portname
        self.ser.baudrate = 19200
        self.ser.parity = serial.PARITY_NONE
        self.ser.stopbits = serial.STOPBITS_TWO
        self.ser.bytesize = serial.EIGHTBITS
        self.ser.timeout = 1
        self.ser.open()

    def close(self):
        self.ser.close()

def main():
    if len(sys.argv) != 3:
        print ("Usage: {} serial_device bitstream_file".format(sys.argv[0]))
        sys.exit(1)

    try:
        prog = iceFUNprog()
        prog.init(sys.argv[1])
        prog.flash(sys.argv[2])
        prog.close()

    except serial.SerialException as e:
        print("Serial error({}): ".format(e.args))

    except:
        print("Unexpected error:", sys.exc_info()[0])

if __name__ == "__main__":
    main()


