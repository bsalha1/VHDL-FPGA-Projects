library ieee;
use ieee.std_logic_1164.all;

entity spi_tb is
end spi_tb;

architecture spi_tb_arch of spi_tb is

    type data_array is array (0 to 7) of std_logic_vector(9 downto 0);

    signal clk : std_logic := '0';
    signal cs : std_logic;
    signal sdo : std_logic;
    signal sdi : std_logic := '0';
    signal scl : std_logic;
    signal tx_byte : std_logic_vector(9 downto 0) := (others => '0');
    signal tx_data_index : integer range 0 to 7 := 0;
    signal tx_data : data_array := (
        "0011100001", "0000100000", "0000000100", 
        "0000011000", "0000001000", "0000110000",
        "0000001000", "0100000101");
    -- signal tx_data : data_array := (
    --     "0000000001", "0000000010", "0000000011", 
    --     "0000000100", "0000000101", "0000000110",
    --     "0000000111", "0000001000");
    signal tx_en : std_logic := '1';
    signal tx_done : std_logic;

    component spi is 
        port (
            clk : in std_logic;
            cs : out std_logic;
            sdo : out std_logic;
            sdi : in std_logic;
            scl : out std_logic;
            tx_byte : in std_logic_vector(9 downto 0);
            tx_en : in std_logic;
            tx_done : out std_logic
        );
    end component;
    
begin
    
    clk <= not clk after 42 ns; -- 12 MHz

    spi_instance: spi port map (
        clk => clk,
        cs => cs,
        sdo => sdo,
        sdi => sdi,
        scl => scl,
        tx_byte => tx_byte,
        tx_en => tx_en,
        tx_done => tx_done
    );

    tx_byte <= tx_data(tx_data_index);

    p_queue_tx: process (clk)
    begin

        if rising_edge(clk) then
            if tx_done = '1' and tx_en /= '1' then

                if tx_data_index < 7 then
                    tx_data_index <= tx_data_index + 1;
                    tx_en <= '1';
                end if;

            else 
                tx_en <= '0';
            end if;
        end if;

    end process;

    -- p_sim: process
    -- begin
    --     wait for 100 us;

    --     tx_en <= '1';

    --     wait for 100 us;

    --     tx_en <= '0';

    --     wait;
    -- end process;

end spi_tb_arch;