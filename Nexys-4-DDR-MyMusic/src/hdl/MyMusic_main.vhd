library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--The IEEE.std_logic_unsigned contains definitions that allow
--std_logic_vector types to be used with the + operator to instantiate a
--counter.
use IEEE.std_logic_unsigned.all;

entity MyMusic_main is
    Port ( SW           : in  STD_LOGIC_VECTOR (15 downto 0);
           BTN          : in  STD_LOGIC_VECTOR (4 downto 0);
           CLK          : in  STD_LOGIC;
           LED          : out  STD_LOGIC_VECTOR (15 downto 0);
           SSEG_CA      : out  STD_LOGIC_VECTOR (7 downto 0);
           SSEG_AN      : out  STD_LOGIC_VECTOR (7 downto 0);
           UART_RXD:   in std_logic;
           UART_TXD     : out  STD_LOGIC;
           RGB1_Red     : out  STD_LOGIC;
           RGB1_Green   : out  STD_LOGIC;
           RGB1_Blue    : out  STD_LOGIC;
           RGB2_Red     : out  STD_LOGIC;
           RGB2_Green   : out  STD_LOGIC;
           RGB2_Blue    : out  STD_LOGIC;
           micClk       : out STD_LOGIC;
           micLRSel     : out STD_LOGIC;
           micData      : in STD_LOGIC;
           ampPWM       : out STD_LOGIC;
           ampSD        : out STD_LOGIC
              );
end MyMusic_main;

architecture Behavioral of MyMusic_main is

component UART_RX_CTRL
    port (UART_RX:    in  STD_LOGIC;
          CLK:        in  STD_LOGIC;
          DATA:       out STD_LOGIC_VECTOR (7 downto 0);
          READ_DATA:  out STD_LOGIC;
          RESET_READ: in  STD_LOGIC
    );
end component;

component UART_TX_CTRL
Port(
    SEND : in std_logic;
    DATA : in std_logic_vector(7 downto 0);
    CLK : in std_logic;
    READY : out std_logic;
    UART_TX : out std_logic
    );
end component;

component hex_7seg is
    port (CLK:          in std_logic;
          DATA:         in std_logic_vector(31 downto 0);
          DIGIT_ENABLE: in std_logic_vector(7 downto 0);
          SSEG_CA:      out std_logic_vector(7 downto 0);
          SSEG_AN:      out std_logic_vector(7 downto 0)
    );
end component;

component debouncer
Generic(
        DEBNC_CLOCKS : integer;
        PORT_WIDTH : integer);
Port(
        SIGNAL_I : in std_logic_vector(4 downto 0);
        CLK_I : in std_logic;
        SIGNAL_O : out std_logic_vector(4 downto 0)
        );
end component;

component RGB_controller
Port(
    GCLK            : in std_logic;
    RGB_LED_1_O : out std_logic_vector(2 downto 0);
    RGB_LED_2_O : out std_logic_vector(2 downto 0)
    );
end component;

--Used to determine when a button press has occured
signal btnReg : std_logic_vector (3 downto 0) := "0000";
signal btnDetect : std_logic;

--Debounced btn signals used to prevent single button presses
--from being interpreted as multiple button presses.
signal btnDeBnc : std_logic_vector(4 downto 0);

signal clk_cntr_reg : std_logic_vector (4 downto 0) := (others=>'0');

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
signal last_four_chars: std_logic_vector(31 downto 0) := (others => '0');

begin

----------------------------------------------------------
------                LED Control                  -------
----------------------------------------------------------

with BTN(4) select
    LED <= SW           when '0',
             "0000000000000000" when others;

----------------------------------------------------------
------              Button Control                 -------
----------------------------------------------------------
--Buttons are debounced and their rising edges are detected
--to trigger UART messages


--Debounces btn signals
Inst_btn_debounce: debouncer
    generic map(
        DEBNC_CLOCKS => (2**16),
        PORT_WIDTH => 5)
    port map(
        SIGNAL_I => BTN,
        CLK_I => CLK,
        SIGNAL_O => btnDeBnc
    );

--Registers the debounced button signals, for edge detection.
btn_reg_process : process (CLK)
begin
    if (rising_edge(CLK)) then
        btnReg <= btnDeBnc(3 downto 0);
    end if;
end process;

--btnDetect goes high for a single clock cycle when a btn press is
--detected. This triggers a UART message to begin being sent.
btnDetect <= '1' when ((btnReg(0)='0' and btnDeBnc(0)='1') or
                                (btnReg(1)='0' and btnDeBnc(1)='1') or
                                (btnReg(2)='0' and btnDeBnc(2)='1') or
                                (btnReg(3)='0' and btnDeBnc(3)='1')  ) else
                  '0';

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
        DATA => last_four_chars,
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
------            RGB LED Control                  -------
----------------------------------------------------------

RGB_Core: RGB_controller port map(
    GCLK => CLK,
    RGB_LED_1_O(0) => RGB1_Green,
    RGB_LED_1_O(1) => RGB1_Blue,
    RGB_LED_1_O(2) => RGB1_Red,
    RGB_LED_2_O(0) => RGB2_Green,
    RGB_LED_2_O(1) => RGB2_Blue,
    RGB_LED_2_O(2) => RGB2_Red
    );


----------------------------------------------------------
------              MIC Control                    -------
----------------------------------------------------------
--PDM data from the microphone is registered on the rising
--edge of every micClk, converting it to PWM. The PWM data
--is then connected to the mono audio out circuit, causing
--the sound captured by the microphone to be played over
--the audio out port.

process(CLK)
begin
  if (rising_edge(CLK)) then
    clk_cntr_reg <= clk_cntr_reg + 1;
  end if;
end process;

--micClk = 100MHz / 32 = 3.125 MHz
micClk <= clk_cntr_reg(4);

process(CLK)
begin
  if (rising_edge(CLK)) then
    if (clk_cntr_reg = "01111") then
      pwm_val_reg <= micData;
    end if;
  end if;
end process;

micLRSel <= '0';
ampPWM <= pwm_val_reg;
ampSD <= '1';

end Behavioral;
