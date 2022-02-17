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

    signal uart_rx_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_rx_dv : std_logic := '0';
    signal number : unsigned(15 downto 0) := (others => '0');
    signal seven_seg_clk : std_logic;

    component uart_rx is 
        port(
            clk : in std_logic;
            rx : in std_logic;
            rx_dv : out std_logic;
            rx_byte : out std_logic_vector(7 downto 0)
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
        clk_divided : out std_logic
    );
    end component;

begin
    
    clock_divider_instance : clock_divider port map(
        clk => clk,
        clk_divided => seven_seg_clk
    );

    uart_instance : uart_rx port map (
        clk => clk,
        rx => uart1_rx,
        rx_byte => uart_rx_byte,
        rx_dv => uart_rx_dv
    );

    seven_seg_instance : seven_seg port map (
        clk => seven_seg_clk,
        number => number,
        seven_seg_sel => seven_seg_sel,
        seven_seg_leds => seven_seg_leds
    );

    gpio <= uart_rx_byte;

    number <= unsigned(resize(unsigned(uart_rx_byte), 16));
    
end uart_ice40_arch;
