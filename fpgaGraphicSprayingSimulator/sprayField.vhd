library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

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
   type ticksArray is array(0 to (squaresQty - 1)) of unsigned(31 downto 0);
   signal squares : square := (others => "0000");
   signal ticks : ticksArray := (others => (others => '0'));
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
         if ticks(squareIndexForTractor) = ticksForRGBDarkeningU then
            if tractorXInt < screenWidth and tractorYInt < screenHeight then
               if squares(squareIndexForTractor) < "0101" then
                  squares(squareIndexForTractor) <= std_logic_vector(unsigned(squares(squareIndexForTractor)) + 1);
               end if;
            end if;
            ticks(squareIndexForTractor) <= (others => '0');
         else
            ticks(squareIndexForTractor) <= ticks(squareIndexForTractor) + 1;
         end if;
      end if;
   end process;

   squareIndexForPixel <= ((to_integer(unsigned(pixelX)) / squareWidth) + ((to_integer(unsigned(pixelY)) / squareWidth) * squareQtyInOneRow));
   red <= "1011" when squares(squareIndexForPixel) = "0000" else
       "1001" when squares(squareIndexForPixel) = "0001" else
       "0111" when squares(squareIndexForPixel) = "0010" else
       "0110" when squares(squareIndexForPixel) = "0011" else
       "0100" when squares(squareIndexForPixel) = "0100" else
       "0110" when squares(squareIndexForPixel) = "0101" else
       "0100" when squares(squareIndexForPixel) = "0110" else
       "0100" when squares(squareIndexForPixel) = "0111" else
       "0111" when squares(squareIndexForPixel) = "1000" else
       "1000" when squares(squareIndexForPixel) = "1001" else
       "1010" when squares(squareIndexForPixel) = "1010" else
       "0110" when squares(squareIndexForPixel) = "1011" else
       "1001" when squares(squareIndexForPixel) = "1100" else
       "0110" when squares(squareIndexForPixel) = "1101" else
       "1110";

green <= "0110" when squares(squareIndexForPixel) = "0000" else
         "0101" when squares(squareIndexForPixel) = "0001" else
         "0100" when squares(squareIndexForPixel) = "0010" else
         "0011" when squares(squareIndexForPixel) = "0011" else
         "0011" when squares(squareIndexForPixel) = "0100" else
         "0011" when squares(squareIndexForPixel) = "0101" else
         "0100" when squares(squareIndexForPixel) = "0110" else
         "0110" when squares(squareIndexForPixel) = "0111" else
         "0100" when squares(squareIndexForPixel) = "1000" else
         "0100" when squares(squareIndexForPixel) = "1001" else
         "0100" when squares(squareIndexForPixel) = "1010" else
         "0100" when squares(squareIndexForPixel) = "1011" else
         "0011" when squares(squareIndexForPixel) = "1100" else
         "0011" when squares(squareIndexForPixel) = "1101" else
         "0011";

blue <= "0110" when squares(squareIndexForPixel) = "0000" else
        "0101" when squares(squareIndexForPixel) = "0001" else
        "0100" when squares(squareIndexForPixel) = "0010" else
        "0011" when squares(squareIndexForPixel) = "0011" else
        "0011" when squares(squareIndexForPixel) = "0100" else
        "0011" when squares(squareIndexForPixel) = "0101" else
        "0100" when squares(squareIndexForPixel) = "0110" else
        "0110" when squares(squareIndexForPixel) = "0111" else
        "0100" when squares(squareIndexForPixel) = "1000" else
        "0100" when squares(squareIndexForPixel) = "1001" else
        "0100" when squares(squareIndexForPixel) = "1010" else
        "0100" when squares(squareIndexForPixel) = "1011" else
        "0011" when squares(squareIndexForPixel) = "1100" else
        "0011" when squares(squareIndexForPixel) = "1101" else
        "0011";


end architecture sprayField_arch;
