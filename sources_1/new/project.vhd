----------------------------------------------------------------------------------
-- Justin Igmen
-- ENEL 384 Project
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project is
    Port ( clk : in STD_LOGIC;
           month_sel : in STD_LOGIC_VECTOR (3 downto 0);
           SSEG_CA : out STD_LOGIC_VECTOR (6 downto 0);
           SSEG_AN : out STD_LOGIC_VECTOR (7 downto 0);
           is_leap_year : in STD_LOGIC;
           start : in STD_LOGIC;
           secret : in STD_LOGIC;
           RGB1_Blue : out STD_LOGIC;
           RGB2_Red : out STD_LOGIC;
           led : out STD_LOGIC_VECTOR (15 downto 0));
           
end project;

architecture Behavioral of project is

signal cath_int : integer range 0 to 9 := 0;
signal cath_val : std_logic_vector (6 downto 0) := (others => '1');

signal digit_select : std_logic_vector (2 downto 0) := (others => '0');

signal clk_250Hz : integer range 0 to 31999 := 0;

signal pos_0 : STD_LOGIC_VECTOR (6 downto 0);
signal pos_1 : STD_LOGIC_VECTOR (6 downto 0);
signal pos_2 : STD_LOGIC_VECTOR (6 downto 0);
signal pos_3 : STD_LOGIC_VECTOR (6 downto 0);
signal pos_4 : STD_LOGIC_VECTOR (6 downto 0);
signal pos_5 : STD_LOGIC_VECTOR (6 downto 0);
signal pos_6 : STD_LOGIC_VECTOR (6 downto 0);
signal pos_7 : STD_LOGIC_VECTOR (6 downto 0);

signal timer : std_logic_vector (25 downto 0) := "00000000000000000000000000";
signal secret_timer : std_logic_vector (25 downto 0) := "00000000000000000000000000";

signal slowedCounter : STD_LOGIC_VECTOR( 3 downto 0 ) := "0000" ;
signal counter : STD_LOGIC_VECTOR( 7 downto 0 ) := "00000000" ;

begin

-- drive the cathode segments based on the output of the BCD to 7 Seg decoder

SSEG_CA <= cath_val;


sevenseg_mux_clk_proc : process (CLK)
begin
   if ( CLK'event and CLK ='1') then
	   clk_250Hz <= clk_250Hz +1;
		if (clk_250Hz = 31999) then
			digit_select <= digit_select+1;
		end if;
   end if;
end process;	

cath_mux_proc : process (digit_select)
begin
   case digit_select is
      when "000" => cath_val <= pos_0;
      when "001" => cath_val <= pos_1;
      when "010" => cath_val <= pos_2;
      when "011" => cath_val <= pos_3;
      when "100" => cath_val <= pos_4;
      when "101" => cath_val <= pos_5;
      when "110" => cath_val <= pos_6;
      when "111" => cath_val <= pos_7;
      when others => cath_val <= "11111111";
   end case;
end process;

anod_sel_proc : process (digit_select)
begin
   case digit_select is
      when "000" => SSEG_AN <= "11111110";
      when "001" => SSEG_AN <= "11111101";
      when "010" => SSEG_AN <= "11111011";
      when "011" => SSEG_AN <= "11110111";
      when "100" => SSEG_AN <= "11101111";
      when "101" => SSEG_AN <= "11011111";
      when "110" => SSEG_AN <= "10111111";
      when "111" => SSEG_AN <= "01111111";
      when others => SSEG_AN <= "11111111";
   end case;
end process;

month_sel_proc : process (clk, month_sel)
begin
    if (start = '0') then
        pos_0 <= "1100001";
        pos_1 <= "0100011";
        pos_2 <= "0101111";
        pos_3 <= "0001100";
        pos_4 <= "1111111";
        pos_5 <= "0011001";
        pos_6 <= "0000000";
        pos_7 <= "0110000";
    else
            pos_0 <= "1111111"; 
            pos_3 <= "0111111"; 
            pos_4 <= "0111111";                     
            pos_7 <= "1111111";
        if (month_sel = "0000") then
            pos_0 <= "1001100";
            pos_1 <= "0001000";
            pos_2 <= "0100001";
            pos_3 <= "1001000";
            pos_4 <= "0000110";
            pos_5 <= "1000111";
            pos_6 <= "0001000";
            pos_7 <= "1000110";
        elsif (month_sel = "0001" or month_sel = "0011" or month_sel = "0101" or month_sel = "0111" 
            or month_sel = "1000" or month_sel = "1010" or month_sel = "1100") then
            
            pos_1 <= "1111001"; 
            pos_2 <= "0110000";
                            
            if (month_sel = "0001") then    --January
                pos_5 <= "1111001";
                pos_6 <= "1000000";
            elsif (month_sel = "0011") then --March
                pos_5 <= "0110000";
                pos_6 <= "1000000";
            elsif (month_sel = "0101") then --May
                pos_5 <= "0010010";
                pos_6 <= "1000000";
            elsif (month_sel = "0111") then --July
                pos_5 <= "1111000";
                pos_6 <= "1000000";
            elsif (month_sel = "1000") then --August
                pos_5 <= "0000000";
                pos_6 <= "1000000";
            elsif (month_sel = "1010") then --October
                pos_5 <= "1000000";
                pos_6 <= "1111001";
            elsif (month_sel = "1100") then --December
                pos_5 <= "0100100";
                pos_6 <= "1111001";
            end if;
            --January, March, May, July, August, October, December
            
        elsif (month_sel = "0100" or month_sel = "0110" or month_sel = "1001" or month_sel = "1011") then
            pos_1 <= "1000000";
            pos_2 <= "0110000";
            
            if (month_sel = "0100") then    --April
                pos_5 <= "0011001";
                pos_6 <= "1000000";
            elsif (month_sel = "0110") then --June
                pos_5 <= "0000010";
                pos_6 <= "1000000";    
            elsif (month_sel = "1001") then --September
                pos_5 <= "0010000";
                pos_6 <= "1000000";
            elsif (month_sel = "1011") then --November
                pos_5 <= "1111001";
                pos_6 <= "1111001";
            end if;
        
            --April, June, September, November
            
        elsif (month_sel = "0010") then   
            pos_5 <= "0100100";
            pos_6 <= "1000000";
       
            if (is_leap_year = '0') then
                pos_1 <= "0000000";
                pos_2 <= "0100100";
            else
                pos_1 <= "0010000";
                pos_2 <= "0100100";
                
                --other part of super secret code
                if (secret = '1') then
                    pos_0 <= "1111111";
                    pos_1 <= "0100001";
                    pos_2 <= "0000110";
                    pos_3 <= "0111001";
                    pos_4 <= "0010010";
                    pos_5 <= "1000001";
                    pos_6 <= "0000011";
                    pos_7 <= "1111111";
                end if;
                -----------------------------------
                
            end if;
        else
            pos_0 <= "1111111";
            pos_1 <= "1111111";
            pos_2 <= "1111111";
            pos_3 <= "0101111";
            pos_4 <= "0100011";
            pos_5 <= "0101111";
            pos_6 <= "0101111";
            pos_7 <= "0000110";
        
        end if;
    end if;  
end process;

my_birthmonth_and_pwm : process (clk)
begin
    if ( CLK'event and CLK ='1') then
        if (start = '1') then
            if (month_sel = "0111") then
                timer <= timer + 1;
                counter <= counter + 1;
      
                if (counter = "11111111") then
                    slowedCounter <= slowedCounter + 1 ;
                end if;
                                
                if (timer >= "10000000000000000000000000") then
                    if (slowedCounter < "1000") then
                        led <= "1010101010101010";
                    else
                        led <= "0000000000000000";
                    end if;
                else
                    if (slowedCounter < "1000") then
                         led <= "0101010101010101";
                    else
                         led <= "0000000000000000";
                    end if;
                end if;
            else
                led <= "0000000000000000";
            end if;
         else
            led <= "0000000000000000";
         end if;
    end if;
    
end process;

--Just for fun
super_secret_code : process(clk, secret)
begin
    if ( CLK'event and CLK ='1') then
        if (start ='1') then         
            if (is_leap_year = '1') then   
                if (month_sel = "0010") then 
                    if (secret = '1') then 
                        secret_timer <= secret_timer + 1;      
                        if (secret_timer >= "10000000000000000000000000") then
                                RGB1_Blue <= '0';
                                RGB2_Red <= '1';
                        else 
                                RGB1_Blue <= '1';
                                RGB2_Red <= '0';
                        end if;
                     else
                        RGB1_Blue <= '0';
                        RGB2_Red <= '0';
                     end if;
                else 
                    RGB1_Blue <= '0';
                    RGB2_Red <= '0';
                end if;
             else 
                    RGB1_Blue <= '0';
                    RGB2_Red <= '0';
             end if;
        else 
            RGB1_Blue <= '0';
            RGB2_Red <= '0';
        end if;
    end if;
end process;
    
end Behavioral;
