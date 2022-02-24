library ieee;
use ieee.std_logic_1164.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture uart_rx_tb_arch of uart_rx_tb is

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal uart1_rx : std_logic := '1';
    signal uart_rx_byte : std_logic_vector(7 downto 0);
    signal is_packet_rxed : std_logic;

    component uart_rx is 
        port(
            clk : in std_logic;
            reset : in std_logic;
            rx_in : in std_logic;
            rx_byte_out : out std_logic_vector(7 downto 0);
            is_packet_rxed : out std_logic
        );
    end component;


begin

    -- UART RX
    uart_rx_instance: uart_rx port map (
        clk => clk,
        reset => reset,
        rx_in => uart1_rx,
        rx_byte_out => uart_rx_byte,
        is_packet_rxed => is_packet_rxed
    );

    
    clk <= not clk after 41.67 ns; -- 12 MHz

    p_reset: process(clk)
    begin
        if rising_edge(clk) then
            reset <= '0';
        end if;
    end process;

    p_sim: process
    begin
        wait for 100 us;
        uart1_rx <= '0'; -- START

        wait for 8.68 us; -- 115200 bps
        uart1_rx <= '1'; -- DATA(0)
        wait for 8.68 us;
        uart1_rx <= '0'; -- DATA(1)
        wait for 8.68 us;
        uart1_rx <= '1'; -- DATA(2)
        wait for 8.68 us;
        uart1_rx <= '0'; -- DATA(3)
        wait for 8.68 us;
        uart1_rx <= '1'; -- DATA(4)
        wait for 8.68 us;
        uart1_rx <= '0'; -- DATA(5)
        wait for 8.68 us;
        uart1_rx <= '1'; -- DATA(6)
        wait for 8.68 us;
        uart1_rx <= '0'; -- DATA(7)

        wait for 8.68 us;
        uart1_rx <= '1'; -- STOP

        wait;
    end process;
    
end uart_rx_tb_arch;