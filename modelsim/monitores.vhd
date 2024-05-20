library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity monitores is
port(
	CS : in std_logic;
	SPC: in std_logic;
	SDI: in std_logic;
	SDO: in std_logic);
end entity;

architecture sim of monitores is

  signal CS_UP: boolean;
  signal CS_DOWN: boolean;
  
  signal SPC_UP: boolean;  
  signal T_SPC_UP: time := 0 ns;
  signal SPC_DOWN: boolean;
  signal T_SPC_DOWN: time := 0 ns;
  
  signal T_SU_CONDITION: time := 0 ns;
  signal T_HOLD_CONDITION: time := 0 ns;

  signal T_CS_DOWN: time := 0 ns;
  signal T_CS_UP: time := 0 ns;

  signal STOP: boolean;

  


  -- Constantes para autoverificacion de tiempos del SPC
  
  constant t_su_cs: time := 5 ns;
  constant t_hold_cs: time := 20 ns;
  constant t_periodo_spc: time := 200 ns;
  constant t_low : time := 100 ns;
  constant t_high : time := 100 ns;
  
begin

  
  SPC_UP <= (SPC'event and SPC = '1') when now > 100 ns
			else false when SPC_UP'event;
			
  SPC_DOWN <= (SPC'event and SPC = '0') when now > 100 ns
			else false when SPC_DOWN'event;

  CS_UP <= (CS'event and CS = '1') when now > 100 ns
			else false when CS_UP'event;

  CS_DOWN <= (CS'event and CS = '0') when now > 100 ns
			else false when CS_DOWN'event;
			
  T_SPC_UP <= now when SPC_UP;
  T_SPC_DOWN <= now when SPC_DOWN;

  T_CS_UP <= now when CS_UP;
  T_CS_DOWN <= now when CS_DOWN;
  
  T_SU_CONDITION <= now when (CS'event and CS = '0') and (SPC'event and SPC = '0');


  STOP <= (CS'event and CS = '1' and SPC = '1') when now > 200 ns
           else false when STOP'event;

  --T_HOLD_CONDITION	<= now when (SPC'event and SPC = '1') and 	

-- Verificacion de tiempos:
-- Frecuencia de SPC correcta

assert (not SPC_DOWN or ((now - T_SPC_DOWN) >= t_periodo_spc)) and
	   (not SPC_UP or ((now - T_SPC_UP) >= t_periodo_spc))
report "Frecuencia de SPC > 5 MHz"
severity error;

  -- Duracion de SPC_LOW >= t_low  --------------------------
  assert (not SPC_UP or ((now - T_SPC_DOWN) >= t_low))
  report "Nivel bajo de SPC < TLOW_min"
  severity error;
  
    -- Duracion de SPC_HIGH >= THIGH_min  ------------------------
  assert (not SPC_DOWN or ((now - T_SPC_UP) >= t_high))
  report "Nivel alto de SPC < THIGH_min"
  severity error;
  
  -- Tiempo de set up cs 
  assert (not SPC_DOWN or ((now - T_CS_DOWN) >= t_su_cs))
  report "El t_su_cs < 5 ns"
  severity error;

  -- Tiempo de hold cs

  assert (not stop or ((now - T_SPC_UP) >= t_hold_cs))
  report "El t_hold_cs < 20 ns"
  severity error;
  


end sim;