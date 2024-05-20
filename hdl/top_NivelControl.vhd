library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top_NivelControl is 
port(clk:       in     std_logic;
     nRst:      in     std_logic;
	 --Senales conectadas al Slave
     nCS:	       buffer  std_logic; -- Se mantiene a nivel bajo durante una transferencia
     SPC:          buffer std_logic;  -- Reloj SPI
	 SDI:		   inout std_logic;
	 SDO:	       inout std_logic; --  Conectado al SDI del Slave
     
	 leds_X: buffer std_logic_vector(7 downto 0);
	 display_Y: buffer std_logic_vector(7 downto 0);
	 seg_Y: buffer std_logic_vector(6 downto 0)
	);
end entity;


architecture struct of top_NivelControl is

--Senales Control - SPI
  signal ini: std_logic;
  signal dir_add: std_logic_vector(5 downto 0);
  signal data_in: std_logic_vector(7 downto 0);
  signal nWR: std_logic;
  signal fin: std_logic;
  
-- Senales Interfaz - Calc Offset
  signal ena_calc_offset: std_logic;
  signal data_rd: std_logic_vector(7 downto 0);

  signal X_out_bias: std_logic_vector(10 downto 0);
  signal Y_out_bias: std_logic_vector(10 downto 0);
  signal muestra_bias_rdy: std_logic;

--Senales Estimador -> Representacion
 signal X_media:   std_logic_vector(11 downto 0);
 signal Y_media: std_logic_vector(11 downto 0);
 
 
    
begin

  U0: entity work.controlador_SPI(rtl)
      generic map(CUENTA_5ms => 250000) -- Realizacion de medidas cada 5 ms
			   --Control -> SPI
      port map(clk 	=> clk,
			   nRst	=> nRst,
			   ini	=> ini,
			   dir_add => dir_add,
			   data_in => data_in,
			   nWR	   => nWR,
			   fin	   => fin);
  U1: entity work.interfaz_SPI(rtl)
      port map(clk => clk,
               nRst => nRst,
			    -- SPI -> Control
		       ini=> ini,
		       fin=> fin,
			   dir_add=> dir_add,
		       data_in=> data_in,
			   nWR => nWR,
			   -- SPI -> Calc_offset
		       ena_calc_offset=> ena_calc_offset,
			   data_rd => data_rd,
			   nCS=> nCS,
		       SPC=> SPC,
		       SDI=> SDI,
		       SDO => SDO);
	U2: entity work.calc_offset(rtl)
	    generic map(N => 64) --Numero de medidas realizadas en 360 ms
	    port map(clk => clk,
                 nRst => nRst,
			     -- SPI -> Calc_offset
		         ena_rd=> ena_calc_offset,
			     dato_rd => data_rd,
				 -- Calc_offset -> Estimador
				 X_out_bias => X_out_bias,
				 Y_out_bias => Y_out_bias,
				 muestra_bias_rdy => muestra_bias_rdy
			    );
	U3: entity work.estimador(rtl)
	   generic map(N => 32) --Numero de medidas realizadas en 160 ms
		port map (clk => clk,
				  nRst => nRst,
				  -- Calc_offset -> Estimador
				  X_out_bias => X_out_bias,
				  Y_out_bias => Y_out_bias,
				  muestra_bias_rdy => muestra_bias_rdy,
				  -- Estimador -> Representacion
				  X_media => X_media,
				  Y_media => Y_media
				  );
	U4: entity work.representacion(rtl)
		port map (clk => clk,
				  nRst => nRst,
				  -- Estimador -> Representacion
				  X_media => X_media,
				  Y_media => Y_media,
				  leds_X => leds_X,
				  display_Y => display_Y,
				  seg_Y => seg_Y,
				  fin => fin
				  );
    
end struct;
