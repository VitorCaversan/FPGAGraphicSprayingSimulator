library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tractorMover is
   port (
      clock : in std_logic;
      reset : in std_logic;
      x_pos, y_pos : out std_logic_vector(9 downto 0);
      direction : out std_logic_vector(1 downto 0)
   );
end entity tractorMover;

architecture Behavioral of tractorMover is
   signal x, y : unsigned(9 downto 0) := (others => '0');
   signal dir : std_logic_vector(1 downto 0) := "11";  -- Initial direction is 270° (moving right)
   signal move_clock : std_logic;
begin
   process(clock, reset)
   begin
      if reset = '1' then
         x <= (others => '0');
         y <= (others => '0');
         dir <= "11";  -- Reset direction to 270°
      elsif rising_edge(clock) then
         if move_clock = '1' then
            case dir is
               when "11" =>  -- Moving right
                  if x < to_unsigned(600, 10) then
                     x <= x + 40;
                  else
                     dir <= "00";  -- Change direction to 0° (down)
                     y <= y + 40;  -- Move down one row
                  end if;
               when "00" =>  -- Moving down
                  if y < to_unsigned(440, 10) then
                     if x = to_unsigned(600, 10) then
                        dir <= "01";  -- Change direction to 90° (left)
                     else
                        dir <= "11";  -- Change direction to 270° (right)
                     end if;
                  end if;
               when "01" =>  -- Moving left
                  if x > to_unsigned(0, 10) then
                     x <= x - 40;
                  else
                     dir <= "00";  -- Change direction to 0° (down)
                     y <= y + 40;  -- Move down one row
                  end if;
               when others =>
                  null;
            end case;
         end if;
      end if;
   end process;

   x_pos <= std_logic_vector(x);
   y_pos <= std_logic_vector(y);
   direction <= dir;

   -- Generate move clock signal
   process(clock)
   begin
      if rising_edge(clock) then
         move_clock <= not move_clock;
      end if;
   end process;
end architecture Behavioral;
