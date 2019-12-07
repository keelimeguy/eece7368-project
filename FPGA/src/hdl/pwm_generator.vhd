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

    type integer_arr_type is array(chord_size-1 downto 0) of integer;
    signal target_count : integer_arr_type;
    signal wave_count : integer_arr_type;

    signal duty_count : integer := 0;

    signal off_flag : std_logic_vector(chord_size-1 downto 0) := (others => '0');
    signal pwm_arr : std_logic_vector(chord_size-1 downto 0) := (others => '0');
    signal valid : std_logic_vector(chord_size-1 downto 0) := (others => '0');
    signal last_chord : chord_type(chord_size-1 downto 0) := (others => (others => '0'));
    signal count : integer := 0;

begin
    sineWaveGEN : if (wave_type = 1) generate
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
                    nine_incr_ticks => target_count(I)
                );

            process(clk, chord(I))
            begin
                -- On new freq need to reset waveform also
                if (chord(I) = "00000000000000") then
                    valid(I) <= '0';
                    sinemem_addr(I) <= X"000";
                elsif (chord(I) /= last_chord(I)) then
                    valid(I) <= '1';
                    sinemem_addr(I) <= X"000";
                elsif (clk'event and clk = '1') then
                    if (wave_count(I) < target_count(I)-1) then
                        wave_count(I) <= wave_count(I)+1;
                    else
                        sinemem_addr(I) <= std_logic_vector(to_unsigned(to_integer(unsigned(sinemem_addr(I))) + 9, sinemem_addr(I)'length));
                        wave_count(I) <= 0;
                    end if;
                    valid(I) <= '1';
                end if;
            end process;

            pwm_arr(I) <= '1' when (duty_count < to_integer(unsigned(sine(I))) * to_integer(unsigned(volume))) else '0';

        end generate;

        process(clk)
        begin
            if (clk'event and clk = '1') then
                if (count < count_ones(valid)-1) then
                    count <= count+1;
                else
                    count <= 0;
                end if;

                -- Volume&Sine is max 15*15 -> 225
                if (duty_count < 224) then
                    duty_count <= duty_count+1;
                else
                    duty_count <= 0;
                end if;
            end if;
        end process;

        pwm <= '1' when (count_ones(pwm_arr) > count) and (playing = '1') else '0';
        last_chord <= chord;

    end generate;

    squareWaveGEN : if (wave_type = 0) generate
        squareWaveGEN_LOOP : for I in 0 to chord_size-1 generate

            square_ticks_LUT : lut_square_ticks
                port map (
                    freq => chord(I),
                    half_period_ticks => target_count(I)
                );

            process(clk, chord(I))
            begin
                -- On new freq need to reset waveform also
                if (chord(I) = "00000000000000") then
                    valid(I) <= '0';
                    off_flag(I) <= '0';
                elsif (chord(I) /= last_chord(I)) then
                    valid(I) <= '1';
                elsif (clk'event and clk = '1') then
                    if (wave_count(I) < target_count(I)-1) then
                        wave_count(I) <= wave_count(I)+1;
                    else
                        wave_count(I) <= 0;
                        off_flag(I) <= not off_flag(I);
                    end if;
                    valid(I) <= '1';
                end if;
            end process;

            pwm_arr(I) <= '1' when off_flag(I) = '1' and to_integer(unsigned(volume))>duty_count else '0';

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
                if (duty_count < 14) then
                    duty_count <= duty_count+1;
                else
                    duty_count <= 0;
                end if;
            end if;
        end process;

        pwm <= '1' when (count_ones(pwm_arr) > count) and (playing = '1') else '0';
        last_chord <= chord;

    end generate;

end Behavioral;
