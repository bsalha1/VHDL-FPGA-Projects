library ieee;
use ieee.std_logic_1164.all;

entity switches is 
    port (
        switch1 : in std_logic;
        switch2 : in std_logic;
        led1 : out std_logic;
        led2 : out std_logic
    );
end switches;

architecture switches_arch of switches is
begin
    led1 <= switch1;
    led2 <= switch2;
end switches_arch;