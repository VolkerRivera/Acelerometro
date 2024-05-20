
library ieee;                    
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity test_interfaz_SPI is             
end entity; 

architecture test of test_interfaz_SPI is
 signal clk       : std_logic;
 signal nRst      : std_logic;
 signal fin   : std_logic;
 signal ini : std_logic;
 signal ena_calc_offset    : std_logic;
 signal dir_add   : std_logic_vector (5 downto 0);
 signal data_in   : std_logic_vector (7 downto 0);
 signal data_rd	  : std_logic_vector (7 downto 0);
 signal ena_stop_SPI     : std_logic;
 signal nWR : std_logic;
 signal nCS  	  : std_logic;
 signal SPC 	  : std_logic;
 signal SDI 	  : std_logic;
 signal SDO  	  : std_logic;
 constant Tclk : time := 20 ns;
 signal end_sim : boolean := false;
 
 signal pos_X: std_logic_vector(1 downto 0);
 signal pos_Y: std_logic_vector(1 downto 0);
 signal leds_X:  std_logic_vector(7 downto 0);
 signal	display_Y: std_logic_vector(7 downto 0);
 signal	seg_Y:  std_logic_vector(7 downto 0);
 

  

begin  
  dut: entity work.top_NivelControl(struct)
  port map(
           clk => clk,
           nRst => nRst,
		   nCS=> nCS,
		   SPC=> SPC,
		   SDI=> SDI,
		   SDO => SDO,
		   leds_X => leds_X,
		   display_Y => display_Y,
		   seg_Y => seg_Y
		   );

  --SDO <= '1';

  U2_mon: entity work.monitores(sim)
          port map(CS => nCS,
                   SPC => SPC,
		   SDI => SDI,
		   SDO => SDO);

  agente: entity work.agente_spi(sim)
  port map(
		   pos_X => pos_X,
		   pos_Y => pos_Y,
           nCS	 => nCS,
           SPC	 => SPC,
           SDI	 => SDO,
           SDO	 => SDI
           ); 
 
   U0_sim: entity work.driver_clk_nRst(sim)
          generic map(Tclk => Tclk)
          port map(clk  => clk,
                   nRst => nRst);
 
 process
 begin
    pos_X <= "00";
    pos_Y <= "00";
   wait until clk'event and clk = '1';
   wait until clk'event and clk = '1';
   wait for 1000000*Tclk;
    pos_X <= "01";
    pos_Y <= "11";
   wait until clk'event and clk = '1';
   wait until clk'event and clk = '1';
   wait for 1000100*Tclk;
   pos_X <= "01";
   pos_Y <= "11";
   wait until clk'event and clk = '1';
   wait until clk'event and clk = '1';
   wait for 1000150*Tclk;
   
   pos_X <= "11";
   pos_Y <= "11";
   
   wait until ini'event and ini = '1';
   wait until clk'event and clk = '1';
   wait until clk'event and clk = '1';
   wait for 1000*Tclk;
   
 end process;
 
end test;
