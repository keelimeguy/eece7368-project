-- Keelin Becker-Wheeler
-- MyMusic_main.vhd

library ieee;
use ieee.std_logic_1164.ALL;

--The ieee.std_logic_unsigned contains definitions that allow
--std_logic_vectortypes to be used with the + operator to instantiate a
--counter.
use ieee.std_logic_unsigned.all;
use work.pwm_generator_pkg.all;

entity MyMusic_main is
    generic (
        MAX_CHORD_SIZE : integer := 3;
        WAVE_TYPE      : integer := 0 -- 1=sine, 0=square
    );
    port (
        CLK      : in  std_logic;
        SSEG_CA  : out std_logic_vector(7 downto 0);
        SSEG_AN  : out std_logic_vector(7 downto 0);
        UART_RXD : in  std_logic;
        UART_TXD : out std_logic;
        ampPWM   : out std_logic;
        ampSD    : out std_logic
    );
end MyMusic_main;

architecture Behavioral of MyMusic_main is

    component pwm_generator is
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
    end component;

    component lut_note_freq
        port (
            note_value : in  std_logic_vector(7 downto 0);
            freq_value : out std_logic_vector(13 downto 0)
        );
    end component;

    component UART_RX_CTRL
        port (
            UART_RX    : in  std_logic;
            CLK        : in  std_logic;
            DATA       : out std_logic_vector(7 downto 0);
            READ_DATA  : out std_logic;
            RESET_READ : in  std_logic
        );
    end component;

    component UART_TX_CTRL
        port(
            SEND    : in  std_logic;
            DATA    : in  std_logic_vector(7 downto 0);
            CLK     : in  std_logic;
            READY   : out std_logic;
            UART_TX : out std_logic
        );
    end component;

    component hex_7seg is
        port (
            CLK          : in std_logic;
            DATA         : in std_logic_vector(31 downto 0);
            DIGIT_ENABLE : in std_logic_vector(7 downto 0);
            SSEG_CA      : out std_logic_vector(7 downto 0);
            SSEG_AN      : out std_logic_vector(7 downto 0)
        );
    end component;

    signal pwm_val_reg : std_logic := '0';

    -- Signals to hold the data in from and out to the UART
    signal uart_data_in: std_logic_vector(7 downto 0);
    signal uart_data_out: std_logic_vector(7 downto 0);

    -- UART receive signals: data is available, and
    -- a line to tell the UART that we have absorbed the data
    signal data_available: std_logic;
    signal reset_read: std_logic := '0';

    -- UART transmit signals: the component is ready to send
    -- a character, and a line to tell it to send the data now
    signal tx_is_ready: std_logic;
    signal send_data: std_logic := '0';

    -- Once the READ_DATA line goes high, we strobe the send_data
    -- line and move to the SENT state. Then we move into the
    -- WAITING state until READ_DATA drops, and we return to READY.

    type SEND_STATE_TYPE is (READY, SENT, WAITING);
    signal SEND_STATE : SEND_STATE_TYPE := READY;

    -- Diagnostic: store the last four characters here
    signal last_four_chars : std_logic_vector(31 downto 0) := (others => '0');

    signal freq_value : chord_type(MAX_CHORD_SIZE-1 downto 0);
    signal note_value : note_type(MAX_CHORD_SIZE-1 downto 0);
    signal volume : std_logic_vector(3 downto 0) := "1000";
    signal playing : std_logic := '0';

    signal chord_number : integer range 0 to MAX_CHORD_SIZE-1;

begin

    ----------------------------------------------------------
    ------              UART Control                   -------
    ----------------------------------------------------------

    -- Instantiation of the UART receive component
    inst_UART_RX_CTRL: UART_RX_CTRL
        port map(
            UART_RX => UART_RXD,
            CLK => CLK,
            DATA => uart_data_in,
            READ_DATA => data_available,
            RESET_READ => reset_read
        );

    -- Instantiation of the UART transmit component
    inst_UART_TX_CTRL: UART_TX_CTRL
        port map(
            SEND => send_data,
            CLK => CLK,
            DATA => uart_data_out,
            READY => tx_is_ready,
            UART_TX => UART_TXD
        );

    -- Instantiation of the 7-segment hex digit component
    inst_hex: hex_7seg
        port map(
            CLK => CLK,
            DATA => note_value(0)&note_value(1)&note_value(2)&volume&"000"&playing,
            DIGIT_ENABLE => "11111111",
            SSEG_CA => SSEG_CA,
            SSEG_AN => SSEG_AN
        );

    uart_receive: process(CLK, SEND_STATE, data_available)
    begin
        if (rising_edge(CLK)) then
            case SEND_STATE is
                when READY =>
                    -- We are waiting for data to arrive.
                    -- If data is available and the transmitter is ready
                    if (data_available = '1' and tx_is_ready = '1') then
                        -- Copy the data read in to the transmitter
                        -- and initiate the transmission
                        uart_data_out <= uart_data_in;
                        last_four_chars(31 downto 8) <= last_four_chars(23 downto 0);
                        last_four_chars(7 downto 0) <= uart_data_in;
                        send_data <= '1';
                        SEND_STATE <= SENT;

                        case uart_data_in(7 downto 4) is
                            when "1000" =>
                                playing <= uart_data_in(0);

                            when "1010" =>
                                volume <= uart_data_in(3 downto 0);

                            when others =>
                                note_value(chord_number) <= uart_data_in;

                                if chord_number = MAX_CHORD_SIZE-1 then
                                    chord_number <= 0;
                                else
                                    chord_number <= chord_number + 1;
                                end if;
                        end case;

                    end if;

                when SENT =>
                    -- On the next clock cycle, tell the UART receiver
                    -- that we read the data, and reset the transmit initiation
                    reset_read <= '1';
                    send_data <= '0';
                    SEND_STATE <= WAITING;

                when WAITING =>
                    -- Once the receiver knows that we have absorbed the
                    -- data, lower the line that we used to tell it so.
                    -- We are now back in the READY state, waiting for the
                    -- next character to arrive on the receiver.
                    if (data_available = '0') then
                        reset_read <= '0';
                        SEND_STATE <= READY;
                    end if;
            end case;
        end if;
    end process;


    ----------------------------------------------------------
    ------              Audio Control                    -------
    ----------------------------------------------------------

    freqLutGEN_LOOP : for I in 0 to MAX_CHORD_SIZE-1 generate
    freq_LUT: lut_note_freq
        port map (
            note_value => note_value(I),
            freq_value => freq_value(I)
        );
    end generate;

    PWM_Gen: pwm_generator
        generic map(
            wave_type => WAVE_TYPE,
            chord_size => MAX_CHORD_SIZE
        )
        port map (
            playing => playing,
            clk => CLK,
            chord => freq_value,
            volume => volume,
            pwm => pwm_val_reg
        );

    ampPWM <= '0' when pwm_val_reg='0' else 'Z';
    ampSD <= '1';

end Behavioral;
