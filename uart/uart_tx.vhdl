library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    generic (
        CLKS_PER_BIT : integer :=  105 -- 12 MHz / 115200 Hz = 105
    );
    port (
        clk : in std_logic;
        tx : out std_logic;
        tx_byte : in std_logic_vector(7 downto 0);
        tx_done : out std_logic;
        request_tx : in std_logic
    );
end uart_tx;

architecture uart_tx_arch of uart_tx is
    type uart_status is (
        IDLE, START_BIT, DATA, STOP_BIT
    );

    signal status : uart_status := IDLE;

    signal clk_count : integer range 0 to CLKS_PER_BIT;
    signal bit_index : integer range 0 to 7 := 0;
    signal tx_data : std_logic_vector(7 downto 0) := (others => '0');

begin

    p_uart_tx : process(clk)
    begin
        if rising_edge(clk) then
            case status is

                -- Hold line high until TX requested, then send START_BIT
                when IDLE =>
                    tx <= '1';
                    bit_index <= 0;
                    clk_count <= 0;
                    tx_done <= '0';
                
                if request_tx = '1' then
                    tx_data <= tx_byte;
                    status <= START_BIT;
                end if;
                
                -- Pull line low until CLKS_PER_BIT cycles and then send data
                when START_BIT =>
                    tx <= '0';

                    if clk_count < CLKS_PER_BIT - 1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;
                        status <= DATA;
                    end if;
                
                -- Transmit current bit
                when DATA =>
                    
                    tx <= tx_data(bit_index);

                    -- Wait for CLKS_PER_BIT cycles until sending the next data
                    if clk_count < CLKS_PER_BIT - 1 then
                        clk_count <= clk_count + 1;
                    else
                        clk_count <= 0;

                        -- Send data until end of byte
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                        else
                            bit_index <= 0;
                            status <= STOP_BIT;
                        end if;
                    end if;
                
                -- Pull line high and update tx_done flip-flop to 1
                when STOP_BIT =>
                    tx <= '1';

                    if clk_count < CLKS_PER_BIT - 1 then 
                        clk_count <= clk_count + 1;
                    else
                        tx_done <= '1';
                        status <= IDLE;
                    end if;
                
                when others =>
                    status <= IDLE;
            end case;
        end if;
    end process;

end uart_tx_arch;