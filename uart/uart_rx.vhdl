library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    generic (
        CLKS_PER_BIT : integer :=  105-- 12 MHz / 115200 Hz = 105
    );
    port (
        clk : in std_logic;
        rx : in std_logic;
        rx_dv : out std_logic;
        rx_byte : out std_logic_vector(7 downto 0)
    );
end uart_rx;

architecture uart_rx_arch of uart_rx is
    type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup);
    signal r_SM_Main : t_SM_Main := s_Idle;

    signal r_rx_data_r : std_logic := '0';
    signal r_rx_data : std_logic := '0';

    signal clk_count : integer range 0 to CLKS_PER_BIT - 1 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal r_rx_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal r_rx_dv : std_logic := '0';

begin

    p_sample : process(clk) 
    begin 
        if rising_edge(clk) then
            r_rx_data_r <= rx;
            r_rx_data <= r_rx_data_r;
        end if;
    end process;

    p_uart_rx : process (clk)
    begin
        if rising_edge(clk) then
            
            case r_SM_Main is

                when s_Idle =>
                    r_rx_dv <= '0';
                    clk_count <= 0;
                    bit_index <= 0;

                if r_rx_data = '0' then       -- Start bit detected
                    r_SM_Main <= s_RX_Start_Bit;
                else
                    r_SM_Main <= s_Idle;
                end if;

                    
                -- Check middle of start bit to make sure it's still low
                when s_RX_Start_Bit =>
                    if clk_count = (CLKS_PER_BIT-1)/2 then
                        if r_rx_data = '0' then
                            clk_count <= 0;  -- reset counter since we found the middle
                            r_SM_Main <= s_RX_Data_Bits;
                        else
                            r_SM_Main <= s_Idle;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                        r_SM_Main   <= s_RX_Start_Bit;
                    end if;

                    
                -- Wait CLKS_PER_BIT-1 clock cycles to sample serial data
                when s_RX_Data_Bits =>
                if clk_count < CLKS_PER_BIT-1 then
                    clk_count <= clk_count + 1;
                    r_SM_Main <= s_RX_Data_Bits;
                else
                    clk_count            <= 0;
                    r_rx_byte(bit_index) <= r_RX_Data;
                    
                    -- Check if we have sent out all bits
                    if bit_index < 7 then
                        bit_index <= bit_index + 1;
                        r_SM_Main   <= s_RX_Data_Bits;
                    else
                        bit_index <= 0;
                        r_SM_Main   <= s_RX_Stop_Bit;
                    end if;
                end if;


                -- Receive Stop bit.  Stop bit = 1
                when s_RX_Stop_Bit =>
                    -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                    if clk_count < CLKS_PER_BIT-1 then
                        clk_count <= clk_count + 1;
                        r_SM_Main   <= s_RX_Stop_Bit;
                    else
                        r_rx_dv     <= '1';
                        clk_count <= 0;
                        r_SM_Main   <= s_Cleanup;
                    end if;

                            
                -- Stay here 1 clock
                when s_Cleanup =>
                    r_SM_Main <= s_Idle;
                    r_rx_dv   <= '0';

                    
                when others =>
                    r_SM_Main <= s_Idle;

            end case;
        end if;
    end process;
    
    rx_dv <= r_rx_dv;
    rx_byte <= r_rx_byte;

end uart_rx_arch;