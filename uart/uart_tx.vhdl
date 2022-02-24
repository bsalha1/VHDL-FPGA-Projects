library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    generic (
        CLK_FREQ : natural := 12000000;
        BAUD_RATE : natural := 112500;
        RESOLUTION : integer := 8; -- Oversample count i.e. x8, x16, ...
        TX_SIZE : integer := 8;
        BAUD_OVERSAMPLER_TICKS : natural := 12000000 / 112500 / 8 -- = CLK_FREQ / BAUD_RATE / RESOLUTION
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        tx_out : out std_logic;
        tx_byte_in : in std_logic_vector(7 downto 0);
        tx_done : out std_logic;
        request_tx : in std_logic
    );
end uart_tx;

architecture uart_tx_arch of uart_tx is
    type uart_status is (IDLE, START_BIT, DATA, STOP_BIT);
    signal state : uart_status := IDLE;

    signal oversampler_clk : std_logic := '0';

    signal tx_byte : std_logic_vector(TX_SIZE - 1 downto 0) := (others => '0');

begin

    -- Generates baud sampler clock
    p_oversampler_clk_generator: process(clk)
        variable oversampler_count: integer range 0 to (BAUD_OVERSAMPLER_TICKS - 1) := (BAUD_OVERSAMPLER_TICKS - 1);
    begin
        if rising_edge(clk) then

            if reset = '1' then
                oversampler_clk <= '0';
                oversampler_count := (BAUD_OVERSAMPLER_TICKS - 1);
            elsif oversampler_count = 0 then
                oversampler_clk <= '1';
                oversampler_count := (BAUD_OVERSAMPLER_TICKS - 1);
            else
                oversampler_clk <= '0';
                oversampler_count := oversampler_count - 1;
            end if;
        end if;
    end process p_oversampler_clk_generator;

    -- Poll request_tx line for high and then move along state machine to transmit the byte
    p_uart_tx : process(clk)
        variable oversampler_count : integer range 0 to RESOLUTION - 1 := 0;
        variable bit_index : integer range 0 to TX_SIZE - 1  := 0;
    begin
        if rising_edge(clk) then

            if reset = '1' then
                state <= IDLE;
            elsif oversampler_clk = '1' then
                case state is

                    -- Hold line high until TX requested, then send START_BIT
                    when IDLE =>
                        tx_out <= '1';
                        bit_index := 0;
                        oversampler_count := 0;
                        tx_done <= '0';
                    
                        -- Data transmission requested
                        if request_tx = '1' then
                            tx_byte <= tx_byte_in;
                            state <= START_BIT;
                        end if;
                    
                    -- START_BIT: Pull line low and then send data
                    when START_BIT =>
                        tx_out <= '0';

                        if oversampler_count = RESOLUTION - 1 then
                            oversampler_count := 0;
                            state <= DATA;
                        else
                            oversampler_count := oversampler_count + 1;
                        end if;
                    
                    -- DATA: Transmit current bit until nothing left
                    when DATA =>
                        
                        tx_out <= tx_byte(bit_index);

                        -- Wait for CLKS_PER_BIT cycles until sending the next data
                        if oversampler_count = RESOLUTION - 1 then
                            oversampler_count := 0;

                            -- Send data until end of byte
                            if bit_index < 7 then
                                bit_index := bit_index + 1;
                            else
                                bit_index := 0;
                                state <= STOP_BIT;
                            end if;
                        else
                            oversampler_count := oversampler_count + 1;
                        end if;
                    
                    -- STOP_BIT: Pull line high and update tx_done flag to 1
                    when STOP_BIT =>

                        tx_out <= '1';
                        if oversampler_count = RESOLUTION - 1 then 
                            tx_done <= '1';
                            state <= IDLE;
                        else
                            oversampler_count := oversampler_count + 1;
                        end if;
                    
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end uart_tx_arch;