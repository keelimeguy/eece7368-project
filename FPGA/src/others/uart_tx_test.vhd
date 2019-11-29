-- Simulation testbed to see the waveforms when
-- the UART sends one character.
-- Warren Toomey, 2015

library ieee;
use ieee.std_logic_1164.all;

entity uart_tx_test is
end uart_tx_test;

architecture behaviour of  uart_tx_test is
    component UART_TX_CTRL is port(
    	   SEND : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           READY : out  STD_LOGIC;
           UART_TX : out  STD_LOGIC);
    end component;

    signal send:    std_logic;
    signal data:    std_logic_vector(7 downto 0);
    signal clock:   std_logic;
    signal ready:   std_logic;
    signal uart_tx: std_logic;

    -- Clock period definitions
    constant clock_period : time := 10 ns;	-- 100 MHz

begin
    -- Clock process definitions: clock with 50% duty cycle is generated here.
    clock_process: process
    begin
        clock <= '0';
        wait for clock_period/2;  --for 5 ns signal is '0'.
        clock <= '1';
        wait for clock_period/2;  --for next 5 ns signal is '1'.
    end process;

    -- Unit under test port map
    uut: UART_TX_CTRL port map (
	   SEND => send,
           DATA => data,
           CLK  => clock,
           READY => ready,
           UART_TX => uart_tx
      );

    --- Stimulation process
    stim_proc: process
    begin
        -- Try to send 01011001
        wait for clock_period;
	data <= "01011001";
        send <= '1';
        wait for clock_period;

	-- Turn off the send line
        send <= '0';
        wait for 150 ms;

        report "uart tx test finished" severity failure;
    end process;
end;
