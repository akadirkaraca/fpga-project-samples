library	IEEE;
use	IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use	IEEE.std_logic_unsigned.all;

entity	vending_machine is
	port(	---inputs
			clk 		: in std_logic;
			rst 		: in std_logic;
			para_giris_in	: in std_logic;
			para		: in std_logic_vector(4 downto 0);
			
			---outputs
			urun_hazir	: out std_logic;   --ürün verildi sinyali
			para_ustu_out	: out std_logic	--para üstü verildi sinyali
		);
end	entity;

architecture arc of vending_machine is

type state_type is (IDLE, PARA_GIRIS, URUN_TESLIM, PARA_USTU);
signal state : state_type;

---Process Signal:
signal toplam_para : std_logic_vector(4 downto 0);  ---Register olarak tanýmladýk
signal eksik_para_flag : std_logic;		--- Eksik para atýldýðýnda para_giris_in durumundan para_üstü durumuna geçiþ için

signal fiyat: std_logic_vector(4 downto 0) :="01010";

begin
	fiyat <= "01010";

	process(clk,rst)
	begin
		if(rst='1') then
			state <= IDLE;
			toplam_para <= (others => '0'); ---others tüm bitleri sýfýrlamak için
			urun_hazir <= '0';
			para_ustu_out <= '0';
			eksik_para_flag <= '0';
		elsif(rising_edge(clk)) then
			case state is
				when IDLE =>
				--Reset process parameters/outputs
					state <= IDLE;
					toplam_para <= (others => '0');
					urun_hazir <= '0';
					para_ustu_out <= '0';
					eksik_para_flag <= '0';
					
					if(para_giris_in = '1') then
						state <= PARA_GIRIS;
						toplam_para <= toplam_para + para;
					else
						state <= IDLE;
					end if;
					
				when PARA_GIRIS =>
									
					if(para_giris_in = '1') then
						state <= PARA_GIRIS;
						toplam_para <= toplam_para + para;  --Toplam para miktarýný güncelle
					else	-- Para giriþi durdu
						if(toplam_para >= fiyat) then
							state <= URUN_TESLIM;
						else
							state <= PARA_USTU;
							eksik_para_flag <= '1';	
						end if;
					end if;
								
				when URUN_TESLIM =>
					toplam_para <= toplam_para -fiyat;
					urun_hazir <='1';
					state <= PARA_USTU;
				
				when PARA_USTU=>
				    urun_hazir <= '0';
					eksik_para_flag <= '0';
					if(toplam_para/="00000") then
						toplam_para <= toplam_para - "00001"; ---Makine her seferinde 1 TL paraüstü verebilir
						para_ustu_out <= '1';
						state <= PARA_USTU;
					else ---toplam para artýk 0'dýr.
						state <= IDLE;
						para_ustu_out <= '0';
					end if;
					
				when others =>
					state <= IDLE;
					toplam_para <= (others => '0');
					urun_hazir <= '0';
					para_ustu_out <= '0';
					eksik_para_flag <= '0';
			end case;
		end if;
	end process;
	
end architecture;