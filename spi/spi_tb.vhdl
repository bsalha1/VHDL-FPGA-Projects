library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_tb is
    generic(
        TX_SIZE : natural := 10
    );
end spi_tb;

architecture spi_tb_arch of spi_tb is

    type data_array is array (0 to 7) of std_logic_vector(TX_SIZE - 1 downto 0);

    signal clk : std_logic := '1';
    signal reset : std_logic := '1';

    signal spi_cs : std_logic;
    signal spi_sdo : std_logic;
    signal spi_sdi : std_logic := '0';
    signal spi_scl : std_logic;
    
    signal tx_data : std_logic_vector(TX_SIZE - 1 downto 0) := (others => '0');
    signal tx_data_index : integer range 0 to 7 := 0;
    signal tx_data_buffer : data_array := (
        "0011100001", "0000100000", "0000000100", 
        "0000011000", "0000001000", "0000110000",
        "0000001000", "0100000101");
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
    tx_data <= tx_data_buffer(tx_data_index);

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

    p_reset: process(clk)
    begin
        if rising_edge(clk) then
            reset <= '0';
        end if;
    end process;

    -- Queue TX: while the FIFO is not empty, enable SPI transmission
    p_queue_tx: process (tx_done)
    begin
        
        if rising_edge(tx_done) then

            if tx_data_index < 7 then
                tx_data_index <= tx_data_index + 1;
                tx_en <= '1';
            else
                tx_data_index <= 0;
                tx_en <= '0';
            end if;
        
        end if;

    end process;

end spi_tb_arch;