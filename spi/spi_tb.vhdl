library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_tb is
    generic(
        NUM_DATA : natural := 18;
        TX_SIZE : natural := 10
    );
end spi_tb;

architecture spi_tb_arch of spi_tb is

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';

    signal spi_cs : std_logic;
    signal spi_sdo : std_logic;
    signal spi_sdi : std_logic := '0';
    signal spi_scl : std_logic;
    
    type data_array is array (0 to NUM_DATA - 1) of std_logic_vector(TX_SIZE - 1 downto 0);
    signal tx_data : std_logic_vector(TX_SIZE - 1 downto 0) := (others => '0');
    signal tx_data_index : integer range 0 to NUM_DATA - 1 := 0;
    signal tx_data_array : data_array := (
        "0000111000", "0000001000", "0000000001", "0000000110", "0000000010", "0000001100", "0000000010", -- Initialization
        "1001001000", -- H 
        "1001100101", -- e
        "1001101100", -- l
        "1001101100", -- l
        "1001101111", -- o
        "1000100000", --  
        "1001010111", -- W
        "1001101111", -- o
        "1001110010", -- r
        "1001101100", -- l
        "1001100100"  -- d
    );

    signal tx_en : std_logic := '1';
    signal tx_done : std_logic;

    component spi is 
        port (
            clk : in std_logic;
            cs_out : out std_logic;
            sdo_out : out std_logic;
            sdi_in : in std_logic;
            scl_out : out std_logic;
            tx_byte_in : in std_logic_vector(TX_SIZE - 1 downto 0);
            tx_en : in std_logic;
            tx_done : out std_logic
        );
    end component;
    
begin
    
    clk <= not clk after 42 ns; -- 12 MHz
    tx_data <= tx_data_array(tx_data_index);

    spi_instance: spi port map (
        clk => clk,
        cs_out => spi_cs,
        sdo_out => spi_sdo,
        sdi_in => spi_sdi,
        scl_out => spi_scl,
        tx_byte_in => tx_data,
        tx_en => tx_en,
        tx_done => tx_done
    );

    -- Reset: create an artificial reset before first rising edge of core clock
    p_reset: process(clk)
    begin
        if rising_edge(clk) then
            reset <= '0';
        end if;
    end process;

    -- Queue TX: queue packets for transmission until none left
    p_queue_tx: process (tx_done)
    begin
        
        if rising_edge(tx_done) then

            if reset = '1' then
                tx_data_index <= 0;
                tx_en <= '1';

            elsif tx_data_index < NUM_DATA - 1 then
                tx_data_index <= tx_data_index + 1;
                tx_en <= '1';

            else
                tx_en <= '0';
            end if;
        
        end if;

    end process;

end spi_tb_arch;