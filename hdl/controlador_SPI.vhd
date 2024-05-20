library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity controlador_SPI is
generic(CUENTA_5ms: in natural := 2500000); 
port(clk:           in     std_logic;
     nRst:          in     std_logic;
	 fin: 	        in std_logic; -- Indica que el master esta listo para iniciar una nueva trasferencia
	 
	 -- Senales de salida conectadas al SPI
     ini:           buffer     std_logic;  -- Indica inicio de transferencia. Activada cada 5ms
     dir_add:       buffer std_logic_vector(5 downto 0);   -- Direccion del registro 
     data_in:       buffer std_logic_vector (7 downto 0); -- Dato a enviar en una escritura 
     nWR:           buffer std_logic -- Indica la operacion que vamos a realizar
	);
end entity;

architecture rtl of controlador_SPI is
	-- Señales contador 5ms
	signal cnt_5ms: std_logic_vector(25 downto 0);
	signal tic_5ms: std_logic;
	
	-- Señales para los estados del automata
	type t_estado is (reposo, conf_reg4, conf_reg1, lecturas);
	signal estado: t_estado;
	
begin
	-- Timer 5ms
	process(clk, nRst)
	begin
	if nRst = '0' then
		cnt_5ms <= (0 =>'1',others => '0');
  
	elsif clk'event and clk ='1' then
		if cnt_5ms < CUENTA_5ms then
			cnt_5ms <= cnt_5ms + 1;  
		else
			cnt_5ms <= (0 =>'1',others => '0');
		end if;
	end if; 
	end process; 
	
	tic_5ms <= '1' when cnt_5ms = CUENTA_5ms else '0';
	
	process(clk, nRst)
	begin
		if nRst = '0' then
		estado <= reposo;
		nWR <= '0';
		dir_add <= "000000"; 
		data_in <= X"00";
		ini <= '0';

		elsif clk'event and clk ='1' then 
			case estado is
				when reposo => 
					if tic_5ms = '1' and fin = '1' then
					    ini <= '1';	
						nWR <= '0';
						dir_add <= "100011"; --x23
						data_in <= X"80";
						estado <= conf_reg4;
					else 
						ini <= '0';
					end if;					
				when conf_reg4 =>
					if tic_5ms = '1' and fin = '1' then
					    ini <= '1';	
						nWR <= '0';
						dir_add <= "100000"; --x23
						data_in <= X"63";
						estado <= conf_reg1;
					else 
						ini <= '0';
						
					end if;		
				when conf_reg1 =>
				  if tic_5ms = '1' and fin = '1' then
					    ini <= '1';	
						nWR <= '1';
						dir_add <= "101000"; --x28
						estado <= lecturas;
					else 
						ini <= '0';
						
					end if;
				when lecturas =>
				if fin = '1' and tic_5ms = '1' then
						ini <= '1';
						nWR <= '1';
						dir_add <= "101000"; --x28
						
				else 
						ini <= '0';
				end if;
				
			end case;
		end if;
	end process;
end rtl;
