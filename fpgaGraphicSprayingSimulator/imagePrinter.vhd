library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

-- input: row (10 bits), column (10 bits), clock (std_logic), invert (std_logic)
-- output: red (4 bits), green (4 bits), blue (4 bits)
-- it prints an image by calculating the address of the pixel in the image memory
-- based on the row and column values, and outputs the value of each color channel.
-- If invertV is on, the image is inverted vertically, if invertH is on, the image is inverted horizontally.
entity imagePrinter is
   port (column, row : in std_logic_vector(9 downto 0);
         clock : in std_logic;
         red, green, blue : out std_logic_vector(3 downto 0));
end entity imagePrinter;

architecture imagePrinter of imagePrinter is
   constant maxcol : integer  := 320;
   signal auxadd :  INTEGER RANGE 0 to 80000 ;--
   signal auxrow:	INTEGER RANGE 0 to 1023;--
   signal auxcolumn:	INTEGER RANGE 0 to 1023 ;--
   signal address : std_logic_vector(16 downto 0);
   signal romImage_q : std_logic_vector(11 downto 0);

   component romImage IS
   PORT
   (
      address      : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
      clock      : IN STD_LOGIC  := '1';
      q      : OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
   );
   END component;

begin
   romImage1: romImage PORT MAP (address, clock, romImage_q);

   process(clock)
   begin
      
      if (clock'event and clock = '1') then
         auxrow <= to_integer(unsigned(row));
         auxcolumn <= to_integer(unsigned(column));
         auxadd <=  ((480-auxrow)/2)*320+auxcolumn/2;
         address <=  std_logic_vector(to_unsigned(auxadd,17));
      end if;
   
   end process;



   red   <= romImage_q(11 downto 8);
   green <= romImage_q(7 downto 4);
   blue  <= romImage_q(3 downto 0);
end architecture imagePrinter;