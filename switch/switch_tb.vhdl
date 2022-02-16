library ieee;
use ieee.std_logic_1164.all;

entity Switches_LEDS_tb is
end Switches_LEDS_tb;

architecture Behavior of Switches_LEDS_tb is

    component Switches_LEDS
    port(
        switch1 : in std_logic;
        switch2 : in std_logic;
        led1 : out std_logic;
        led2 : out std_logic
    );
    end component;

    -- Inputs
    signal switch1 : std_logic := '0';
    signal switch2 : std_logic := '0';

    -- Outputs
    signal led1 : std_logic;
    signal led2 : std_logic;

begin
    test_instance: Switches_LEDS port map (
        switch1 => switch1, 
        switch2 => switch2, 
        led1 => led1, 
        led2 => led2
    );

    stim_proc: process
    begin
        wait for 100 ns;

        -- Initialize inputs
        switch1 <= '0';
        switch2 <= '0';
        wait for 10 ns;

        switch1 <= '1';
        switch2 <= '0';
        wait for 10 ns;

        switch1 <= '0';
        switch2 <= '1';
        wait for 10 ns;

        switch1 <= '1';
        switch2 <= '1';
        wait for 10 ns;

        wait;
    end process;
end Behavior;