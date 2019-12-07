-- Keelin Becker-Wheeler
-- sine_mem.vhd

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library unisim;
use unisim.vcomponents.all;

entity sine_mem is
    port (
        addr : in  std_logic_vector(11 downto 0);
        data : out std_logic_vector(3 downto 0);
        clk  : in  std_logic
    );
end sine_mem;

architecture Behavioral of sine_mem is
begin
    RAMB16_S4_inst : RAMB16_S4
        generic map (
            INIT_00 => X"8888888888888888888888888888888888888888888888888888888888888888",
            INIT_01 => X"9999999999999999999999999999999999999999888888888888888888888888",
            INIT_02 => X"AAAAAAAAAAAAAAAA999999999999999999999999999999999999999999999999",
            INIT_03 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
            INIT_04 => X"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBAAAAAAAAAAAAA",
            INIT_05 => X"CCCCCCCCCCCCCCCCCBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
            INIT_06 => X"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC",
            INIT_07 => X"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCCCCCCCCCCCCC",
            INIT_08 => X"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
            INIT_09 => X"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
            INIT_0A => X"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            INIT_0B => X"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            INIT_0C => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEEE",
            INIT_0D => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0E => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_0F => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_10 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_11 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_12 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_13 => X"EEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
            INIT_14 => X"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            INIT_15 => X"EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            INIT_16 => X"DDDDDDDDDDDDDDDDDDDDDDDDDDDDEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",
            INIT_17 => X"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
            INIT_18 => X"CCCCCCCCCCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
            INIT_19 => X"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC",
            INIT_1A => X"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCC",
            INIT_1B => X"AAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
            INIT_1C => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
            INIT_1D => X"99999999999999999999999999999999999999999999999AAAAAAAAAAAAAAAAA",
            INIT_1E => X"8888888888888888888888899999999999999999999999999999999999999999",
            INIT_1F => X"8888888888888888888888888888888888888888888888888888888888888888",
            INIT_20 => X"7777777777777777777777777777777777777777777777777777777777777778",
            INIT_21 => X"6666666666666666666666666666666666666666777777777777777777777777",
            INIT_22 => X"5555555555555555666666666666666666666666666666666666666666666666",
            INIT_23 => X"5555555555555555555555555555555555555555555555555555555555555555",
            INIT_24 => X"4444444444444444444444444444444444444444444444444445555555555555",
            INIT_25 => X"3333333333333333344444444444444444444444444444444444444444444444",
            INIT_26 => X"3333333333333333333333333333333333333333333333333333333333333333",
            INIT_27 => X"2222222222222222222222222222222222223333333333333333333333333333",
            INIT_28 => X"2222222222222222222222222222222222222222222222222222222222222222",
            INIT_29 => X"1111111111111111111111111111111111122222222222222222222222222222",
            INIT_2A => X"1111111111111111111111111111111111111111111111111111111111111111",
            INIT_2B => X"1111111111111111111111111111111111111111111111111111111111111111",
            INIT_2C => X"0000000000000000000000000000000000000000000000011111111111111111",
            INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_33 => X"1111111111111111000000000000000000000000000000000000000000000000",
            INIT_34 => X"1111111111111111111111111111111111111111111111111111111111111111",
            INIT_35 => X"1111111111111111111111111111111111111111111111111111111111111111",
            INIT_36 => X"2222222222222222222222222222111111111111111111111111111111111111",
            INIT_37 => X"2222222222222222222222222222222222222222222222222222222222222222",
            INIT_38 => X"3333333333333333333333333332222222222222222222222222222222222222",
            INIT_39 => X"3333333333333333333333333333333333333333333333333333333333333333",
            INIT_3A => X"4444444444444444444444444444444444444444444444333333333333333333",
            INIT_3B => X"5555555555554444444444444444444444444444444444444444444444444444",
            INIT_3C => X"5555555555555555555555555555555555555555555555555555555555555555",
            INIT_3D => X"6666666666666666666666666666666666666666666666655555555555555555",
            INIT_3E => X"7777777777777777777777766666666666666666666666666666666666666666",
            INIT_3F => X"7777777777777777777777777777777777777777777777777777777777777777"
        )
        port map (
            DO => data,
            DI => "0000",
            ADDR => addr,
            CLK => clk,
            EN => '1',
            SSR => '0',
            WE => '0'
        );

end Behavioral;

