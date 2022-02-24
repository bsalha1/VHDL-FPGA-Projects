library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    generic(
        CLK_FREQ : natural := 12000000;
        BAUD_RATE : natural := 112500;
        RESOLUTION : integer := 8; -- Oversample count i.e. x8, x16, ...
        TX_SIZE : integer := 8;
        BAUD_OVERSAMPLER_TICKS : natural := 12000000 / 112500 / 8 -- = CLK_FREQ / BAUD_RATE / RESOLUTION
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        rx_in : in std_logic;
        rx_byte_out : out std_logic_vector(TX_SIZE - 1 downto 0);
        is_packet_rxed : out std_logic
    );
end uart_rx;

architecture uart_rx_arch of uart_rx is
    type uart_state is (IDLE, START_BIT, DATA, STOP_BIT);
    signal state : uart_state := IDLE;

    signal oversampler_clk : std_logic := '0';

    signal rx_byte : std_logic_vector(TX_SIZE - 1 downto 0) := (others => '0');

    component clock_divider is
        port (
            clk : in std_logic;
            divisor : in natural;
            clk_divided : out std_logic
        );
    end component;
    
begin

    -- Generates baud generator (sampler) clock
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

    -- Poll RX line for START bit and then move along state machine
    p_uart_rx : process (clk)
        variable oversampler_count : integer range 0 to RESOLUTION - 1 := 0;
        variable bit_index : integer range 0 to TX_SIZE - 1  := 0;
    begin
        if rising_edge(clk) then
            
            if reset = '1' then
                state <= IDLE;
                rx_byte <= (others => '0');
                rx_byte_out <= (others => '0');
                oversampler_count := 0;
                bit_index := 0;

            elsif oversampler_clk = '1' then
                case state is

                    -- IDLE: Look for START bit
                    when IDLE =>
                        rx_byte <= (others => '0');
                        oversampler_count := 0;
                        bit_index := 0;
                        is_packet_rxed <= '0';

                        -- START bit detected
                        if rx_in = '0' then
                            state <= START_BIT;
                        end if;

                        
                    -- START_BIT: Wait for middle of start bit
                    when START_BIT =>

                        -- Make sure we are still in START bit
                        if rx_in = '0' then

                            -- Get to middle of START bit so middle of each subsequent bit can be sampled in the
                            if oversampler_count = (RESOLUTION - 1) / 2 then
                                state <= DATA;
                                oversampler_count := 0;
                            else
                                oversampler_count := oversampler_count + 1;
                            end if;
                        else
                            state <= IDLE;
                        end if;


                    -- DATA: Sample middle of each data bit until no data left
                    when DATA =>
                        
                        -- Wait till we are in the middle of the next DATA bit and then latch RX line to rx_byte(bit_index)
                        if oversampler_count = RESOLUTION - 1 then
                            
                            rx_byte(bit_index) <= rx_in;
                            oversampler_count := 0;
                            
                            -- If all data bytes have been read, enter STOP_BIT stage
                            if bit_index = TX_SIZE - 1 then
                                state <= STOP_BIT;
                                bit_index := 0;
                            else
                                bit_index := bit_index + 1;
                            end if;
                        else
                            oversampler_count := oversampler_count + 1;
                        end if;


                    -- STOP_BIT: wait for stop bit to be done and then latch RX'ed data to output
                    when STOP_BIT =>
                    
                        if oversampler_count = RESOLUTION - 1 then
                            rx_byte_out <= rx_byte;
                            state <= IDLE;
                            is_packet_rxed <= '1';
                        else
                            oversampler_count := oversampler_count + 1;
                        end if;


                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end uart_rx_arch;