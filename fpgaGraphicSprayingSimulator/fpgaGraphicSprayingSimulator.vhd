library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fpgaGraphicSprayingSimulator is
   port(
      MAX10_CLK1_50 : in std_logic;
      SW: in std_logic_vector(9 downto 0);
      VGA_HS : out std_logic;
      VGA_VS : out std_logic;
      VGA_R : out std_logic_vector(3 downto 0);
      VGA_G : out std_logic_vector(3 downto 0);
      VGA_B : out std_logic_vector(3 downto 0);
      red_tap, green_tap, blue_tap : out std_logic_vector(3 downto 0);
      vid_display : out std_logic
   );
end entity fpgaGraphicSprayingSimulator;

architecture fpgaGraphicSprayingSimulator of fpgaGraphicSprayingSimulator is
   signal pixel_x : std_logic_vector(9 downto 0);
   signal pixel_y : std_logic_vector(9 downto 0);
   signal pixel_x_final : std_logic_vector(9 downto 0); -- 640 - pixel_x if SW(2) = 1
   signal pixel_y_final : std_logic_vector(9 downto 0); -- 480 - pixel_y if SW(3) = 1
   signal red : std_logic_vector(3 downto 0);
   signal green : std_logic_vector(3 downto 0);
   signal blue : std_logic_vector(3 downto 0);
   signal clkDivided : std_logic_vector(25 downto 0);
   signal direction : std_logic_vector(1 downto 0);
   signal x_pos, y_pos : std_logic_vector(9 downto 0);

   component tractorPrinter is
      port (
         column, row : in std_logic_vector(9 downto 0);
         clock : in std_logic;
         red, green, blue : out std_logic_vector(3 downto 0);
         x_pos, y_pos : in std_logic_vector(9 downto 0);
         direction : in std_logic_vector(1 downto 0)
      );
   end component;
   
   component tractorMover is
      port (
         clock : in std_logic;
         reset : in std_logic;
         x_pos, y_pos : out std_logic_vector(9 downto 0);
         direction : out std_logic_vector(1 downto 0)
      );
   end component;
   
   component div_freq is
      port (
         clock : in std_logic;
         q : out std_logic_vector (25 downto 0)
      );
   end component;
   
   component VGA_drvr is
      generic(
         H_back_porch:    natural:=48;    
         H_display:       natural:=640; 
         H_front_porch: natural:=16;    
         H_retrace:       natural:=96;    
         V_back_porch:    natural:=33;    
         V_display:       natural:=480; 
         V_front_porch: natural:=10; 
         V_retrace:       natural:=2;
         Color_bits:      natural:=4;
         H_sync_polarity: std_logic:= '0';   --  depends on standard (negative -> 0), (positive -> 1)
         V_sync_polarity: std_logic:= '0';   --  depends on standard (negative -> 0), (positive -> 1)
         H_counter_size: natural:= 10;      --  depends on above generic values
         V_counter_size: natural:= 10      --  depends on above generic values
      );
      port(
         i_vid_clk:       in    std_logic;
         i_rstb:          in    std_logic;
         o_h_sync:      out    std_logic;
         o_v_sync:      out    std_logic;
         o_pixel_x:       out    std_logic_vector (H_counter_size -1 downto 0);
         o_pixel_y:       out    std_logic_vector (V_counter_size - 1 downto 0);
         o_vid_display:   out    std_logic;
         i_red_in:        in    std_logic_vector((Color_bits - 1) downto 0);
         i_green_in:      in    std_logic_vector((Color_bits - 1) downto 0);
         i_blue_in:       in    std_logic_vector((Color_bits - 1) downto 0);
         o_red_out:       out   std_logic_vector((Color_bits - 1) downto 0);
         o_green_out:     out   std_logic_vector((Color_bits - 1) downto 0);
         o_blue_out:      out   std_logic_vector((Color_bits - 1) downto 0)
      );
   end component;

begin
   divFreq1: div_freq port map(MAX10_CLK1_50, clkDivided);
   VGA1: VGA_drvr port map(clkDivided(0), SW(0), VGA_HS, VGA_VS, pixel_x, pixel_y, vid_display, red, green, blue, VGA_R, VGA_G, VGA_B);
   
   tractorMover1: tractorMover port map(
      clock => clkDivided(20), -- Use the 25th bit for the slower clock
      reset => SW(9),
      x_pos => x_pos,
      y_pos => y_pos,
      direction => direction
   );
   
   tractorPrinter1: tractorPrinter port map(
      pixel_x, pixel_y, clkDivided(0), red, green, blue, x_pos, y_pos, direction
   );

   pixel_x_final <= std_logic_vector(640 - unsigned(pixel_x)) when SW(2) = '1'
                     else pixel_x;
   pixel_y_final <= std_logic_vector(480 - unsigned(pixel_y)) when SW(3) = '1'
                     else pixel_y;

   red_tap <= red;
   green_tap <= green;
   blue_tap <= blue;

end architecture fpgaGraphicSprayingSimulator;
