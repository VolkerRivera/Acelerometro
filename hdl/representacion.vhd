-- Los rangos de medida cumplen la siguiente formula: X_medida/Sensibilidad = (2*N - 15)/15. 
-- La sensibilidad de sensor es de 4mg/digito para las medidas realizas con 10 bits.
-- N = 1 hasta N = 15.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity representacion is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
     X_media:       in     std_logic_vector(11 downto 0);
     Y_media:       in     std_logic_vector(11 downto 0);	 
	 leds_X: buffer std_logic_vector(7 downto 0);
	 display_Y: buffer std_logic_vector(7 downto 0);
	 seg_Y: buffer std_logic_vector(6 downto 0);
	 fin: in std_logic
    );
end entity;

architecture rtl of representacion is

begin

  seg_Y <= "1111111";
  
  leds_X <= "11111110" when  X_media <= -217  else
			"11111100" when X_media > -217 and X_media <= -184 else
            "11111000" when X_media > -184 and X_media <= -151  else
            "11110000" when X_media > -151 and X_media <= -118  else
            "11100000" when X_media > -118 and X_media <= -85  else
            "11000000" when X_media > -85 and X_media <= -52  else
            "10000000" when X_media > -52 and X_media <= -19  else
            "00000000" when X_media > -19 and X_media <= 14  else
            "00000001" when X_media > 14 and X_media <= 47  else
            "00000011" when X_media > 47 and X_media <= 80 else
            "00000111" when X_media > 80 and X_media <= 113 else
            "00001111" when X_media > 113 and X_media <= 146 else
            "00011111" when X_media > 146 and X_media <= 179 else
            "00111111" when X_media > 179 and X_media <= 212 else
            "01111111" when X_media > 212 and X_media <= 245 else
            "01111111";

	
	display_Y <= "01111111" when  Y_media <= -217  else
				 "00111111" when Y_media > -217 and Y_media <= -184 else
                 "00011111" when Y_media > -184 and Y_media <= -151  else
	             "00001111" when Y_media > -151 and Y_media <= -118  else
                 "00000111" when Y_media > -118 and Y_media <= -85  else
                 "00000011" when Y_media > -85 and Y_media <= -52  else
                 "00000001" when Y_media > -52 and Y_media <= -19  else
                 "00000000" when Y_media > -19 and Y_media <= 14  else
                 "10000000" when Y_media > 14 and Y_media <= 47  else
                 "11000000" when Y_media > 47 and Y_media <= 80 else
                 "11100000" when Y_media > 80 and Y_media <= 113 else
                 "11110000" when Y_media > 113 and Y_media <= 146 else
                 "11111000" when Y_media > 146 and Y_media <= 179 else
				 "11111100" when Y_media > 179 and Y_media <= 212 else
                 "11111110" when Y_media > 212 and Y_media <= 245 else
				 "11111110";
	
end rtl;