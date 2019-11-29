-- Keelin Becker-Wheeler
-- pwm_generator_pkg.vhd

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

package pwm_generator_pkg is
    type note_type is array (natural range <>) of std_logic_vector(7 downto 0);
    type chord_type is array (natural range <>) of std_logic_vector(13 downto 0);
    function count_ones(vector : std_logic_vector) return natural;
end package;

package body pwm_generator_pkg is
    function count_ones(vector : std_logic_vector) return natural is
        variable ones : natural := 0;
    begin
        for i in vector'range loop
            if (vector(i) = '1') then
                ones := ones + 1;
            end if;
        end loop;
        return ones;
    end function count_ones;
end pwm_generator_pkg;
