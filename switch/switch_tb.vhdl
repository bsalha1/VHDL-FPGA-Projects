library ieee;
use ieee.std_logic_1164.all;

entity switches_tb is
end switches_tb;

architecture switches_tb_arch of switches_tb is

    component switches
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
    switches_instance: switches port map (
        switch1 => switch1, 
        switch2 => switch2, 
        led1 => led1, 
        led2 => led2
    );

    p_sim: process
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
end switches_tb_arch;