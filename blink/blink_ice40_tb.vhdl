library ieee;
use ieee.std_logic_1164.all;

entity blink_ice40_tb is
end blink_ice40_tb;

architecture blink_ice40_tb_arch of blink_ice40_tb is
    signal clk : std_logic := '0' ;
    signal switch1 : std_logic;
    signal switch2 : std_logic;
    signal led1 : std_logic;
    signal led2 : std_logic;

    component blink_ice40 is 
        port (
            clk : in std_logic;
            switch1 : in std_logic;
            switch2 : in std_logic;
            led1 : out std_logic;
            led2 : out std_logic
        );
    end component;

begin
    
    clk <= not clk after 2 ns;

    blink_ice40_instance: blink_ice40 port map (
        clk => clk,
        switch1 => switch1,
        switch2 => switch2,
        led1 => led1,
        led2 => led2
    );

    process begin


        wait;
    end process;

end blink_ice40_tb_arch;