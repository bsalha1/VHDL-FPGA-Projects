library ieee;
use ieee.std_logic_1164.all;

entity processor_tb is
    generic(
        ADDRESS_SIZE : natural := 32;     -- Size of address in bits
        INSTRUCTION_SIZE : natural := 16 -- Size of instruction in bits
    );
end processor_tb;

architecture processor_tb_arch of processor_tb is

    signal address_bus : std_logic_vector(ADDRESS_SIZE - 1 downto 0);
    signal data_bus : std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';

    component processor is
        port(
            clk : in std_logic;
            reset : in std_logic;
            address_bus_out : out std_logic_vector(ADDRESS_SIZE - 1 downto 0);
            data_bus_in : in std_logic_vector(INSTRUCTION_SIZE - 1 downto 0)
        );
    end component;
    
    component instruction_rom is
        port(
            clk : in std_logic;
            rom_addr_in : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
            instruction_out : out std_logic_vector(INSTRUCTION_SIZE - 1 downto 0)
        );
    end component;

begin
    
    clk <= not clk after 42 ns; -- 12 MHz

    -- Processor: outputs instruction address to address bus and executes instruction on data bus
    processor_instance: processor port map (
        clk => clk,
        reset => reset,
        address_bus_out => address_bus,
        data_bus_in => data_bus
    );

    -- Instruction ROM: set input address as PC and tie instruction to IR
    instruction_rom_instance: instruction_rom port map (
        clk => clk,
        rom_addr_in => address_bus,
        instruction_out => data_bus
    );

    -- Turn off reset on first rising edge of clock
    p_reset: process(clk)
    begin
        if rising_edge(clk) then
            reset <= '0';
        end if;
    end process;

end processor_tb_arch;