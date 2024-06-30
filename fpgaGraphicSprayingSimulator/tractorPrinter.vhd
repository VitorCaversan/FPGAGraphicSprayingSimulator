library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tractorPrinter is
   port (
      column, row : in std_logic_vector(9 downto 0);
      clock : in std_logic;
      red, green, blue : out std_logic_vector(3 downto 0);
      x_pos, y_pos : in std_logic_vector(9 downto 0);
      direction : in std_logic_vector(1 downto 0) -- Only two bits needed for 4 directions
   );
end entity tractorPrinter;

architecture tractorPrinter of tractorPrinter is
   constant tractor_width : integer := 40;
   constant tractor_height : integer := 40;
   signal address : std_logic_vector(16 downto 0);
   signal romImage_q : std_logic_vector(11 downto 0);
   component romImage IS
   PORT (
      address : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
      clock : IN STD_LOGIC := '1';
      q : OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
   );
   END component;
begin
   romImage1: romImage PORT MAP (address, clock, romImage_q);

   process(clock)
   begin
      if (clock'event and clock = '1') then
         -- Determine the address based on direction
         case direction is
            when "00" =>  -- Normal
               if (unsigned(column) >= unsigned(x_pos) and unsigned(column) < unsigned(x_pos) + to_unsigned(tractor_width, 10) and
                   unsigned(row) >= unsigned(y_pos) and unsigned(row) < unsigned(y_pos) + to_unsigned(tractor_height, 10)) then
                  address <= std_logic_vector(to_unsigned((to_integer(unsigned(row)) - to_integer(unsigned(y_pos))) * tractor_width + 
                                                          (to_integer(unsigned(column)) - to_integer(unsigned(x_pos))), 17));
               else
                  address <= (others => '0');  -- Background color or default value
               end if;
            when "01" =>  -- Rotated 90 degrees
               if (unsigned(column) >= unsigned(x_pos) and unsigned(column) < unsigned(x_pos) + to_unsigned(tractor_height, 10) and
                   unsigned(row) >= unsigned(y_pos) and unsigned(row) < unsigned(y_pos) + to_unsigned(tractor_width, 10)) then
                  address <= std_logic_vector(to_unsigned((tractor_width - 1 - (to_integer(unsigned(column)) - to_integer(unsigned(x_pos)))) * tractor_height + 
                                                          (to_integer(unsigned(row)) - to_integer(unsigned(y_pos))), 17));
               else
                  address <= (others => '0');  -- Background color or default value
               end if;
            when "10" =>  -- Rotated 180 degrees
               if (unsigned(column) >= unsigned(x_pos) and unsigned(column) < unsigned(x_pos) + to_unsigned(tractor_width, 10) and
                   unsigned(row) >= unsigned(y_pos) and unsigned(row) < unsigned(y_pos) + to_unsigned(tractor_height, 10)) then
                  address <= std_logic_vector(to_unsigned((tractor_height - 1 - (to_integer(unsigned(row)) - to_integer(unsigned(y_pos)))) * tractor_width + 
                                                          (tractor_width - 1 - (to_integer(unsigned(column)) - to_integer(unsigned(x_pos)))), 17));
               else
                  address <= (others => '0');  -- Background color or default value
               end if;
            when "11" =>  -- Rotated 270 degrees
               if (unsigned(column) >= unsigned(x_pos) and unsigned(column) < unsigned(x_pos) + to_unsigned(tractor_height, 10) and
                   unsigned(row) >= unsigned(y_pos) and unsigned(row) < unsigned(y_pos) + to_unsigned(tractor_width, 10)) then
                  address <= std_logic_vector(to_unsigned((to_integer(unsigned(column)) - to_integer(unsigned(x_pos))) * tractor_height + 
                                                          (tractor_height - 1 - (to_integer(unsigned(row)) - to_integer(unsigned(y_pos)))), 17));
               else
                  address <= (others => '0');  -- Background color or default value
               end if;
            when others =>
               address <= (others => '0');  -- Background color or default value
         end case;
      end if;
   end process;

   red   <= romImage_q(11 downto 8);
   green <= romImage_q(7 downto 4);
   blue  <= romImage_q(3 downto 0);
end architecture tractorPrinter;
