library ieee;
use ieee.std_logic_1164.all;

entity spi is
    generic(
        TX_SIZE : integer := 10; -- 10 bit transfer size
        CLK_DIV : integer := 150 -- 12MHz / 120 = 120 KHz SCK
    );
    port(
        clk : in std_logic;
        cs : out std_logic;
        sdo : out std_logic;
        sdi : in std_logic;
        scl : out std_logic;
        tx_byte : in std_logic_vector(TX_SIZE - 1 downto 0);
        tx_en : in std_logic;
        tx_done : out std_logic
    );
end spi;

architecture spi_arch of spi is
    type spi_status is (
        IDLE, START_TX, DATA_TX, STOP_TX
    );

    signal status : spi_status := IDLE;
    signal bit_index : integer range 0 to TX_SIZE - 1 := 0;
    signal tx_data : std_logic_vector(TX_SIZE - 1 downto 0) := (others => '0');
    signal serial_out : std_logic := '0';
    signal chip_select : std_logic := '1';
    signal done : std_logic := '0';

    signal r_scl : std_logic := '1';
    signal scl_count : integer range 0 to CLK_DIV * 2 := 0;
    signal scl_rise : std_logic := '0';
    signal scl_fall : std_logic := '0';
    
begin

    sdo <= serial_out;
    cs <= chip_select;
    tx_done <= done;
    scl <= r_scl;

    -- SCL control
    p_scl_ctrl: process(clk)
    begin
        if rising_edge(clk) then
            
            -- SCL Falling edge
            if scl_count = CLK_DIV - 1 then
                scl_count <= scl_count + 1;
                scl_rise <= '0';
                scl_fall <= '1';
            -- SCL Rising edge
            elsif scl_count = 2 * CLK_DIV - 1 then
                scl_count <= 0;
                scl_rise <= '1';
                scl_fall <= '0';
            else 
                scl_rise <= '0';
                scl_fall <= '0';
                scl_count <= scl_count + 1;
            end if;

        end if;

    end process;

    p_spi_tx: process(clk)
    begin
        if rising_edge(clk) then
            case status is

                -- Poll TX_EN until it is high, then transition to START_TX state
                when IDLE =>
                    chip_select <= '1';
                    r_scl <= '1';

                    -- Latch tx_byte to tx_data and flag done as low
                    if tx_en = '1' then
                        done <= '0';
                        status <= START_TX;
                        tx_data <= tx_byte;
                    end if;

                -- After first rising edge of SCL, pull CS low and transition to DATA_TX state
                when START_TX =>

                    if scl_rise = '1' then
                        chip_select <= '0';
                        bit_index <= TX_SIZE - 1;
                        status <= DATA_TX;
                    end if;

                -- Toggle SCL and latch TX data to TX line
                when DATA_TX =>
                    if scl_fall = '1' then
                        r_scl <= '0';
                        
                        serial_out <= tx_data(bit_index);

                    elsif scl_rise = '1' then
                        r_scl <= '1';
                        
                        if bit_index > 0 then
                            bit_index <= bit_index - 1;
                        else 
                            status <= STOP_TX;
                        end if;
                    end if;

                -- After what would be the last falling edge of SCL, 
                -- pull TX line low, CS high, flag done, and transition to IDLE
                when STOP_TX =>

                    if scl_fall = '1' then
                        serial_out <= '0';
                        done <= '1';
                        chip_select <= '1';
                        status <= IDLE;
                    end if;
            end case;
        end if;
    end process;

end spi_arch;