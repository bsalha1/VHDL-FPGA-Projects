library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Implementing the ARMv8-A Architecture

entity control_unit is
    generic (
        -- ALU Operations
        ALU_ADD : std_logic_vector(2 downto 0) := "000";
        ALU_SUB : std_logic_vector(2 downto 0) := "001";
        ALU_AND : std_logic_vector(2 downto 0) := "010";
        ALU_OR  : std_logic_vector(2 downto 0) := "011";
        ALU_XOR : std_logic_vector(2 downto 0) := "100";
        ALU_NOT : std_logic_vector(2 downto 0) := "101";

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
    type control_unit_state is (FETCH, DECODE, EXECUTE);
    
    signal state : control_unit_state := FETCH;

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

    -- ALU Ports
    signal alu_arg0 : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_arg1 : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_op : std_logic_vector(2 downto 0) := (others => '0');
    signal alu_en : std_logic := '0';
    signal alu_result : std_logic_vector(31 downto 0);
    signal alu_done : std_logic;

    signal cu_done : std_logic := '0'; -- Control Unit can do some operations, this indicates if those are done
    signal instruction_done : std_logic; -- If either control unit is done or alu is done

    function zero_extend_8_to_32(
        imm8 : std_logic_vector(7 downto 0)
    ) return std_logic_vector is
    begin
        return x"000000" & imm8;
    end function;

    function zero_extend_3_to_32(
        imm3 : std_logic_vector(2 downto 0)
    ) return std_logic_vector is
    begin
        return "00000000000000000000000000000" & imm3;
    end function;


    component alu is
    port(
        arg0 : in std_logic_vector(31 downto 0);
        arg1 : in std_logic_vector(31 downto 0);
        op : in std_logic_vector(2 downto 0);
        en : in std_logic;
        result : out std_logic_vector(31 downto 0);
        done : out std_logic
    );
    end component;

begin

    instruction_done <= alu_done or cu_done;

    alu_instance: alu port map(
        arg0 => alu_arg0,
        arg1 => alu_arg1,
        op => alu_op,
        en => alu_en,
        result => alu_result,
        done => alu_done
    );

    -- Control: fetch, decode and then execute the instruction
    p_control: process(clk, reset)
        variable dest_reg_num : integer := 0;
    begin
        if rising_edge(clk) then

            case(state) is

                -- FETCH: write out to address bus, instruction will arrive in instruction register
                when FETCH =>
                    alu_en <= '0';
                    cu_done <= '0';
                    address_bus_out <= pc_reg;
                    state <= DECODE;
            
                -- DECODE: decode the instruction to figure out the operations to do 
                when DECODE => 

                    state <= EXECUTE;

                    -- Arithmetic Instruction
                    if instruction(15 downto 14) = "00" then
                        
                        -- LSL_IMM
                        if instruction(13 downto 11) = "000" then

                        -- LSR_IMM
                        elsif instruction(13 downto 11) = "001" then
                
                        -- ASR_IMM
                        elsif instruction(13 downto 11) = "010" then
                
                        -- ADD_REG
                        elsif instruction(13 downto 9) = "01100" then
                
                        -- SUB_REG
                        elsif instruction(13 downto 9) = "01101" then
                
                        -- ADD_IMM3
                        -- imm3[8:6] Rn[5:3] Rd[2:0]
                        elsif instruction(13 downto 9) = "01110" then
                            alu_op <= ALU_ADD;
                            alu_arg0 <= gp_reg(to_integer(unsigned(instruction(5 downto 3))));
                            alu_arg1 <= zero_extend_3_to_32(instruction(8 downto 6));
                            dest_reg_num := to_integer(unsigned(instruction(2 downto 0)));
                            alu_en <= '1';
                            
                        -- SUB_IMM3
                        elsif instruction(13 downto 9) = "01111" then
                
                        -- MOV_IMM
                        -- Rd[10:8] imm8[7:0] : Rd = imm8 
                        elsif instruction(13 downto 11) = "100" then
                            gp_reg(to_integer(unsigned(instruction(10 downto 8)))) <= zero_extend_8_to_32(instruction(7 downto 0));
                            cu_done <= '1';
                
                        -- CMP_IMM
                        elsif instruction(13 downto 11) = "101" then
                
                        -- ADD_IMM8
                        -- Rdn[10:8] imm8[7:0]
                        elsif instruction(13 downto 11) = "110" then
                            
                        -- SUB_IMM8
                        elsif instruction(13 downto 11) = "111" then
                        
                        -- Unknown Instruction
                        else
                            
                        end if;
                        
                    end if;

                -- EXECUTE: wait for instruction to be done executing. Once done, increment program counter and fetch next instruction
                when EXECUTE =>

                    if instruction_done then
                        state <= FETCH;
                        pc_reg <= std_logic_vector(unsigned(pc_reg) + 1);

                        -- If ALU was invoked for an instruction, assign the destination register the result
                        if alu_done then
                            gp_reg(dest_reg_num) <= alu_result;
                        end if;
                    end if;
                        
            end case;
        end if;

    end process;
end control_unit_arch;