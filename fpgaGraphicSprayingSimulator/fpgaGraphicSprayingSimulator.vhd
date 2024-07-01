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
      vid_display : out std_logic
   );
end entity fpgaGraphicSprayingSimulator;

architecture fpgaGraphicSprayingSimulator of fpgaGraphicSprayingSimulator is
   signal pixel_x : std_logic_vector(9 downto 0);
   signal pixel_y : std_logic_vector(9 downto 0);
   signal red : std_logic_vector(3 downto 0);
   signal green : std_logic_vector(3 downto 0);
   signal blue : std_logic_vector(3 downto 0);
   signal redTractor, greenTractor, blueTractor : std_logic_vector(3 downto 0);
   signal redField, greenField, blueField : std_logic_vector(3 downto 0);
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

   component sprayField is
      generic (
         ticksForRGBDarkening : std_logic_vector(31 downto 0) := x"00100000"; -- 268.435.456;
         squaresQty : integer := 192;
         screenWidth: integer := 640;
         screenHeight: integer := 480;
         squareWidth : integer := 40
      );
      port (
         clk : in std_logic;
         tractorX : in std_logic_vector(9 downto 0);
         tractorY : in std_logic_vector(9 downto 0);
         pixelX : in std_logic_vector(9 downto 0);
         pixelY : in std_logic_vector(9 downto 0);
         red : out std_logic_vector(3 downto 0);
         green : out std_logic_vector(3 downto 0);
         blue : out std_logic_vector(3 downto 0)
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
      clock => clkDivided(25), -- Use the 25th bit for the slower clock
      reset => SW(9),
      x_pos => x_pos,
      y_pos => y_pos,
      direction => direction
   );
   
   tractorPrinter1: tractorPrinter port map(
      pixel_x, pixel_y, clkDivided(0), redTractor, greenTractor, blueTractor, x_pos, y_pos, direction
   );

   sprayField1: sprayField port map(clkDivided(0), x_pos, y_pos, pixel_x, pixel_y, redField, greenField, blueField);

   red <= redTractor when redTractor /= "0000" else redField;
   green <= greenTractor when greenTractor /= "0000" else greenField;
   blue <= blueTractor when blueTractor /= "0000" else blueField;

end architecture fpgaGraphicSprayingSimulator;
