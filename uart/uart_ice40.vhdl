library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity uart_ice40 is
    port(
        clk : in std_logic;
        uart1_tx : out std_logic;
        uart1_rx : in std_logic;
        gpio : out std_logic_vector(7 downto 0);
        seven_seg_leds : out std_logic_vector(7 downto 0);
        seven_seg_sel : out std_logic_vector(1 downto 0)
    );
end uart_ice40;

architecture uart_ice40_arch of uart_ice40 is

    signal reset : std_logic := '1';
    signal uart_rx_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_tx_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal number : unsigned(15 downto 0) := (others => '0');
    signal seven_seg_clk : std_logic;
    signal seven_seg_clk_divisor : natural := 25000;
    signal is_packet_rxed : std_logic;
    signal request_tx : std_logic := '0';
    signal tx_done : std_logic;

    component uart_rx is 
        port(
            clk : in std_logic;
            reset : in std_logic;
            rx_in : in std_logic;
            rx_byte_out : out std_logic_vector(7 downto 0);
            is_packet_rxed : out std_logic
        );
    end component;

    component uart_tx is 
        port(
            clk : in std_logic;
            tx : out std_logic;
            tx_byte : in std_logic_vector(7 downto 0);
            tx_done : out std_logic;
            request_tx : in std_logic
        );
    end component;

    component seven_seg is
        port(
            clk : in std_logic;
            number : in unsigned(15 downto 0);
            seven_seg_sel : out std_logic_vector(1 downto 0);
            seven_seg_leds : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component clock_divider is 
    port (
        clk : in std_logic;
        clk_divided : out std_logic;
        divisor : in natural
    );
    end component;

begin
    
    -- UART RX
    uart_rx_instance : uart_rx port map (
        clk => clk,
        reset => reset,
        rx_in => uart1_rx,
        rx_byte_out => uart_rx_byte,
        is_packet_rxed => is_packet_rxed
    );

    -- UART TX
    uart_tx_instance : uart_tx port map (
        clk => clk,
        tx => uart1_tx,
        tx_byte => uart_tx_byte,
        tx_done => tx_done,
        request_tx => request_tx
    );

    -- 240 Hz clock for seven-segment display
    clock_divider_instance : clock_divider port map(
        clk => clk,
        clk_divided => seven_seg_clk,
        divisor => seven_seg_clk_divisor
    );

    -- Seven-segment display driver 
    seven_seg_instance : seven_seg port map (
        clk => seven_seg_clk,
        number => number,
        seven_seg_sel => seven_seg_sel,
        seven_seg_leds => seven_seg_leds
    );

    p_reset: process(clk)
    begin
        if rising_edge(clk) then
            reset <= '0';
        end if;
    end process;

    p_uart_echo : process (is_packet_rxed)
    begin
        if is_packet_rxed = '1' then
            uart_tx_byte <= uart_rx_byte;
            request_tx <= '1';
        else
            uart_tx_byte <= (others => '0');
            request_tx <= '0';
        end if;
    end process;
    
    -- Output RX'ed packet byte to seven-seg display
    number <= unsigned(resize(unsigned(uart_rx_byte), 16));
    
end uart_ice40_arch;
