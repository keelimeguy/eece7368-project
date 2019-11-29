-- Simulation testbed to see the waveforms when
-- the UART receives one character.
-- Warren Toomey, 2015

library ieee;
use ieee.std_logic_1164.all;

entity uart_rx_test is
end uart_rx_test;

architecture behaviour of  uart_rx_test is
    component UART_RX_CTRL is port(
    	UART_RX:   in std_logic;
        CLK:       in std_logic;
        DATA:      out std_logic_vector (7 downto 0);
        READ_DATA: out std_logic);
    end component;

    signal uart_rx:   std_logic;
    signal clock:     std_logic;
    signal data:      std_logic_vector(7 downto 0);
    signal read_data: std_logic;

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
    uut: UART_RX_CTRL port map (
           UART_RX  => uart_rx,
           CLK => clock,
           DATA => data,
           READ_DATA => read_data
    );

    --- Stimulation process. Send 01011001 to the UART.
    --- Note this is sent LSB first, i.e. 10011010
    --- surrounded by a start and stop bit.
    stim_proc: process
    begin
	uart_rx <= '1';
        wait for clock_period * 5;

	-- Send start bit
	uart_rx <= '0';
	wait for 104167 ns;

	-- Send 1 bit
	uart_rx <= '1';
	wait for 104167 ns;

	-- Send 0 bit
	uart_rx <= '0';
	wait for 104167 ns;

	-- Send 0 bit
	uart_rx <= '0';
	wait for 104167 ns;

	-- Send 1 bit
	uart_rx <= '1';
	wait for 104167 ns;

	-- Send 1 bit
	uart_rx <= '1';
	wait for 104167 ns;

	-- Send 0 bit
	uart_rx <= '0';
	wait for 104167 ns;

	-- Send 1 bit
	uart_rx <= '1';
	wait for 104167 ns;

	-- Send 0 bit
	uart_rx <= '0';
	wait for 104167 ns;

	-- Send stop bit
	-- Send 1 bit
	uart_rx <= '1';
	wait for 104167 ns;

	wait for 100 ms;
        report "uart rx test finished" severity failure;
    end process;
end;
