library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tractorMover is
   port (
      clock : in std_logic;
      reset : in std_logic;
      x_pos, y_pos : out std_logic_vector(9 downto 0);
      direction : out std_logic_vector(1 downto 0);
      rock_x_pos, rock_y_pos : in std_logic_vector(9 downto 0)
   );
end entity tractorMover;

architecture Behavioral of tractorMover is
   signal x, y : unsigned(9 downto 0) := (others => '0');
   signal dir : std_logic_vector(1 downto 0) := "11";  -- Initial direction is 270° (moving right)
   signal move_clock : std_logic;
   signal bypassing_obstacle : boolean := false;
   signal bypass_stage : integer := 0;
   signal start_dir : std_logic;  -- Signal to store the initial direction before bypass
begin
   process(clock, reset)
   begin
      if reset = '1' then
         x <= (others => '0');
         y <= (others => '0');
         dir <= "11";  -- Reset direction to 270°
         bypassing_obstacle <= false;
         bypass_stage <= 0;
         start_dir <= '0';
      elsif rising_edge(clock) then
         if move_clock = '1' then
            if bypassing_obstacle then
               -- Logic to handle bypassing the obstacle
               case bypass_stage is
                  when 1 =>
                     -- Move down to avoid obstacle
                     y <= y + 40;
                     if dir = "11" then
                        start_dir <= '0';
                     else
                        start_dir <= '1';
                     end if; 
                     dir <= "00";  -- Set direction to down
                     bypass_stage <= 2;
                  when 2 =>
                     -- Move right or left past the obstacle
                     if start_dir = '0' then
                        x <= x + 40;  -- Move right
                        dir <= "11";  -- Set direction to right
                     else
                        x <= x - 40;  -- Move left
                        dir <= "01";  -- Set direction to left
                     end if;
                     bypass_stage <= 3;
                  when 3 =>
                     -- Continue moving right or left past the obstacle
                     if start_dir = '0' then
                        x <= x + 40;  -- Move right
                     else
                        x <= x - 40;  -- Move left
                     end if;
                     bypass_stage <= 4;
                  when 4 =>
                     -- Move back up to the original row
                     y <= y - 40;
                     if start_dir = '0' then
                        dir <= "11";  -- Continue moving right
                     else
                        dir <= "01";  -- Continue moving left
                     end if;
                     bypassing_obstacle <= false;
                     bypass_stage <= 0;
                  when others =>
                     bypassing_obstacle <= false;
                     bypass_stage <= 0;
               end case;
            else
               -- Normal movement logic with obstacle avoidance
               case dir is
                  when "11" =>  -- Moving right
                     if x < to_unsigned(600, 10) then
                        -- Check if the next block is the obstacle
                        if (x + 40 = unsigned(rock_x_pos) and y = unsigned(rock_y_pos)) then
                           bypassing_obstacle <= true;
                           bypass_stage <= 1;
                        else
                           x <= x + 40;
                        end if;
                     elsif y < to_unsigned(440, 10) then
                        dir <= "00";  -- Change direction to 0° (down)
                        y <= y + 40;  -- Move down one row
                     else -- Restart the movement
                        x <= (others => '0');
                        y <= (others => '0');
                        dir <= "11";  -- Change direction to 270° (right)
                     end if;
                  when "00" =>  -- Moving down
                     if y < to_unsigned(440, 10) then
                        if x = to_unsigned(600, 10) then
                           dir <= "01";  -- Change direction to 90° (left)
                        else
                           dir <= "11";  -- Change direction to 270° (right)
                        end if;
                     else -- Restart the movement
                        x <= (others => '0');
                        y <= (others => '0');
                        dir <= "11";  -- Change direction to 270° (right)
                     end if;
                  when "01" =>  -- Moving left
                     if x > to_unsigned(0, 10) then
                        -- Check if the next block is the obstacle
                        if (x - 40 = unsigned(rock_x_pos) and y = unsigned(rock_y_pos)) then
                           bypassing_obstacle <= true;
                           bypass_stage <= 1;
                        else
                           x <= x - 40;
                        end if;
                     else
                        dir <= "00";  -- Change direction to 0° (down)
                        y <= y + 40;  -- Move down one row
                     end if;
                  when others =>
                     null;
               end case;
            end if;
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
