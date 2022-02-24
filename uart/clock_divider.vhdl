library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity clock_divider is
    port (
        clk : in std_logic;
        divisor : in natural;
        clk_divided : out std_logic
    );
end clock_divider;

architecture clock_divider_arch of clock_divider is
    signal counter : integer := 1;
    signal toggle : std_logic := '0';

begin

    clk_divided <= toggle;

    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;

            if counter = divisor then
                toggle <= not toggle;
                counter <= 1;
            end if;
        end if;
    end process;

end clock_divider_arch;