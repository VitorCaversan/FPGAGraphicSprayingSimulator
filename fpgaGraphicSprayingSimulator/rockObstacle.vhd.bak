library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rockObstacle is
   port (
      column, row : in std_logic_vector(9 downto 0);
      clock : in std_logic;
      red, green, blue : out std_logic_vector(3 downto 0);
      x_pos, y_pos : in std_logic_vector(9 downto 0)
   );
end entity rockObstacle;

architecture rockObstacle_arch of rockObstacle is
   constant rock_width : integer := 40;
   constant rock_height : integer := 40;
   signal address : std_logic_vector(10 downto 0);
   signal romImage_q : std_logic_vector(11 downto 0);
   component romPedra is
      port (
         address : in std_logic_vector(10 downto 0);
         clock : in std_logic;
         q : out std_logic_vector(11 downto 0)
      );
   end component;
begin
   romPedra1: romPedra port map(address, clock, romImage_q);

   process(clock)
   begin
      if (clock'event and clock = '1') then
         if (unsigned(column) >= unsigned(x_pos) and unsigned(column) < unsigned(x_pos) + to_unsigned(rock_width, 10) and
             unsigned(row) >= unsigned(y_pos) and unsigned(row) < unsigned(y_pos) + to_unsigned(rock_height, 10)) then
            address <= std_logic_vector(to_unsigned((to_integer(unsigned(row)) - to_integer(unsigned(y_pos))) * rock_width + 
                                                    (to_integer(unsigned(column)) - to_integer(unsigned(x_pos))), 11));
         else
            address <= (others => '0');  -- Background color or default value
         end if;
      end if;
   end process;

   red   <= romImage_q(11 downto 8);
   green <= romImage_q(7 downto 4);
   blue  <= romImage_q(3 downto 0);
end architecture rockObstacle_arch;
