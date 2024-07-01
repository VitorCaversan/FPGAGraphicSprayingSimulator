library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Generic: ticksForRGBDarkening in std_logic_vector
-- Inputs: clk, tractorX, tractorY, pixelX, pixelY in std_logic_vector
-- Outputs: red, green, blue out std_logic_vector

-- An entity that represents all of the 192 40x40 squares of the 640x480 image.
-- Each square holds the value of darkness gradient of the pixels inside it (from 0 to 5).
-- After every ticksForRGBDarkening clock cycles, the RGB value of the square represented by tractorX
-- and tractorY is darkened in 1.
-- pixelX and pixelY are the coordinates of the pixel being analyzed by the VGA driver. The red,
-- green, and blue outputs are the RGB value of the square where the pixel is located.
-- The red, green, and blue values are calculated based on the darkness gradient of the square in the
-- brown spectrum.

entity sprayField is
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
end sprayField;

architecture sprayField_arch of sprayField is
   type square is array(0 to (squaresQty - 1)) of std_logic_vector(3 downto 0);
   signal squares : square;
   signal ticks : unsigned(31 downto 0);
   signal ticksForRGBDarkeningU : unsigned(31 downto 0);
   signal tractorXInt : integer;
   signal tractorYInt : integer;
   signal tractorXIndex : integer;
   signal tractorYIndex : integer;
   signal squareQtyInOneRow : integer := screenWidth / squareWidth;
   signal squareQtyInOneColumn : integer := screenHeight / squareWidth;
   signal squareIndexForPixel : integer;
   signal squareIndexForTractor : integer;

begin
   ticksForRGBDarkeningU <= unsigned(ticksForRGBDarkening);
   tractorXInt <= to_integer(unsigned(tractorX));
   tractorYInt <= to_integer(unsigned(tractorY));
   tractorXIndex <= tractorXInt / squareWidth;
   tractorYIndex <= tractorYInt / squareWidth;
   squareIndexForTractor <= tractorXIndex + (tractorYIndex * squareQtyInOneRow);

   process(clk)
   begin
      if rising_edge(clk) then
         if ticks = ticksForRGBDarkeningU then
            if tractorXInt < squareQtyInOneRow and tractorYInt < squareQtyInOneColumn then
               if squares(squareIndexForTractor) < "1111" then
                  squares(squareIndexForTractor) <= std_logic_vector(unsigned(squares(squareIndexForTractor)) + 1);
               end if;
            end if;
            ticks <= (others => '0');
         else
            ticks <= ticks + 1;
         end if;
      end if;
   end process;

   squareIndexForPixel <= ((to_integer(unsigned(pixelX)) / squareWidth) + ((to_integer(unsigned(pixelY)) / squareWidth) * squareQtyInOneRow));

   red <= "0000" when squares(squareIndexForPixel) = "0000" else
          "0000" when squares(squareIndexForPixel) = "0001" else
          "0000" when squares(squareIndexForPixel) = "0010" else
          "0000" when squares(squareIndexForPixel) = "0011" else
          "0000" when squares(squareIndexForPixel) = "0100" else
          "0000" when squares(squareIndexForPixel) = "0101" else
          "0000";
   green <= "0000" when squares(squareIndexForPixel) = "0000" else
            "0000" when squares(squareIndexForPixel) = "0001" else
            "0000" when squares(squareIndexForPixel) = "0010" else
            "0000" when squares(squareIndexForPixel) = "0011" else
            "0000" when squares(squareIndexForPixel) = "0100" else
            "0000" when squares(squareIndexForPixel) = "0101" else
            "0000";
   blue <= "0000" when squares(squareIndexForPixel) = "0000" else
           "0001" when squares(squareIndexForPixel) = "0001" else
           "0010" when squares(squareIndexForPixel) = "0010" else
           "0011" when squares(squareIndexForPixel) = "0011" else
           "0100" when squares(squareIndexForPixel) = "0100" else
           "0101" when squares(squareIndexForPixel) = "0101" else
           "0000";

end architecture sprayField_arch;