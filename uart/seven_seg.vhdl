library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity seven_seg is
    port(
        clk : in std_logic;
        number : in unsigned(15 downto 0); -- Max 0xFFFF
        seven_seg_sel : out std_logic_vector(1 downto 0);
        seven_seg_leds : out std_logic_vector(7 downto 0)
    );
end seven_seg;

architecture seven_seg_arch of seven_seg is
    signal digit0 : unsigned(3 downto 0);
    signal digit1 : unsigned(3 downto 0);
    signal digit2 : unsigned(3 downto 0);
    signal digit3 : unsigned(3 downto 0);
    signal current_digit : unsigned(3 downto 0) := (others => '0');
    signal digit_index : unsigned(1 downto 0) := (others => '0');

begin
    
    digit0 <= number(3 downto 0);
    digit1 <= number(7 downto 4);
    digit2 <= number(11 downto 8);
    digit3 <= number(15 downto 12);
    seven_seg_sel <= std_logic_vector(digit_index);

    p_inc_digit_index : process(clk)
    begin
        if rising_edge(clk) then
            if digit_index = "11" then
                digit_index <= "00";
            else 
                digit_index <= digit_index + 1;
            end if;
        end if;
    end process;

    p_select_digit : process(digit_index)
    begin
        case digit_index is
            when "00" => current_digit <= digit0;
            when "01" => current_digit <= digit1;
            when "10" => current_digit <= digit2;
            when "11" => current_digit <= digit3;
            when others => current_digit <= digit0;
        end case;
    end process;

    p_display_digit : process(current_digit)
    begin
        case current_digit is
            when "0000" => seven_seg_leds <= "00000011";
            when "0001" => seven_seg_leds <= "10011111";
            when "0010" => seven_seg_leds <= "00100101";
            when "0011" => seven_seg_leds <= "00001101";
            when "0100" => seven_seg_leds <= "10011001";
            when "0101" => seven_seg_leds <= "01001001";
            when "0110" => seven_seg_leds <= "01000001";
            when "0111" => seven_seg_leds <= "00011111";
            when "1000" => seven_seg_leds <= "00000001";
            when "1001" => seven_seg_leds <= "00011001";
            when "1010" => seven_seg_leds <= "00010001";
            when "1011" => seven_seg_leds <= "11000001";
            when "1100" => seven_seg_leds <= "01100011";
            when "1101" => seven_seg_leds <= "10000101";
            when "1110" => seven_seg_leds <= "01100001";
            when "1111" => seven_seg_leds <= "01110001";
            when others => seven_seg_leds <= "11111111";
        end case;
    end process;

end seven_seg_arch;