library ieee;
use ieee.std_logic_1164.all;

entity blink_ice40 is
    port(
        clk : in std_logic;
        switch1 : in std_logic;
        switch2 : in std_logic;
        led1 : out std_logic;
        led2 : out std_logic
    );
end blink_ice40;

architecture blink_ice40_arch of blink_ice40 is
    signal slow_clk : std_logic := '0';
    signal toggle : std_logic := '0';

    component clock_divider is 
        port (
            clk : in std_logic;
            clk_divided : out std_logic
        );
    end component;

begin
    

    clock_divider_instance: clock_divider port map (
        clk => clk,
        clk_divided => slow_clk
    );

    -- Clock's first cycle is at LOW, so to initialize properly, start blinking on the falling edge
    process(slow_clk)
    begin
        if falling_edge(slow_clk) then
            toggle <= not toggle;
        end if;
    end process;

    led1 <= toggle; 

end blink_ice40_arch;