library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_rom is
    generic(
        ADDRESS_SIZE : natural := 32; -- Size of address
        TOTAL_WORDS : natural := 8; -- Total number of words in memory
        INSTRUCTION_SIZE : natural := 16
    );
    port(
        clk : in std_logic;
        rom_addr_in : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
        instruction_out : out std_logic_vector(INSTRUCTION_SIZE - 1 downto 0)
    );
end instruction_rom;

architecture instruction_rom_arch of instruction_rom is

    type rom_data_buffer is array (0 to TOTAL_WORDS - 1) of std_logic_vector (INSTRUCTION_SIZE - 1 downto 0);

    constant rom_data: rom_data_buffer :=(
        "0010000100000001", -- mov r1,1
        "0010000000000011", -- mov r0,3
        "1011111100000000", -- ...
        "1011111100000000",

        "1011111100000000",
        "1011111100000000",
        "1011111100000000",
        "1011111100000000"
    );
begin
    
    instruction_out <= rom_data(to_integer(resize(unsigned(rom_addr_in), 3)));
end instruction_rom_arch;