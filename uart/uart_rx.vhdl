library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    generic (
        CLKS_PER_BIT : integer :=  105 -- 12 MHz / 115200 Hz = 105
    );
    port (
        clk : in std_logic;
        rx : in std_logic;
        rx_byte : out std_logic_vector(7 downto 0);
        is_packet_rxed : out std_logic
    );
end uart_rx;

architecture uart_rx_arch of uart_rx is
    type uart_status is (
        IDLE, START_BIT, DATA, STOP_BIT
    );

    signal status : uart_status := IDLE;

    signal rx_data_ff1 : std_logic := '0';
    signal rx_data_ff2 : std_logic := '0'; -- Double flops "rx" from low freq UART domain to high freq FPGA domain

    signal clk_count : integer range 0 to CLKS_PER_BIT - 1 := 0; -- The current progress of the bit being RX'd
    signal bit_index : integer range 0 to 7 := 0;

begin

    -- Since UART data is slower than clk, double flop the slow data (rx) to increase resolution time
    p_sample : process(clk) 
    begin 
        if rising_edge(clk) then
            rx_data_ff1 <= rx;
            rx_data_ff2 <= rx_data_ff1;
        end if;
    end process;

    p_uart_rx : process (clk)
    begin
        if rising_edge(clk) then
            
            case status is

                -- Idle, look for START bit
                when IDLE =>
                    clk_count <= 0;
                    bit_index <= 0;
                    is_packet_rxed <= '0';

                    -- START bit detected (line pulled low)
                    if rx_data_ff2 = '0' then
                        status <= START_BIT;
                    end if;

                    
                -- Start RX
                when START_BIT =>

                    -- Sample middle of START bit 
                    if clk_count = (CLKS_PER_BIT - 1) / 2 then

                        -- If still pulled low, prepare for data
                        if rx_data_ff2 = '0' then
                            clk_count <= 0;
                            status <= DATA;
                        else
                            status <= IDLE;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                -- Data incoming
                when DATA =>
                    
                    -- Wait CLKS_PER_BIT - 1 cycles to get to next RX'd bit
                    if clk_count < CLKS_PER_BIT - 1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        rx_byte(bit_index) <= rx_data_ff2;
                        
                        -- If bits left, increment bit to transfer. Otherwise, this is the STOP bit
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            status <= STOP_BIT;
                        end if;
                    end if;

                -- STOP bit received
                when STOP_BIT =>
                
                    -- Wait CLKS_PER_BIT cycles to get to next RX'd bit
                    if clk_count < CLKS_PER_BIT - 1 then
                        clk_count <= clk_count + 1;
                    else
                        is_packet_rxed <= '1';
                        clk_count <= 0;
                        status <= IDLE;
                    end if;

                when others =>
                    status <= IDLE;

            end case;
        end if;
    end process;

end uart_rx_arch;