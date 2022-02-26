library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    generic (
        MOV_IMM : std_logic_vector(2 downto 0) := "100";
        REGISTER_SIZE : natural := 32;    -- Size of register in bits
        ADDRESS_SIZE : natural := 32;     -- Size of address
        INSTRUCTION_SIZE : natural := 16 -- Size of instruction in bits
    );
    port(
        clk : in std_logic;
        reset : in std_logic;
        instruction : in std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
        address_bus_out : out std_logic_vector(ADDRESS_SIZE - 1 downto 0)
    );
end control_unit;

architecture control_unit_arch of control_unit is

    type array_of_regs is array (0 to 12) of std_logic_vector(REGISTER_SIZE - 1 downto 0); 

    -- Flag Block
    signal n_flag : std_logic := '0';
    signal z_flag : std_logic := '0';
    signal c_flag : std_logic := '0';
    signal v_flag : std_logic := '0';

    -- Register Block
    signal sp_reg : std_logic_vector(REGISTER_SIZE - 1 downto 0) := (others => '0'); -- Stack Pointer Register
    signal lr_reg : std_logic_vector(REGISTER_SIZE - 1 downto 0) := (others => '0'); -- Link Register
    signal pc_reg : std_logic_vector(REGISTER_SIZE - 1 downto 0) := (others => '0'); -- Program Counter Register
    signal ir_reg : std_logic_vector(INSTRUCTION_SIZE - 1 downto 0); -- Instruction Register
    signal gp_reg : array_of_regs := (others => (others => '0')); -- General Purpose Registers

begin

    address_bus_out <= pc_reg;

    p_decode: process(clk, reset)
        variable dest_reg_num : std_logic_vector(2 downto 0) := (others => '0');
        variable imm8 : std_logic_vector(7 downto 0) := (others => '0');
        -- variable last_pc : std_logic_vector(REGISTER_SIZE - 1 downto 0) := (others => '0');
    
    begin
        if rising_edge(clk) then

            -- Arithmetic Instruction
            if instruction(INSTRUCTION_SIZE - 1 downto INSTRUCTION_SIZE - 2) = "00" then

                report "Yeah we hit dat goo";
                -- Rd[10:8] imm8[7:0] : Rd = imm8 
                if instruction(INSTRUCTION_SIZE - 3 downto INSTRUCTION_SIZE - 5) = MOV_IMM then
                    gp_reg(to_integer(unsigned(instruction(10 downto 8)))) <= x"000000" & instruction(7 downto 0);
                end if;

            -- Logic Instruction
            -- elsif instruction(INSTRUCTION_SIZE - 1 downto INSTRUCTION_SIZE - 6) = "010000" then

            -- Special Instruction
            -- elsif instruction(INSTRUCTION_SIZE - 1 downto INSTRUCTION_SIZE - 6) = "010001" then

            -- Branch Instruction
            -- elsif instruction(INSTRUCTION_SIZE - 1 downto INSTRUCTION_SIZE - 4) = "1101" then

            -- Unconditional Branch Instruction
            -- elsif instruction(INSTRUCTION_SIZE - 1 downto INSTRUCTION_SIZE - 5) = "11100" then
            else
                
                report "Yeah we hit dat";
            end if;
            pc_reg <= std_logic_vector(unsigned(pc_reg) + 1);
        end if;

    end process;
end control_unit_arch;