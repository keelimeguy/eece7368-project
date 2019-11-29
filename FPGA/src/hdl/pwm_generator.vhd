-- Keelin Becker-Wheeler
-- pwm_generator.vhd

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.pwm_generator_pkg.all;

entity pwm_generator is
    generic (
        wave_type  : integer := 0;
        chord_size : integer := 1
    );
    port (
        playing : in  std_logic;
        clk     : in  std_logic;
        chord   : in  chord_type(chord_size-1 downto 0);
        volume  : in  std_logic_vector(3 downto 0);
        pwm     : out std_logic
    );
end pwm_generator;

architecture Behavioral of pwm_generator is
    ------------------------------------
    -- Square Wave calculations:
    ------------------------------------
    -- freq = 1/T  =>  T/2 = 1/(2*freq)
    -- f_clk = 100MHZ => t_clk = 10ns
    -- ticks_per_half_period = T/(2*t_clk)
    ------------------------------------

    type integer_arr_type is array(chord_size-1 downto 0) of integer;
    signal last_chord : chord_type(chord_size-1 downto 0);
    signal target_count : integer_arr_type;
    signal square_count : integer_arr_type;
    signal duty_count : integer;
    signal off_flag : std_logic_vector(chord_size-1 downto 0);
    signal pwm_arr : std_logic_vector(chord_size-1 downto 0);
    signal count : integer := 0;

begin
    squareWaveGEN : if (wave_type = 0) generate
        squareWaveGEN_LOOP : for I in 0 to chord_size-1 generate

            square_ticks_LUT : entity work.lut_square_ticks
                port map (
                    freq => chord(I),
                    half_period_ticks => target_count(I)
                );

            process(clk)
            begin
                last_chord(I) <= chord(I);
                -- On new freq need to reset waveform also
                if (chord(I) /= last_chord(I) or chord(I) = "00000000000000") then
                    square_count(I) <= 0;
                    off_flag(I) <= '0';
                elsif (clk'event and clk = '1') then
                    if (square_count(I) < target_count(I)) then
                        square_count(I) <= square_count(I)+1;
                        off_flag(I) <= off_flag(I);

                    else
                        square_count(I) <= 0;
                        off_flag(I) <= not off_flag(I);
                    end if;
                end if;
            end process;

            pwm_arr(I) <= '1' when off_flag(I) = '0' and to_integer(unsigned(volume))>duty_count else '0';

        end generate;

        process(clk)
        begin
            if (clk'event and clk = '1') then
                if (count < chord_size-1) then
                    count <= count+1;
                else
                    count <= 0;
                end if;

                -- Volume is 4 bits -> 15
                if (duty_count < 14) then
                    duty_count <= duty_count+1;
                else
                    duty_count <= 0;
                end if;
            end if;
        end process;

        pwm <= '1' when count_ones(pwm_arr) > count and playing = '1' else '0';

    end generate;

end Behavioral;
