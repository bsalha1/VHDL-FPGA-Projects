library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity clock_divider is 
    generic (
        DIVISOR : integer := 25000
    );
    port (
        clk : in std_logic;
        clk_divided : out std_logic
    );
end clock_divider;

architecture clock_divider_arch of clock_divider is
    signal counter : std_logic_vector(31 downto 0) := (others => '0');
    signal toggle : std_logic := '0';

begin

    clk_divided <= toggle;

    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + '1';

            -- If counter reaches 25000 then flip the divided clock (12MHz -> 240Hz)
            if counter = DIVISOR then
                toggle <= not toggle;
                counter <= (others => '0');
            end if;
        end if;
    end process;

end clock_divider_arch;