-- Keelin Becker-Wheeler
-- pwm_generator.vhd

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.pwm_generator_pkg.all;

entity pwm_generator is
    generic (
        chord_size : integer := 1
    );
    port (
        wave_type : in  std_logic; -- 1=sine, 0=square
        playing   : in  std_logic;
        clk       : in  std_logic;
        chord     : in  chord_type(chord_size-1 downto 0);
        volume    : in  std_logic_vector(3 downto 0);
        pwm       : out std_logic
    );
end pwm_generator;

architecture Behavioral of pwm_generator is

    signal valid : std_logic_vector(chord_size-1 downto 0) := (others => '0');
    signal last_chord : chord_type(chord_size-1 downto 0) := (others => (others => '0'));
    signal count : integer := 0;

    ------------------------------------
    -- Sine Wave calculations:
    ------------------------------------
    -- resolution = 14 bits
    -- ram_samples = 4096
    -- f_clk = 100MHZ => t_clk = 10ns

    -- address_step_wait = f_clk / (4096*f_input)
    ------------------------------------

    component lut_sine_mem_addr is
        port (
            freq            : in  std_logic_vector(13 downto 0);
            nine_incr_ticks : out integer
        );
    end component;

    component sine_mem is
        port (
            addr : in  std_logic_vector(11 downto 0);
            data : out std_logic_vector(3 downto 0);
            clk  : in  std_logic
        );
    end component;

    type addr_arr_type is array(chord_size-1 downto 0) of std_logic_vector(11 downto 0);
    signal sinemem_addr : addr_arr_type;
    signal next_sinemem_addr : addr_arr_type;
    type half_byte_arr_type is array(chord_size-1 downto 0) of std_logic_vector(3 downto 0);
    signal sine : half_byte_arr_type;
    signal sine_count : integer := 0;
    signal sine_pwm_arr : std_logic_vector(chord_size-1 downto 0) := (others => '0');

    ------------------------------------
    -- Square Wave calculations:
    ------------------------------------
    -- freq = 1/T  =>  T/2 = 1/(2*freq)
    -- f_clk = 100MHZ => t_clk = 10ns
    -- ticks_per_half_period = T/(2*t_clk)
    ------------------------------------

    component lut_square_ticks is
        port (
            freq              : in  std_logic_vector(13 downto 0);
            half_period_ticks : out integer
        );
    end component;
    signal square_count : integer := 0;
    signal off_flag : std_logic_vector(chord_size-1 downto 0) := (others => '0');
    signal square_pwm_arr : std_logic_vector(chord_size-1 downto 0) := (others => '0');

    type integer_arr_type is array(chord_size-1 downto 0) of integer;
    signal sine_target_count : integer_arr_type;
    signal square_target_count : integer_arr_type;
    signal sine_wave_count : integer_arr_type;
    signal square_wave_count : integer_arr_type;

begin
    sineWaveGEN_LOOP : for I in 0 to chord_size-1 generate

        sinemem : sine_mem
            port map (
                addr => sinemem_addr(I),
                data => sine(I),
                clk => clk
            );

        sinememaddr_lut : lut_sine_mem_addr
            port map (
                freq => chord(I),
                nine_incr_ticks => sine_target_count(I)
            );

        process(clk, chord(I))
        begin
            -- On new freq need to reset waveform also
            if (chord(I) = "00000000000000") or (chord(I) /= last_chord(I)) then
                sinemem_addr(I) <= X"000";
            elsif (clk'event and clk = '1') then
                if (sine_wave_count(I) < sine_target_count(I)-1) then
                    sine_wave_count(I) <= sine_wave_count(I)+1;
                else
                    sinemem_addr(I) <= std_logic_vector(to_unsigned(to_integer(unsigned(sinemem_addr(I))) + 9, sinemem_addr(I)'length));
                    sine_wave_count(I) <= 0;
                end if;
            end if;
        end process;

        sine_pwm_arr(I) <= '1' when (sine_count < to_integer(unsigned(sine(I))) * to_integer(unsigned(volume))) else '0';

    end generate;

    squareWaveGEN_LOOP : for I in 0 to chord_size-1 generate

        square_ticks_LUT : lut_square_ticks
            port map (
                freq => chord(I),
                half_period_ticks => square_target_count(I)
            );

        process(clk, chord(I))
        begin
            -- On new freq need to reset waveform also
            if (chord(I) = "00000000000000") then
                off_flag(I) <= '0';
            elsif (clk'event and clk = '1') then
                if (square_wave_count(I) < square_target_count(I)-1) then
                    square_wave_count(I) <= square_wave_count(I)+1;
                else
                    square_wave_count(I) <= 0;
                    off_flag(I) <= not off_flag(I);
                end if;
            end if;
        end process;

        square_pwm_arr(I) <= '1' when off_flag(I) = '1' and to_integer(unsigned(volume)) > square_count else '0';

    end generate;

    chordGEN_LOOP : for I in 0 to chord_size-1 generate
        process(chord(I))
        begin
            if (chord(I) = "00000000000000") then
                valid(I) <= '0';
            elsif (chord(I) /= last_chord(I)) then
                valid(I) <= '1';
            end if;
            last_chord(I) <= chord(I);
        end process;
    end generate;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (count < count_ones(valid)-1) then
                count <= count+1;
            else
                count <= 0;
            end if;

            -- Volume is 4 bits -> 15
            if (square_count < 14) then
                square_count <= square_count+1;
            else
                square_count <= 0;
            end if;

            -- Volume&Sine is max 15*15 -> 225
            if (sine_count < 224) then
                sine_count <= sine_count+1;
            else
                sine_count <= 0;
            end if;
        end if;
    end process;

    pwm <= '1' when (playing = '1') and ((count_ones(square_pwm_arr) > count and wave_type = '0') or (count_ones(sine_pwm_arr) > count and wave_type = '1')) else '0';

end Behavioral;
