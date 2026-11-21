library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pixel_gen is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    pix_en  : in  std_logic;
    h_cnt   : in  unsigned(9 downto 0);
    v_cnt   : in  unsigned(9 downto 0);
    ball_x  : in  unsigned(9 downto 0);
    ball_y  : in  unsigned(9 downto 0);
    ball_red: in  std_logic;
    p1_y    : in  unsigned(9 downto 0);
    p2_y    : in  unsigned(9 downto 0);
    H       : out std_logic;
    V       : out std_logic;
    DAC_CLK : out std_logic;
    Rout    : out std_logic_vector(7 downto 0);
    Gout    : out std_logic_vector(7 downto 0);
    Bout    : out std_logic_vector(7 downto 0)
  );
end entity pixel_gen;

architecture rtl of pixel_gen is

  -- VGA timing signals
  signal hs_raw, vs_raw : std_logic;
  signal active          : std_logic;

  -- Pixel color signals
  signal red, green, blue : std_logic_vector(7 downto 0);