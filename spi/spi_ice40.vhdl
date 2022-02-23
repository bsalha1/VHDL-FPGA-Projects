library ieee;
use ieee.std_logic_1164.all;

entity spi_ice40 is
    port(
        clk : in std_logic;
        spi_cs : out std_logic;
        spi_sdo : out std_logic;
        spi_sdi : in std_logic;
        spi_scl : out std_logic
    );
end spi_ice40;

architecture spi_ice40_arch of spi_ice40 is

    type data_array is array (0 to 17) of std_logic_vector(9 downto 0);

    -- Displays Hello World on my SPI OLED display
    signal tx_data : data_array := (
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

    signal tx_byte : std_logic_vector(9 downto 0) := (others => '0');
    signal tx_data_index : integer range 0 to 17 := 0;
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

    spi_instance: spi port map (
        clk => clk,
        cs => spi_cs,
        sdo => spi_sdo,
        sdi => spi_sdi,
        scl => spi_scl,
        tx_byte => tx_byte,
        tx_en => tx_en,
        tx_done => tx_done
    );

    tx_byte <= tx_data(tx_data_index);

    p_queue_tx: process (clk)
    begin

        if rising_edge(clk) then
            if tx_done = '1' and tx_en /= '1' then

                if tx_data_index < 17 then
                    tx_data_index <= tx_data_index + 1;
                    tx_en <= '1';
                end if;

            else 
                tx_en <= '0';
            end if;

        end if;

    end process;

    
end spi_ice40_arch;