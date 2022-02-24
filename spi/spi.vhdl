library ieee;
use ieee.std_logic_1164.all;

entity spi is
    generic(
        TX_SIZE : natural := 10; -- 10 bit transfer size
        CLK_DIV : natural := 150 -- 12MHz / 120 = 120 KHz SCK
    );
    port(
        clk : in std_logic;
        cs_out : out std_logic;
        sdo_out : out std_logic;
        sdi_in : in std_logic;
        scl_out : out std_logic;
        tx_byte_in : in std_logic_vector(TX_SIZE - 1 downto 0);
        tx_en : in std_logic;
        tx_done : out std_logic
    );
end spi;

architecture spi_arch of spi is
    type spi_state is (IDLE, START, DATA, STOP);
    signal state : spi_state := IDLE;

    signal tx_data : std_logic_vector(TX_SIZE - 1 downto 0) := (others => '0');
    signal sdo : std_logic := '0';
    signal cs : std_logic := '1';
    signal done_slow_ff : std_logic := '1';
    signal done_fast_ff : std_logic := '1';
    signal bit_index : integer range 0 to TX_SIZE - 1 := 0;

    signal internal_scl : std_logic := '1';
    
begin

    cs_out <= cs;
    sdo_out <= sdo;
    scl_out <= internal_scl when done_slow_ff = '0' else '1';

    sdo <= tx_data(bit_index);

    -- Internal SCL control: produce internal SCL clock which will be latched to outside SCL when a TX is occurring
    p_internal_scl_ctrl: process(clk)
        variable scl_count : integer range 0 to CLK_DIV - 1 := 0;
    begin
        if rising_edge(clk) then
            
            if scl_count = CLK_DIV - 1 then
                scl_count := 0;
                internal_scl <= not internal_scl;
            else
                scl_count := scl_count + 1;
            end if;

        end if;

    end process;

    -- Translate done from slow SPI clk domain to high core clk domain via double flop
    p_translate_done: process(clk)
    begin
        if rising_edge(clk) then
            done_fast_ff <= done_slow_ff;
            tx_done <= done_fast_ff;
        end if;
    end process;
    
    -- Handle TX: progresses through TX state machine
    p_handle_tx: process(internal_scl)
    begin
        if falling_edge(internal_scl) then

            case state is

                -- IDLE: Poll for TX requested
                when IDLE =>

                    tx_data <= (others => '0');
                    bit_index <= TX_SIZE - 1;

                    -- Pull CS low and transition to START state
                    if tx_en = '1' then
                        cs <= '0';
                        state <= START;
                    else
                        cs <= '1';
                        state <= IDLE;
                    end if;
                
                -- START: 
                when START =>
                    done_slow_ff <= '0';
                    tx_data <= tx_byte_in;
                    state <= DATA;
                
                -- DATA:
                when DATA =>
                    
                    if bit_index > 0 then
                        cs <= '0';
                        bit_index <= bit_index - 1;
                        done_slow_ff <= '0';
                    else
                        cs <= '1';
                        done_slow_ff <= '1';
                        state <= IDLE;
                    end if;

                when others =>
                        
            end case;
        
        end if;
    end process;

end spi_arch;