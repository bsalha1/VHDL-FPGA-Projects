library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is 
    generic(
        REGISTER_SIZE : natural := 32    -- Size of register in bits
    );
    port(
        arg0 : in std_logic_vector(31 downto 0);
        arg1 : in std_logic_vector(31 downto 0);
        op : in std_logic_vector(2 downto 0);
        en : in std_logic;
        result : out std_logic_vector(31 downto 0);
        done : out std_logic
    );
end alu;

architecture alue_arch of alu is

    -- ALU Opcodes
    constant ALU_ADD : std_logic_vector(2 downto 0) := "000";
    constant ALU_SUB : std_logic_vector(2 downto 0) := "001";
    constant ALU_AND : std_logic_vector(2 downto 0) := "010";
    constant ALU_OR  : std_logic_vector(2 downto 0) := "011";
    constant ALU_XOR : std_logic_vector(2 downto 0) := "100";
    constant ALU_NOT : std_logic_vector(2 downto 0) := "101";

begin
    
    -- Operate: perform arithmetic/logical operations on the arguments to produce the result
    p_operate: process(en, op, arg0, arg1) is
    begin

        if en = '1' then
            case(op) is
                when ALU_ADD =>
                    result <= std_logic_vector(unsigned(arg0) + unsigned(arg1));
                    done <= '1';

                when ALU_SUB =>
                    result <= std_logic_vector(unsigned(arg0) - unsigned(arg1));
                    done <= '1';

                when ALU_AND =>
                    result <= arg0 and arg1;
                    done <= '1';

                when ALU_OR =>
                    result <= arg0 or arg1;
                    done <= '1';

                when ALU_XOR =>
                    result <= arg0 xor arg1;
                    done <= '1';

                when ALU_NOT =>
                    result <= not arg0;
                    done <= '1';

                when others =>
            end case;
        else
            result <= (others => '0');
            done <= '0';
        end if;
    end process;

end alue_arch ; -- alue_arch