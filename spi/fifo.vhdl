library ieee;
use ieee.std_logic_1164.all;

entity fifo is
    generic(
        ENTRY_SIZE : natural := 8;
        DEPTH : integer := 32
    );
    port(
        clk : in std_logic;
        reset : in std_logic;

        write_en : in std_logic;
        write_data : in std_logic_vector(ENTRY_SIZE - 1 downto 0);
        full : out std_logic;

        read_en : in std_logic;
        read_data : out std_logic_vector(ENTRY_SIZE - 1 downto 0);
        empty : out std_logic
    );
end fifo;

architecture fifo_arch of fifo is

    type fifo_data_array is array (0 to DEPTH - 1) of std_logic_vector(ENTRY_SIZE - 1 downto 0);

    signal fifo_data : fifo_data_array := (others => (others => '0'));

    signal write_index : integer range 0 to DEPTH - 1 := 0;
    signal read_index : integer range 0 to DEPTH - 1 := 0;

    signal fifo_count : integer range -1 to DEPTH + 1 := 0;

    signal fifo_full : std_logic;
    signal fifo_empty : std_logic;
begin

    p_control: process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                fifo_count <= 0;
                write_index <= 0;
                read_index <= 0;
            else
                -- Keep track of fifo_count
                if write_en = '1' and read_en = '0' then
                    fifo_count <= fifo_count + 1;
                elsif write_en = '0' and read_en = '1' then
                    fifo_count <= fifo_count - 1;
                end if;

                -- Control write_index
                if write_en = '1' and fifo_full = '0' then
                    if write_index = DEPTH - 1 then
                        write_index = 0;
                    else 
                        write_index = write_index + 1;
                    end if;
                end if;

                -- Control read_index
                if read_en = '1' and fifo_empty = '0' then
                    if read_index = DEPTH - 1 then
                        read_index = 0;
                    else 
                        read_index = read_index + 1;
                    end if;
                end if;

                if write_en = '1' then
                    fifo_data(write_index) <= write_data;
                end if;
            end if;
        end if;
    end process;

    read_data <= fifo_data(read_index);
 
    fifo_full <= '1' when fifo_count = DEPTH else '0';
    fifo_empty <= '1' when fifo_count = 0 else '0';
    
    full  <= fifo_full;
    empty <= fifo_empty;


end fifo_arch;