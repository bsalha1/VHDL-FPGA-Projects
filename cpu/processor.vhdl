library ieee;
use ieee.std_logic_1164.all;

entity processor is
    generic(
        REGISTER_SIZE : natural := 32;    -- Size of register in bits
        ADDRESS_SIZE : natural := 32;     -- Size of address in bits
        INSTRUCTION_SIZE : natural := 16 -- Size of instruction in bits
    );
    port(
        clk : in std_logic;
        reset : in std_logic;
        address_bus_out : out std_logic_vector(ADDRESS_SIZE - 1 downto 0);
        data_bus_in : in std_logic_vector(INSTRUCTION_SIZE - 1 downto 0)
    );
end processor;

architecture processor_arch of processor is
        
    component control_unit is
        port(
            clk : in std_logic;
            reset : in std_logic;
            instruction : in std_logic_vector(INSTRUCTION_SIZE - 1 downto 0);
            address_bus_out : out std_logic_vector(REGISTER_SIZE - 1 downto 0)
        );
    end component;
begin

    -- Control Unit: decodes instructions which flow in from data bus
    control_unit_instance: control_unit port map(
        clk => clk,
        reset => reset,
        instruction => data_bus_in,
        address_bus_out => address_bus_out
    );

end processor_arch ;