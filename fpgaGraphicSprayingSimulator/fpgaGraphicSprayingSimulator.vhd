library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Takes the VGA driver and connects it's output to the VGA port
-- The o_pixel_x and o_pixel_y are the pixel coordinates, connected to the row and collumn inputs
-- of the imagePrinter component
-- The output of the imagePrinter component is connected to the VGA color channels

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
   signal alive : std_logic;
   signal clkDivided : std_logic_vector(0 downto 0);

   component imagePrinter is
   port (column, row : in std_logic_vector(9 downto 0);
         clock : in std_logic;
         red, green, blue : out std_logic_vector(3 downto 0));
   end component imagePrinter;
   component clkDiv is
   PORT
   (
      clock      : IN STD_LOGIC ;
      q      : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
   );
   end component;
   component VGA_drvr is
   generic(
      -- Default VGA 640-by-480 display parameters
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
      -- calculated based on other generic parameters
      H_counter_size: natural:= 10;      --  depends on above generic values
      V_counter_size: natural:= 10      --  depends on above generic values
   );
   port(
      -- clock and reset - vid_clk is the appropriate video clock
      -- vid_clk would be 25MHz for a 640 x 480 display
      i_vid_clk:       in    std_logic;
      i_rstb:          in    std_logic;
      -- standard video sync signals
      o_h_sync:      out    std_logic;
      o_v_sync:      out    std_logic;
       --  X and Y values for current pixel location being written to the screen
      --  Can be used for reference in upper levels of design
      o_pixel_x:       out    std_logic_vector (H_counter_size -1 downto 0);
      o_pixel_y:       out    std_logic_vector (V_counter_size - 1 downto 0);
      -- signal to indicate display is actively being written
      -- use this to set RGB values to 0 when not on an active part of the screen
      -- ** not used if using the RGB in/out synchronous signals
      o_vid_display:   out    std_logic;
      -- convenience signals
      -- syncronize rgb outputs to vid_clk
      i_red_in:        in    std_logic_vector((Color_bits - 1) downto 0);
      i_green_in:      in      std_logic_vector((Color_bits - 1) downto 0);
      i_blue_in:      in      std_logic_vector((Color_bits - 1) downto 0);
      o_red_out:      out    std_logic_vector((Color_bits - 1) downto 0);
      o_green_out:   out   std_logic_vector((Color_bits - 1) downto 0);
      o_blue_out:      out   std_logic_vector((Color_bits - 1) downto 0)
   );
   end component;

begin
   clkDiv1: clkDiv port map(MAX10_CLK1_50, clkDivided);
   VGA1: VGA_drvr port map(clkDivided(0), SW(0), VGA_HS, VGA_VS, pixel_x, pixel_y, vid_display, red, green, blue, VGA_R, VGA_G, VGA_B);
   imagePrinter1: imagePrinter port map(pixel_x_final, pixel_y_final, clkDivided(0), red, green, blue);

   pixel_x_final <= std_logic_vector(640 - unsigned(pixel_x)) when SW(2) = '1'
                     else pixel_x;
   pixel_y_final <= std_logic_vector(480 - unsigned(pixel_y)) when SW(3) = '1'
                     else pixel_y;

   red_tap <= red;
   green_tap <= green;
   blue_tap <= blue;

end architecture fpgaGraphicSprayingSimulator;