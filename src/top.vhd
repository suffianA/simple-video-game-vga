library ieee;
use ieee.std_logic_1164.all;


entity top is
  port (
    clk              : in  std_logic;
    rst              : in  std_logic;
    SW               : in std_logic_vector(3 downto 0);
    H, V             : out std_logic;
    DAC_CLK          : out std_logic;
    Rout, Gout, Bout : out std_logic_vector(7 downto 0)
  );
end entity top;

architecture structural of top is


entity svgp_top is
  port (
    clk     : in  std_logic;                      -- 50 MHz oscillator
    rst_btn : in  std_logic;                      -- BTN_SOUTH, active-high
    SW      : in  std_logic_vector(3 downto 0);   -- player controls
    H       : out std_logic;                      -- HSYNC (active-low)
    V       : out std_logic;                      -- VSYNC (active-low)
    DAC_CLK : out std_logic;                      -- 25 MHz pixel clock
    Rout    : out std_logic_vector(7 downto 0);
    Gout    : out std_logic_vector(7 downto 0);
    Bout    : out std_logic_vector(7 downto 0)
  );
end entity svgp_top;

architecture rtl of svgp_top is

  -- Synchronized inputs
  signal rst_async : std_logic_vector(0 downto 0);
  signal rst_sync  : std_logic_vector(0 downto 0);
  signal rst       : std_logic;
  signal sw_sync   : std_logic_vector(3 downto 0);

  -- Pixel-rate enable
  signal pix_en_r  : std_logic := '0';

  -- vga_timing -> pixel_gen / game_logic
  signal h_cnt, v_cnt : coord_t;
  signal hs_raw       : std_logic;
  signal vs_raw       : std_logic;
  signal active       : std_logic;
  signal frame_tick   : std_logic;

  -- game_logic -> pixel_gen
  signal ball_x, ball_y : coord_t;
  signal ball_red       : std_logic;
  signal p1_y, p2_y     : coord_t;

begin

  ------------------------------------------------------------------------------
  -- Input synchronizers (every asynchronous input goes through 2 FFs)
  ------------------------------------------------------------------------------
  rst_async(0) <= rst_btn;

  u_rst_sync : entity work.sync_2ff
    generic map (WIDTH => 1, INIT_VAL => '1')     -- power up held in reset
    port map (clk => clk, d => rst_async, q => rst_sync);

  rst <= rst_sync(0);

  u_sw_sync : entity work.sync_2ff
    generic map (WIDTH => 4, INIT_VAL => '0')
    port map (clk => clk, d => SW, q => sw_sync);

  ------------------------------------------------------------------------------
  -- 25 MHz pixel enable: free-running (not reset) so DAC_CLK never stops
  ------------------------------------------------------------------------------
  pix_en_gen : process (clk)
  begin
    if rising_edge(clk) then
      pix_en_r <= not pix_en_r;
    end if;
  end process pix_en_gen;

  DAC_CLK <= pix_en_r;

  ------------------------------------------------------------------------------
  -- Sync generator: counters give x = h_cnt, y = v_cnt in active video
  ------------------------------------------------------------------------------
  u_timing : entity work.vga_timing
    port map (
      clk        => clk,
      rst        => rst,
      pix_en     => pix_en_r,
      h_cnt      => h_cnt,
      v_cnt      => v_cnt,
      hsync      => hs_raw,
      vsync      => vs_raw,
      active     => active,
      frame_tick => frame_tick
    );

  ------------------------------------------------------------------------------
  -- Game state: updates once per frame_tick (start of vertical blanking)
  ------------------------------------------------------------------------------
  u_game : entity work.game_logic
    port map (
      clk        => clk,
      rst        => rst,
      frame_tick => frame_tick,
      p1_up      => sw_sync(0),
      p1_dn      => sw_sync(1),
      p2_up      => sw_sync(2),
      p2_dn      => sw_sync(3),
      ball_x     => ball_x,
      ball_y     => ball_y,
      ball_red   => ball_red,
      p1_y       => p1_y,
      p2_y       => p2_y
    );

  ------------------------------------------------------------------------------
  -- Pixel colour + registered VGA outputs (RGB, H, V aligned)
  ------------------------------------------------------------------------------
  u_pixel : entity work.pixel_gen
    port map (
      clk      => clk,
      pix_en   => pix_en_r,
      x        => h_cnt,
      y        => v_cnt,
      active   => active,
      hsync_in => hs_raw,
      vsync_in => vs_raw,
      ball_x   => ball_x,
      ball_y   => ball_y,
      ball_red => ball_red,
      p1_y     => p1_y,
      p2_y     => p2_y,
      r_out    => Rout,
      g_out    => Gout,
      b_out    => Bout,
      hsync    => H,
      vsync    => V
    );

end architecture rtl;