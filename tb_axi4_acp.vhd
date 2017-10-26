library STD;
use std.textio.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity tb_axi4_acp is
end tb_axi4_acp;

architecture Behavioral of tb_axi4_acp is
    constant clock_period           : time := 20 ns;

    signal test_done                : boolean;
    signal read_test_done           : boolean := false;
    signal write_test_done          : boolean := true;

    signal clk                      : std_logic                         := '1';
    signal rst                      : std_logic                         := '1';
    -- The signals for axi4_acp_1
    signal AXI_ACP_1_write_addr     : std_logic_vector(31 downto 0)     := (others => '0');
    signal AXI_ACP_1_write_data     : std_logic_vector(31 downto 0)     := (others => '0');
    signal AXI_ACP_1_read_addr      : std_logic_vector(31 downto 0)     := (others => '0');
    signal AXI_ACP_1_read_data      : std_logic_vector(31 downto 0);
    signal AXI_ACP_1_write_start    : std_logic                         := '0';
    signal AXI_ACP_1_write_complete : std_logic;
    signal AXI_ACP_1_write_result   : std_logic_vector(1 downto 0);
    signal AXI_ACP_1_read_start     : std_logic                         := '0';
    signal AXI_ACP_1_read_complete  : std_logic;
    signal AXI_ACP_1_read_result    : std_logic_vector(1 downto 0);
    signal AXI_ACP_1_ACLK           : std_logic;
    signal AXI_ACP_1_AWID           : std_logic_vector(2 DOWNTO 0);
    signal AXI_ACP_1_AWADDR         : std_logic_vector(31 downto 0);
    signal AXI_ACP_1_AWLEN          : std_logic_vector(3 downto 0);
    signal AXI_ACP_1_AWSIZE         : std_logic_vector(2 downto 0);
    signal AXI_ACP_1_AWBURST        : std_logic_vector(1 downto 0);
    signal AXI_ACP_1_AWLOCK         : std_logic_vector(1 downto 0);
    signal AXI_ACP_1_AWCACHE        : std_logic_vector(3 downto 0);
    signal AXI_ACP_1_AWPROT         : std_logic_vector(2 downto 0);
    signal AXI_ACP_1_AWQOS          : std_logic_vector(3 downto 0);
    signal AXI_ACP_1_AWUSER         : std_logic_vector(4 downto 0);
    signal AXI_ACP_1_AWVALID        : std_logic;
    signal AXI_ACP_1_AWREADY        : std_logic                         := '0';
    signal AXI_ACP_1_WID            : std_logic_vector(2 downto 0);
    signal AXI_ACP_1_WDATA          : std_logic_vector(63 downto 0);
    signal AXI_ACP_1_WSTRB          : std_logic_vector(7 downto 0);
    signal AXI_ACP_1_WLAST          : std_logic;
    signal AXI_ACP_1_WVALID         : std_logic;
    signal AXI_ACP_1_WREADY         : std_logic                         := '0';
    signal AXI_ACP_1_BID            : std_logic_vector(2 downto 0)      := (others => '0');
    signal AXI_ACP_1_BRESP          : std_logic_vector(1 downto 0)      := (others => '0');
    signal AXI_ACP_1_BVALID         : std_logic                         := '0';
    signal AXI_ACP_1_BREADY         : std_logic;
    signal AXI_ACP_1_ARID           : std_logic_vector(2 downto 0);
    signal AXI_ACP_1_ARADDR         : std_logic_vector(31 downto 0);
    signal AXI_ACP_1_ARLEN          : std_logic_vector(3 downto 0);
    signal AXI_ACP_1_ARSIZE         : std_logic_vector(2 downto 0);
    signal AXI_ACP_1_ARBURST        : std_logic_vector(1 downto 0);
    signal AXI_ACP_1_ARLOCK         : std_logic_vector(1 downto 0);
    signal AXI_ACP_1_ARCACHE        : std_logic_vector(3 downto 0);
    signal AXI_ACP_1_ARPROT         : std_logic_vector(2 downto 0);
    signal AXI_ACP_1_ARQOS          : std_logic_vector(3 downto 0);
    signal AXI_ACP_1_ARUSER         : std_logic_vector(4 downto 0);
    signal AXI_ACP_1_ARVALID        : std_logic;
    signal AXI_ACP_1_ARREADY        : std_logic                         := '0';
    signal AXI_ACP_1_RID            : std_logic_vector(2 downto 0)      := (others => '0');
    signal AXI_ACP_1_RDATA          : std_logic_vector(63 downto 0)     := (others => '0');
    signal AXI_ACP_1_RRESP          : std_logic_vector(1 downto 0)      := (others => '0');
    signal AXI_ACP_1_RLAST          : std_logic                         := '0';
    signal AXI_ACP_1_RVALID         : std_logic                         := '0';
    signal AXI_ACP_1_RREADY         : std_logic;
begin
    axi4_acp_1 : entity work.axi4_acp_master
    port map (
        clk                 => clk,
        rst                 => rst,
        write_addr          => AXI_ACP_1_write_addr,
        write_data          => AXI_ACP_1_write_data,
        read_addr           => AXI_ACP_1_read_addr,
        read_data           => AXI_ACP_1_read_data,
        write_start         => AXI_ACP_1_write_start,
        write_complete      => AXI_ACP_1_write_complete,
        write_result        => AXI_ACP_1_write_result,
        read_start          => AXI_ACP_1_read_start,
        read_complete       => AXI_ACP_1_read_complete,
        read_result         => AXI_ACP_1_read_result,
        M_AXI_ACP_ACLK      => AXI_ACP_1_ACLK,
        M_AXI_ACP_AWID      => AXI_ACP_1_AWID,
        M_AXI_ACP_AWADDR    => AXI_ACP_1_AWADDR,
        M_AXI_ACP_AWLEN     => AXI_ACP_1_AWLEN,
        M_AXI_ACP_AWSIZE    => AXI_ACP_1_AWSIZE,
        M_AXI_ACP_AWBURST   => AXI_ACP_1_AWBURST,
        M_AXI_ACP_AWLOCK    => AXI_ACP_1_AWLOCK,
        M_AXI_ACP_AWCACHE   => AXI_ACP_1_AWCACHE,
        M_AXI_ACP_AWPROT    => AXI_ACP_1_AWPROT,
        M_AXI_ACP_AWQOS     => AXI_ACP_1_AWQOS,
        M_AXI_ACP_AWUSER    => AXI_ACP_1_AWUSER,
        M_AXI_ACP_AWVALID   => AXI_ACP_1_AWVALID,
        M_AXI_ACP_AWREADY   => AXI_ACP_1_AWREADY,
        M_AXI_ACP_WID       => AXI_ACP_1_WID,
        M_AXI_ACP_WDATA     => AXI_ACP_1_WDATA,
        M_AXI_ACP_WSTRB     => AXI_ACP_1_WSTRB,
        M_AXI_ACP_WLAST     => AXI_ACP_1_WLAST,
        M_AXI_ACP_WVALID    => AXI_ACP_1_WVALID,
        M_AXI_ACP_WREADY    => AXI_ACP_1_WREADY,
        M_AXI_ACP_BID       => AXI_ACP_1_BID,
        M_AXI_ACP_BRESP     => AXI_ACP_1_BRESP,
        M_AXI_ACP_BVALID    => AXI_ACP_1_BVALID,
        M_AXI_ACP_BREADY    => AXI_ACP_1_BREADY,
        M_AXI_ACP_ARID      => AXI_ACP_1_ARID,
        M_AXI_ACP_ARADDR    => AXI_ACP_1_ARADDR,
        M_AXI_ACP_ARLEN     => AXI_ACP_1_ARLEN,
        M_AXI_ACP_ARSIZE    => AXI_ACP_1_ARSIZE,
        M_AXI_ACP_ARBURST   => AXI_ACP_1_ARBURST,
        M_AXI_ACP_ARLOCK    => AXI_ACP_1_ARLOCK,
        M_AXI_ACP_ARCACHE   => AXI_ACP_1_ARCACHE,
        M_AXI_ACP_ARPROT    => AXI_ACP_1_ARPROT,
        M_AXI_ACP_ARQOS     => AXI_ACP_1_ARQOS,
        M_AXI_ACP_ARUSER    => AXI_ACP_1_ARUSER,
        M_AXI_ACP_ARVALID   => AXI_ACP_1_ARVALID,
        M_AXI_ACP_ARREADY   => AXI_ACP_1_ARREADY,
        M_AXI_ACP_RID       => AXI_ACP_1_RID,
        M_AXI_ACP_RDATA     => AXI_ACP_1_RDATA,
        M_AXI_ACP_RRESP     => AXI_ACP_1_RRESP,
        M_AXI_ACP_RLAST     => AXI_ACP_1_RLAST,
        M_AXI_ACP_RVALID    => AXI_ACP_1_RVALID,
        M_AXI_ACP_RREADY    => AXI_ACP_1_RREADY
    );

    test_done <= read_test_done and write_test_done;

    -- Clk generator, simply switch flanks every half period
    clock_gen : process
    begin
        if not (test_done) then
            -- 1/2 duty cycle
            clk <= not clk;
            wait for clock_period/2;
        else
            wait;
        end if;
    end process;

    common_loop : process
    begin
        wait for 2*clock_period;
        rst <= '0';
        wait;
    end process;

    read_loop : process
        constant read_addr : unsigned(AXI_ACP_1_write_addr'RANGE) := to_unsigned(15, AXI_ACP_1_write_addr'length );
        variable my_line : line;
    begin
        -- Give all inputs sensible defaults
        AXI_ACP_1_read_addr <= (others => '0');
        AXI_ACP_1_read_start <= '0';
        AXI_ACP_1_ARREADY <= '0';
        AXI_ACP_1_RDATA <= (others => '0');
        AXI_ACP_1_RRESP <= (others => '0');
        AXI_ACP_1_RLAST <= '0';
        AXI_ACP_1_RVALID <= '0';
        wait for clock_period;
        -- Check the outputs
        -- AXI_ACP_1_read_data
        assert AXI_ACP_1_read_complete = '0' severity error;
        -- AXI_ACP_1_read_result
        -- AXI_ACP_1_ARADDR
        -- AXI_ACP_1_ARLEN
        -- AXI_ACP_1_ARSIZE
        -- AXI_ACP_1_ARBURST
        assert AXI_ACP_1_ARVALID = '0' severity error;
        assert AXI_ACP_1_RREADY = '0' severity error;
        wait until rst = '0';

        wait for clock_period;
        -- Start state: the machine waits until read_start is '1'.
        -- Check the outputs
        for I in 0 to 3 loop
            -- AXI_ACP_1_read_data
            assert AXI_ACP_1_read_complete = '1' severity error;
            -- AXI_ACP_1_read_result
            -- AXI_ACP_1_ARADDR
            -- AXI_ACP_1_ARLEN
            -- AXI_ACP_1_ARSIZE
            -- AXI_ACP_1_ARBURST
            assert AXI_ACP_1_ARVALID = '0' severity error;
            assert AXI_ACP_1_RREADY = '0' severity error;
            wait for clock_period;
        end loop;
        -- Set the inputs
        AXI_ACP_1_read_addr <= std_logic_vector(read_addr);
        AXI_ACP_1_read_start <= '1';
        -- AXI_ACP_1_ARREADY
        -- AXI_ACP_1_RDATA
        -- AXI_ACP_1_RRESP
        -- AXI_ACP_1_RLAST
        -- AXI_ACP_1_RVALID

        wait for clock_period;
        -- Read start has become one, all values should now be locked in
        -- Check the outputs
        -- AXI_ACP_1_read_data
        assert AXI_ACP_1_read_complete = '0' severity error;
        -- AXI_ACP_1_read_result
        assert AXI_ACP_1_ARADDR = std_logic_vector(read_addr) severity error;
        -- AXI_ACP_1_ARLEN
        -- AXI_ACP_1_ARSIZE
        -- AXI_ACP_1_ARBURST
        assert AXI_ACP_1_ARVALID = '1' severity error;
        assert AXI_ACP_1_RREADY = '0' severity error;
        wait for clock_period;
        -- Set the inputs
        AXI_ACP_1_read_addr <= (others => '0');
        AXI_ACP_1_read_start <= '0';
        -- AXI_ACP_1_ARREADY
        -- AXI_ACP_1_RDATA
        -- AXI_ACP_1_RRESP
        -- AXI_ACP_1_RLAST
        -- AXI_ACP_1_RVALID

        wait for clock_period;
        -- Check lock-in and then signal receive
        -- Check the outputs
        for I in 0 to 2 loop
            -- AXI_ACP_1_read_data
            assert AXI_ACP_1_read_complete = '0' severity error;
            -- AXI_ACP_1_read_result
            assert AXI_ACP_1_ARADDR = std_logic_vector(read_addr) severity error;
            -- AXI_ACP_1_ARLEN
            -- AXI_ACP_1_ARSIZE
            -- AXI_ACP_1_ARBURST
            assert AXI_ACP_1_ARVALID = '1' severity error;
            assert AXI_ACP_1_RREADY = '0' severity error;
            wait for clock_period;
        end loop;
        -- Set the inputs
        -- AXI_ACP_1_read_addr
        -- AXI_ACP_1_read_start
        AXI_ACP_1_ARREADY <= '1';
        -- AXI_ACP_1_RDATA
        -- AXI_ACP_1_RRESP
        -- AXI_ACP_1_RLAST
        -- AXI_ACP_1_RVALID

        wait for clock_period;
        -- The address data has just been transmitted, we expect the other side to be waiting for the response
        -- AXI_ACP_1_read_data
        assert AXI_ACP_1_read_complete = '0' severity error;
        -- AXI_ACP_1_read_result
        -- AXI_ACP_1_ARADDR
        -- AXI_ACP_1_ARLEN
        -- AXI_ACP_1_ARSIZE
        -- AXI_ACP_1_ARBURST
        assert AXI_ACP_1_ARVALID = '0' severity error;
        assert AXI_ACP_1_RREADY = '1' severity error;
        -- Set the inputs
        -- AXI_ACP_1_read_addr
        -- AXI_ACP_1_read_start
        AXI_ACP_1_ARREADY <= '0';
        AXI_ACP_1_RDATA <= ( 15 Downto 0 => '1', others => '0');
        AXI_ACP_1_RRESP <= (others => '0');
        -- AXI_ACP_1_RVALID
        AXI_ACP_1_RLAST <= '1';

        wait for clock_period;
        -- Send the response
        -- Check the outputs
        -- AXI_ACP_1_read_data
        assert AXI_ACP_1_read_complete = '0' severity error;
        -- AXI_ACP_1_read_result
        -- AXI_ACP_1_ARADDR
        -- AXI_ACP_1_ARLEN
        -- AXI_ACP_1_ARSIZE
        -- AXI_ACP_1_ARBURST
        assert AXI_ACP_1_ARVALID = '0' severity error;
        assert AXI_ACP_1_RREADY = '1' severity error;
        -- Set the inputs
        -- AXI_ACP_1_read_addr
        -- AXI_ACP_1_read_start
        -- AXI_ACP_1_ARREADY
        -- AXI_ACP_1_RDATA
        -- AXI_ACP_1_RRESP
        AXI_ACP_1_RVALID <= '1';
        -- AXI_ACP_1_RLAST

        wait for clock_period;
        -- The memory data has just been received, we expect the other side to be "done"
        assert AXI_ACP_1_read_data = std_logic_vector(to_unsigned(16#ffff#, AXI_ACP_1_read_data'length)) severity error;
        assert AXI_ACP_1_read_complete = '1' severity error;
        assert AXI_ACP_1_read_result = (AXI_ACP_1_read_result'range => '0') severity error;
        -- AXI_ACP_1_ARADDR
        -- AXI_ACP_1_ARLEN
        -- AXI_ACP_1_ARSIZE
        -- AXI_ACP_1_ARBURST
        assert AXI_ACP_1_ARVALID = '0' severity error;
        assert AXI_ACP_1_RREADY = '0' severity error;
        read_test_done <= true;
        wait;
        --write(my_line, AXI_ACP_1_read_data);
        --writeline(output, my_line);
        --write(my_line, std_logic_vector(to_unsigned(16#ffff#, AXI_ACP_1_read_data'length)));
        --writeline(output, my_line);
    end process;
end Behavioral;

