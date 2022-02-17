library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    generic (
        CLKS_PER_BIT : integer :=  105-- 12 MHz / 115200 Hz = 105
    );
    port (
        clk : in std_logic;
        rx : in std_logic;
        rx_byte : out std_logic_vector(7 downto 0)
    );
end uart_rx;

architecture uart_rx_arch of uart_rx is
    type uart_status is (
        IDLE, START_BIT, DATA, STOP_BIT, CLEANUP
    );

    signal status : uart_status := IDLE;

    signal r_rx_data_r : std_logic := '0';
    signal r_rx_data : std_logic := '0';

    signal clk_count : integer range 0 to CLKS_PER_BIT - 1 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal r_rx_byte : std_logic_vector(7 downto 0) := (others => '0');

begin

    p_sample : process(clk) 
    begin 
        if rising_edge(clk) then
            r_rx_data_r <= rx;
            r_rx_data <= r_rx_data_r;
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

                    -- START bit detected (line pulled low)
                    if r_rx_data = '0' then
                        status <= START_BIT;
                    else
                        status <= IDLE;
                    end if;

                    
                -- Start RX
                when START_BIT =>

                    -- Sample middle of START bit 
                    if clk_count = (CLKS_PER_BIT - 1) / 2 then

                        -- If still pulled low, prepare for data
                        if r_rx_data = '0' then
                            clk_count <= 0;
                            status <= DATA;
                        else
                            status <= IDLE;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                        status <= START_BIT;
                    end if;

                -- Data incoming
                when DATA =>
                    
                    -- Wait CLKS_PER_BIT - 1 cycles to sample the data
                    if clk_count < CLKS_PER_BIT - 1 then
                        clk_count <= clk_count + 1;
                        status <= DATA;
                    else
                        clk_count <= 0;
                        r_rx_byte(bit_index) <= r_RX_Data;
                        
                        -- If bits left, increment bit to transfer. Otherwise, this is the STOP bit
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                            status <= DATA;
                        else
                            bit_index <= 0;
                            status <= STOP_BIT;
                        end if;
                    end if;

                -- STOP bit received
                when STOP_BIT =>
                
                    -- Wait CLKS_PER_BIT - 1 cycles to sample the data
                    if clk_count < CLKS_PER_BIT - 1 then
                        clk_count <= clk_count + 1;
                        status <= STOP_BIT;
                    else
                        clk_count <= 0;
                        status <= CLEANUP;
                    end if;

                when CLEANUP =>
                    status <= IDLE;

                when others =>
                    status <= IDLE;

            end case;
        end if;
    end process;
    
    rx_byte <= r_rx_byte;

end uart_rx_arch;