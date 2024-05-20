
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_SPI is
port(clk:           in     std_logic;
     nRst:          in     std_logic;
	 -- Senales de entrada: provienen del bloque de control
     ini:           in     std_logic;  -- Se activa cada que se quiere realizar una transferen, cada 5 ms
     dir_add:       in std_logic_vector(5 downto 0);   -- direccion del registro 
     data_in:       in std_logic_vector ( 7 downto 0); -- Dato a enviar en una escritura 
     nWR:           in std_logic; -- Indica la operacion que vamos a realizar. Escritura = 0 Lectura = 1
	 -- Senales de salida 
     fin: 	          buffer std_logic; -- Indica que el master esta listo para iniciar la trasferencia
	 --Senales conectadas al calc_offset
     ena_calc_offset: buffer std_logic; 
	 data_rd:         buffer std_logic_vector(7 downto 0);
	 
	 --Senales conectadas al Slave
     nCS:	       buffer  std_logic;  -- Se mantiene a nivel bajo durante transferencia.
     SPC:          buffer std_logic;   -- Reloj SPI generado
	 SDO:	       inout std_logic;    -- Conectado al SDI del Slave
     SDI:          inout std_logic     -- Conectado al SDO del Slave
    );
end entity;


architecture rtl of interfaz_SPI is

--Reloj del sistema T_clk = 50 MHz

-- CONSTANTES DEL SPC
 constant SPI_T_SPC:	natural := 10;	--Valor implementado = 200 ns (fSCLmax = 5MHz)
 constant SPI_T_CS_SU:	natural :=  1;	--Valor implementado = 20 ns. Tiempo que tiene que pasar desde que CS se pone a hasta que comienza a generarse SPC
 constant SPI_T_LOW: natural := SPI_T_SPC/2; --Valor implementado = 100 ns
 constant SPI_T_HIGH: natural:= SPI_T_SPC/2; -- Valor implementado = 100 ns


 constant BITS_LECTURA: natural:= 40; -- Transferencia lectura: 1 byte addres + 4 bytes de medidas  
 constant BITS_ESCRITURA: natural:= 16; --Transferencia escritura: 1 byte addres + 1 bytes de dato

-- CONTADORES
 signal cnt_SPI: std_logic_vector(3 downto 0); --Modulo 10.
 signal cnt_ciclos_SPI: std_logic_vector(5 downto 0); --Contamos numero de ciclos transferencia = bits 
 signal start_SPC: std_logic;   --Inicia el contador de mi SPC
 signal periodo_SPI: std_logic; --Indica cuando tenemos un flanco de subida en SPC
 signal rst_cont_SPI: std_logic;

-- Senales registros
 signal reg_SDO: std_logic_vector(16 downto 0); -- 2 bytes
 signal reg_SDI: std_logic_vector(7 downto 0);  -- 1 bytes
 signal cargar_dato: std_logic;
 signal desplazar_dato: std_logic;

--Constantes cargar dato
 signal leer_SDI: std_logic;
 signal escribir_SDO: std_logic;
 constant LECTURA: natural:= 6;
 constant ESCRITURA: natural:=1;

 signal n_reg_SPC: std_logic;
 signal reg_SPC: std_logic;
 signal n_periodo: std_logic;
 signal r_dato_r: std_logic_vector(39 downto 0);

-- Sincronizacion de SDI
  signal SDI_in_sinc_1:	std_logic;
  signal SDI_in_sinc_2: std_logic;
  signal SDI_in_sinc_3: std_logic;


 begin
 
 CONTADOR_SPC: process (nRst,clk)
 begin
	if nRst = '0' then 
	  cnt_SPI <= (others => '0');  
	  nCS <= '1';
	  start_SPC <= '0';
	elsif clk'event and clk = '1' then
	  if rst_cont_SPI = '1' then
	        nCS <= '1';
		start_SPC <= '0';
		cnt_SPI <= (others => '0');
	  elsif ini = '1' then -- Si recibo un tick que me indica comienzo de una transferencia pongo bajo CS
		nCS <= '0';
	  elsif nCs = '0' and start_SPC = '0' then --Como se me ha puesto bajo necesito respetar el tiempo de tsu_CS
		if cnt_SPI < SPI_T_CS_SU then --Espero ese tiempo.
		  cnt_SPI <= cnt_SPI + 1;
		else
		  cnt_SPI <= (0 => '1', others => '0');
		  start_SPC <= '1'; --Indica que se genere SPC
		end if;
	  elsif nCs = '0' and start_SPC = '1' then --Comenzamos a generar nuestro reloj
		if cnt_SPI < SPI_T_SPC then
		 cnt_SPI <= cnt_SPI + 1;
		else
		 cnt_SPI <= (0 => '1',others => '0');
		end if;
	  end if;
    end if;
 end process;
 
 n_periodo <= '1' when cnt_SPI = SPI_T_SPC else '0'; 

 CONTADOR_CICLOS: process (nRst,clk)
 begin
	if nRst = '0' then 
	  cnt_ciclos_SPI <= (0 => '1',others => '0');  
	elsif clk'event and clk = '1' then
	  if start_SPC = '1' then -- Indica comienzo de la transferencia por lo que estoy generando RELOJ
		if periodo_SPI = '1' then
		cnt_ciclos_SPI <= cnt_ciclos_SPI + 1;
		end if;
	  else 
	    cnt_ciclos_SPI <= (0 => '1', others => '0');
	  end if;	
    end if;
 end process;
 
 --Esta senal me va a reiniciar el contadon cnt_SPI para que pueda realizar otro CLK
 
 rst_cont_SPI <= '1' when nWR = '1' and cnt_ciclos_SPI = BITS_LECTURA   and cnt_SPI = 10 else --Me indica cuando se ha completado la transferencia
				 '1' when nWR = '0' and cnt_ciclos_SPI = BITS_ESCRITURA and cnt_SPI = 10 else	-- he quitado el -1 porque hacia 15 bits solo
				 '0';
				 
 n_reg_SPC <= '0'     when cnt_SPI < 5 and start_SPC = '1' else -- Para que incluya el modulo maximo
              '0'     when cnt_SPI = 5 and start_SPC = '1'else  -- Para que el nivel alto sea de la mitad en adelante
              '1';
 
 --------------------------------------------------ELIMINACION DE GLITCHES-----------------------------------------------------------
 -- Al filtrar nuestra senal SPC hay que modificar las variables del contadon cnt_ciclos_SPI porque se atrasa un ciclo de reloj
 
 filtro_SPC:process(clk,nRst)
  begin
   if nRst = '0' then
      SPC <= n_reg_SPC;
	  periodo_SPI <= '0';
   elsif clk'event and clk = '1' then
      SPC <= n_reg_SPC;
	  periodo_SPI <= n_periodo;
   end if;
 end process;

 
 --------------------------------------------------REGISTROS DE SALIDA Y ENTRADA----------------------------------------------------- 
 
 leer_SDI <= '1' when (cnt_SPI = (LECTURA + 1)) and nCS = '0' else '0'; -- El +1 es porque queremos que nos salga en el ciclo siguiente de lectura o escritura y al ser combinacional lo hace al instante
 escribir_SDO <= '1' when (cnt_SPI = (ESCRITURA + 1)) and nCS= '0' else '0';
 
 
 REGISTRO_SDO: process(nRst,clk)
  begin
   if nRst = '0' then
	reg_SDO <= (others => '0');
	
   elsif clk'event and clk = '1' then
    if cargar_dato = '1' then 
	reg_SDO <= '0'&nWR&'1'&dir_add&data_in;

    elsif desplazar_dato = '1' then
	reg_SDO <= reg_SDO(15 downto 0) & '0';
	
   end if;
  end if;
 end process;
 
 
 SDO <= reg_SDO(16) when reg_SDO(16) = '0' else 
	    '1';
		
 cargar_dato    <= '1' when nWR = '0' and ini = '1' else 
		           '1' when nWR = '1' and ini = '1' else
		           '0';
				   
 desplazar_dato <= '1' when nWR = '0' and escribir_SDO = '1' else
				   '1' when nWR = '1' and escribir_SDO = '1' and cnt_ciclos_SPI < 8 else
				   '0';
				   
 REGISTRO_SDI: process(nRst,clk)
  begin
   if nRst = '0' then
	data_rd <= (others => '0');
   elsif clk'event and clk = '1' then
    if fin = '1' then
       data_rd <= (others => '0');
    elsif nWR = '1' then --Como se trata de una orden de lectura 
      if leer_SDI = '1' and cnt_ciclos_SPI > 8 then --
	 data_rd <= data_rd(6 downto 0) & SDI_in_sinc_3;
      end if;
   end if;
  end if;
 end process;
 
 --------------------------------------------------SINCRONIZACION DE SDI----------------------------------------------------- 
 
 SINCRONIZACION_SDI: process(nRst,clk)
  begin
   if nRst = '0' then
	SDI_in_sinc_1 <= '0';		-- Se ponen a '1' porque la linea SDA en reposo esta a nivel alto
	SDI_in_sinc_2 <= '0';
    SDI_in_sinc_3 <= '0';
    elsif clk'event and clk = '1' then
	SDI_in_sinc_1 <= SDI;
	SDI_in_sinc_2 <= SDI_in_sinc_1;
    SDI_in_sinc_3 <= SDI_in_sinc_2;
     end if;
   end process;

 --------------------------------------------------SENALES DE SALIDA----------------------------------------------------- 
 -- fin : Indica fin de una transferencia tanto de lectura como de escritura
 -- ena_calc_offset: Se activa en cada bit leido en transferencias de lecturas. En total debemos tener 4 pulsos, de los 4 bytes recibidos. Conectada al calc_offset

 fin <= '1' when start_SPC = '0' and nCS = '1' else
        '0'; 
		
 ena_calc_offset <= '1' when cnt_SPI = 8 and (cnt_ciclos_SPI = 16 or cnt_ciclos_SPI = 24 or cnt_ciclos_SPI = 32 or cnt_ciclos_SPI = 40) and nWR = '1' else '0';	
 
 end rtl;