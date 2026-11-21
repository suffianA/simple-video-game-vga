library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity timing is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    pix_en     : out  std_logic;
    h_cnt      : out unsigned(9 downto 0);      
    v_cnt      : out unsigned(9 downto 0); 
    hsync      : out std_logic;                 
    vsync      : out std_logic;
    active     : out std_logic;
    frame_tick : out std_logic 
  );
end entity timing;

architecture behavior of timing is

  signal pix_en_r : std_logic := '0';
  signal h_cnt_r, v_cnt_r : unsigned(9 downto 0) := (others => '0');

begin
process (clk)
  begin
    if rising_edge(clk) then
      pix_en_r <= not pix_en_r;                 
      if rst = '1' then
        h_cnt_r <= (others => '0');
        v_cnt_r <= (others => '0');
      elsif pix_en_r = '1' then
        if h_cnt_r = 799 then
          h_cnt_r <= (others => '0');
          if v_cnt_r = 524 then
            v_cnt_r <= (others => '0');
          else
            v_cnt_r <= v_cnt_r + 1;
          end if;
        else
          h_cnt_r <= h_cnt_r + 1;
        end if;
      end if;
    end if;
  end process;

  hsync <= '0' when h_cnt_r >= 656 and h_cnt_r < 752 else '1';
  vsync <= '0' when v_cnt_r >= 490 and v_cnt_r < 492 else '1';
  active <= '1' when h_cnt_r < 640 and v_cnt_r < 480 else '0';
  frame_tick <= '1' when v_cnt_r = 524 else '0';

  pix_en <= pix_en_r;
  h_cnt  <= h_cnt_r;
  v_cnt  <= v_cnt_r;

end behavior;