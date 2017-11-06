library STD;
use std.textio.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity tb_axi4 is
end tb_axi4;

architecture Behavioral of tb_axi4 is
    constant clock_period               : time := 20 ns;

    signal test_done                    : boolean;
    signal read_test_done               : boolean := false;
    signal write_test_done              : boolean := false;

    signal clk                          : std_logic                         := '1';
    signal rst                          : std_logic                         := '1';

    -- AXI 1
    -- Constants
    constant axi_1_data_width_log2b     : natural                           := 5;
    constant axi_1_address_wdith_log2b  : natural                           := 5;
    -- The signals for axi4_acp_1
    signal AXI_1_write_addr         : std_logic_vector(31 downto 2)     := (others => '0');
    signal AXI_1_write_data         : std_logic_vector(31 downto 0)     := (others => '0');
    signal AXI_1_read_addr          : std_logic_vector(31 downto 2)     := (others => '0');
    signal AXI_1_read_data          : std_logic_vector(31 downto 0);
    signal AXI_1_write_start        : std_logic                         := '0';
    signal AXI_1_write_complete     : std_logic;
    signal AXI_1_write_result       : std_logic_vector(1 downto 0);
    signal AXI_1_write_mask         : std_logic_vector(3 downto 0)      := (others => '1');
    signal AXI_1_read_start         : std_logic                         := '0';
    signal AXI_1_read_complete      : std_logic;
    signal AXI_1_read_result        : std_logic_vector(1 downto 0);
    signal AXI_1_ACLK               : std_logic;
    signal AXI_1_AWID               : std_logic_vector(2 DOWNTO 0);
    signal AXI_1_AWADDR             : std_logic_vector(31 downto 0);
    signal AXI_1_AWLEN              : std_logic_vector(3 downto 0);
    signal AXI_1_AWSIZE             : std_logic_vector(2 downto 0);
    signal AXI_1_AWBURST            : std_logic_vector(1 downto 0);
    signal AXI_1_AWLOCK             : std_logic_vector(1 downto 0);
    signal AXI_1_AWCACHE            : std_logic_vector(3 downto 0);
    signal AXI_1_AWPROT             : std_logic_vector(2 downto 0);
    signal AXI_1_AWQOS              : std_logic_vector(3 downto 0);
    signal AXI_1_AWUSER             : std_logic_vector(4 downto 0);
    signal AXI_1_AWVALID            : std_logic;
    signal AXI_1_AWREADY            : std_logic                         := '0';
    signal AXI_1_WID                : std_logic_vector(2 downto 0);
    signal AXI_1_WDATA              : std_logic_vector(31 downto 0);
    signal AXI_1_WSTRB              : std_logic_vector(3 downto 0);
    signal AXI_1_WLAST              : std_logic;
    signal AXI_1_WVALID             : std_logic;
    signal AXI_1_WREADY             : std_logic                         := '0';
    signal AXI_1_BID                : std_logic_vector(2 downto 0)      := (others => '0');
    signal AXI_1_BRESP              : std_logic_vector(1 downto 0)      := (others => '0');
    signal AXI_1_BVALID             : std_logic                         := '0';
    signal AXI_1_BREADY             : std_logic;
    signal AXI_1_ARID               : std_logic_vector(2 downto 0);
    signal AXI_1_ARADDR             : std_logic_vector(31 downto 0);
    signal AXI_1_ARLEN              : std_logic_vector(3 downto 0);
    signal AXI_1_ARSIZE             : std_logic_vector(2 downto 0);
    signal AXI_1_ARBURST            : std_logic_vector(1 downto 0);
    signal AXI_1_ARLOCK             : std_logic_vector(1 downto 0);
    signal AXI_1_ARCACHE            : std_logic_vector(3 downto 0);
    signal AXI_1_ARPROT             : std_logic_vector(2 downto 0);
    signal AXI_1_ARQOS              : std_logic_vector(3 downto 0);
    signal AXI_1_ARUSER             : std_logic_vector(4 downto 0);
    signal AXI_1_ARVALID            : std_logic;
    signal AXI_1_ARREADY            : std_logic                         := '0';
    signal AXI_1_RID                : std_logic_vector(2 downto 0)      := (others => '0');
    signal AXI_1_RDATA              : std_logic_vector(31 downto 0)     := (others => '0');
    signal AXI_1_RRESP              : std_logic_vector(1 downto 0)      := (others => '0');
    signal AXI_1_RLAST              : std_logic                         := '0';
    signal AXI_1_RVALID             : std_logic                         := '0';
    signal AXI_1_RREADY             : std_logic;
begin
    axi4_acp_1 : entity work.axi4_master
    generic map (
        axi_data_width_log2b    => axi_1_data_width_log2b,
        axi_address_width_log2b => axi_1_address_wdith_log2b
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        write_addr          => AXI_1_write_addr,
        write_data          => AXI_1_write_data,
        read_addr           => AXI_1_read_addr,
        read_data           => AXI_1_read_data,
        write_start         => AXI_1_write_start,
        write_complete      => AXI_1_write_complete,
        write_result        => AXI_1_write_result,
        write_mask          => AXI_1_write_mask,
        read_start          => AXI_1_read_start,
        read_complete       => AXI_1_read_complete,
        read_result         => AXI_1_read_result,
        M_AXI_ACLK          => AXI_1_ACLK,
        M_AXI_AWID          => AXI_1_AWID,
        M_AXI_AWADDR        => AXI_1_AWADDR,
        M_AXI_AWLEN         => AXI_1_AWLEN,
        M_AXI_AWSIZE        => AXI_1_AWSIZE,
        M_AXI_AWBURST       => AXI_1_AWBURST,
        M_AXI_AWLOCK        => AXI_1_AWLOCK,
        M_AXI_AWCACHE       => AXI_1_AWCACHE,
        M_AXI_AWPROT        => AXI_1_AWPROT,
        M_AXI_AWQOS         => AXI_1_AWQOS,
        M_AXI_AWUSER        => AXI_1_AWUSER,
        M_AXI_AWVALID       => AXI_1_AWVALID,
        M_AXI_AWREADY       => AXI_1_AWREADY,
        M_AXI_WID           => AXI_1_WID,
        M_AXI_WDATA         => AXI_1_WDATA,
        M_AXI_WSTRB         => AXI_1_WSTRB,
        M_AXI_WLAST         => AXI_1_WLAST,
        M_AXI_WVALID        => AXI_1_WVALID,
        M_AXI_WREADY        => AXI_1_WREADY,
        M_AXI_BID           => AXI_1_BID,
        M_AXI_BRESP         => AXI_1_BRESP,
        M_AXI_BVALID        => AXI_1_BVALID,
        M_AXI_BREADY        => AXI_1_BREADY,
        M_AXI_ARID          => AXI_1_ARID,
        M_AXI_ARADDR        => AXI_1_ARADDR,
        M_AXI_ARLEN         => AXI_1_ARLEN,
        M_AXI_ARSIZE        => AXI_1_ARSIZE,
        M_AXI_ARBURST       => AXI_1_ARBURST,
        M_AXI_ARLOCK        => AXI_1_ARLOCK,
        M_AXI_ARCACHE       => AXI_1_ARCACHE,
        M_AXI_ARPROT        => AXI_1_ARPROT,
        M_AXI_ARQOS         => AXI_1_ARQOS,
        M_AXI_ARUSER        => AXI_1_ARUSER,
        M_AXI_ARVALID       => AXI_1_ARVALID,
        M_AXI_ARREADY       => AXI_1_ARREADY,
        M_AXI_RID           => AXI_1_RID,
        M_AXI_RDATA         => AXI_1_RDATA,
        M_AXI_RRESP         => AXI_1_RRESP,
        M_AXI_RLAST         => AXI_1_RLAST,
        M_AXI_RVALID        => AXI_1_RVALID,
        M_AXI_RREADY        => AXI_1_RREADY
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

    write_loop : process
        constant write_addr : unsigned(AXI_1_write_addr'RANGE)  := to_unsigned(20, AXI_1_write_addr'length );
        constant write_data : unsigned(AXI_1_write_data'RANGE)  := to_unsigned(14, AXI_1_write_data'length );
        constant bresp      : unsigned(AXI_1_BRESP'RANGE)       := to_unsigned(3, AXI_1_BRESP'length );
    begin
        -- Give all inputs sensible defaults
        AXI_1_write_addr        <= (others => '0');
        AXI_1_write_data        <= (others => '0');
        AXI_1_write_start       <= '0';
        AXI_1_AWREADY           <= '0';
        AXI_1_WREADY            <= '0';
        AXI_1_BRESP             <= (others => '0');
        AXI_1_BVALID            <= '0';
        wait for clock_period;
        -- Reset is still enabled, test the reset outputs
        assert AXI_1_write_complete = '0' severity error;
        -- AXI_1_write_result
        -- AXI_1_AWADDR
        assert AXI_1_AWVALID = '0' severity error;
        -- AXI_1_WDATA
        assert AXI_1_WVALID = '0' severity error;
        assert AXI_1_BREADY = '0' severity error;
        wait until rst = '0';
        wait for clock_period;
        -- Writer should be in start state
        AXI_1_write_addr        <= std_logic_vector(write_addr);
        AXI_1_write_data        <= std_logic_vector(write_data);
        AXI_1_write_start       <= '1';
        AXI_1_AWREADY           <= '1';
        AXI_1_WREADY            <= '0';
        -- AXI_1_BRESP
        -- AXI_1_BVALID
        assert AXI_1_write_complete = '1' severity error;
        -- AXI_1_write_result
        -- AXI_1_AWADDR
        assert AXI_1_AWVALID = '0' severity error;
        -- AXI_1_WDATA
        assert AXI_1_WVALID = '0' severity error;
        assert AXI_1_BREADY = '0' severity error;

        wait for clock_period;
        -- Writer should now be sending data
        AXI_1_write_addr        <= (others => '0');
        AXI_1_write_data        <= (others => '0');
        AXI_1_write_start       <= '0';
        AXI_1_AWREADY           <= '1';
        AXI_1_WREADY            <= '1';
        -- AXI_1_BRESP
        -- AXI_1_BVALID
        assert AXI_1_write_complete = '0' severity error;
        -- AXI_1_write_result
        assert AXI_1_AWVALID = '1' severity error;
        assert AXI_1_AWADDR = std_logic_vector(write_addr) & "00";
        assert AXI_1_WDATA = std_logic_vector(resize(write_data, AXI_1_WDATA'length));
        assert AXI_1_WVALID = '1' severity error;
        -- AXI_1_BREADY

        wait for clock_period;
        -- Now the writer should be ready to receive the feedback
        --AXI_1_write_addr        <= write_addr;
        --AXI_1_write_data        <= write_data
        AXI_1_write_start       <= '0';
        AXI_1_AWREADY           <= '0';
        AXI_1_WREADY            <= '0';
        AXI_1_BRESP             <= std_logic_vector(bresp);
        AXI_1_BVALID            <= '1';
        assert AXI_1_write_complete = '0' severity error;
        -- AXI_1_write_result
        assert AXI_1_AWVALID = '0' severity error;
        -- AXI_1_AWADDR
        -- AXI_1_WDATA
        assert AXI_1_WVALID = '0' severity error;
        -- AXI_1_BREADY
        wait for clock_period;
        -- Now the writer should be ready to receive the feedback

        wait for clock_period;
        -- The writer should have finished operating
        --AXI_1_write_addr        <= write_addr;
        --AXI_1_write_data        <= write_data
        AXI_1_write_start       <= '0';
        AXI_1_AWREADY           <= '0';
        AXI_1_WREADY            <= '0';
        AXI_1_BRESP             <= (others => '0');
        AXI_1_BVALID            <= '0';
        assert AXI_1_write_complete = '1' severity error;
        assert AXI_1_write_result = std_logic_vector(bresp);
        -- AXI_1_AWVALID
        -- AXI_1_AWADDR
        -- AXI_1_WDATA
        -- AXI_1_WVALID
        assert AXI_1_BREADY = '0' severity error;

        write_test_done <= true;
        wait;

    end process;


    read_loop : process
        constant read_addr : unsigned(AXI_1_write_addr'RANGE) := to_unsigned(15, AXI_1_write_addr'length );
        variable my_line : line;
    begin
        -- Give all inputs sensible defaults
        AXI_1_read_addr <= (others => '0');
        AXI_1_read_start <= '0';
        AXI_1_ARREADY <= '0';
        AXI_1_RDATA <= (others => '0');
        AXI_1_RRESP <= (others => '0');
        AXI_1_RLAST <= '0';
        AXI_1_RVALID <= '0';
        wait for clock_period;
        -- Check the outputs
        -- AXI_1_read_data
        assert AXI_1_read_complete = '0' severity error;
        -- AXI_1_read_result
        -- AXI_1_ARADDR
        -- AXI_1_ARLEN
        -- AXI_1_ARSIZE
        -- AXI_1_ARBURST
        assert AXI_1_ARVALID = '0' severity error;
        assert AXI_1_RREADY = '0' severity error;
        wait until rst = '0';

        wait for clock_period;
        -- Start state: the machine waits until read_start is '1'.
        -- Check the outputs
        for I in 0 to 3 loop
            -- AXI_1_read_data
            assert AXI_1_read_complete = '1' severity error;
            -- AXI_1_read_result
            -- AXI_1_ARADDR
            -- AXI_1_ARLEN
            -- AXI_1_ARSIZE
            -- AXI_1_ARBURST
            assert AXI_1_ARVALID = '0' severity error;
            assert AXI_1_RREADY = '0' severity error;
            wait for clock_period;
        end loop;
        -- Set the inputs
        AXI_1_read_addr <= std_logic_vector(read_addr);
        AXI_1_read_start <= '1';
        -- AXI_1_ARREADY
        -- AXI_1_RDATA
        -- AXI_1_RRESP
        -- AXI_1_RLAST
        -- AXI_1_RVALID

        wait for clock_period;
        -- Read start has become one, all values should now be locked in
        -- Check the outputs
        -- AXI_1_read_data
        assert AXI_1_read_complete = '0' severity error;
        -- AXI_1_read_result
        assert AXI_1_ARADDR = std_logic_vector(read_addr) & "00" severity error;
        -- AXI_1_ARLEN
        -- AXI_1_ARSIZE
        -- AXI_1_ARBURST
        assert AXI_1_ARVALID = '1' severity error;
        assert AXI_1_RREADY = '0' severity error;
        wait for clock_period;
        -- Set the inputs
        AXI_1_read_addr <= (others => '0');
        AXI_1_read_start <= '0';
        -- AXI_1_ARREADY
        -- AXI_1_RDATA
        -- AXI_1_RRESP
        -- AXI_1_RLAST
        -- AXI_1_RVALID

        wait for clock_period;
        -- Check lock-in and then signal receive
        -- Check the outputs
        for I in 0 to 2 loop
            -- AXI_1_read_data
            assert AXI_1_read_complete = '0' severity error;
            -- AXI_1_read_result
            assert AXI_1_ARADDR = std_logic_vector(read_addr) & "00" severity error;
            -- AXI_1_ARLEN
            -- AXI_1_ARSIZE
            -- AXI_1_ARBURST
            assert AXI_1_ARVALID = '1' severity error;
            assert AXI_1_RREADY = '0' severity error;
            wait for clock_period;
        end loop;
        -- Set the inputs
        -- AXI_1_read_addr
        -- AXI_1_read_start
        AXI_1_ARREADY <= '1';
        -- AXI_1_RDATA
        -- AXI_1_RRESP
        -- AXI_1_RLAST
        -- AXI_1_RVALID

        wait for clock_period;
        -- The address data has just been transmitted, we expect the other side to be waiting for the response
        -- AXI_1_read_data
        assert AXI_1_read_complete = '0' severity error;
        -- AXI_1_read_result
        -- AXI_1_ARADDR
        -- AXI_1_ARLEN
        -- AXI_1_ARSIZE
        -- AXI_1_ARBURST
        assert AXI_1_ARVALID = '0' severity error;
        assert AXI_1_RREADY = '1' severity error;
        -- Set the inputs
        -- AXI_1_read_addr
        -- AXI_1_read_start
        AXI_1_ARREADY <= '0';
        AXI_1_RDATA <= ( 15 Downto 0 => '1', others => '0');
        AXI_1_RRESP <= (others => '0');
        -- AXI_1_RVALID
        AXI_1_RLAST <= '1';

        wait for clock_period;
        -- Send the response
        -- Check the outputs
        -- AXI_1_read_data
        assert AXI_1_read_complete = '0' severity error;
        -- AXI_1_read_result
        -- AXI_1_ARADDR
        -- AXI_1_ARLEN
        -- AXI_1_ARSIZE
        -- AXI_1_ARBURST
        assert AXI_1_ARVALID = '0' severity error;
        assert AXI_1_RREADY = '1' severity error;
        -- Set the inputs
        -- AXI_1_read_addr
        -- AXI_1_read_start
        -- AXI_1_ARREADY
        -- AXI_1_RDATA
        -- AXI_1_RRESP
        AXI_1_RVALID <= '1';
        -- AXI_1_RLAST

        wait for clock_period;
        -- The memory data has just been received, we expect the other side to be "done"
        assert AXI_1_read_data = std_logic_vector(to_unsigned(16#ffff#, AXI_1_read_data'length)) severity error;
        assert AXI_1_read_complete = '1' severity error;
        assert AXI_1_read_result = (AXI_1_read_result'range => '0') severity error;
        -- AXI_1_ARADDR
        -- AXI_1_ARLEN
        -- AXI_1_ARSIZE
        -- AXI_1_ARBURST
        assert AXI_1_ARVALID = '0' severity error;
        assert AXI_1_RREADY = '0' severity error;
        -- Set the inputs
        -- AXI_1_read_addr
        -- AXI_1_read_start
        -- AXI_1_ARREADY
        -- AXI_1_RDATA
        -- AXI_1_RRESP
        AXI_1_RVALID <= '0';
        -- AXI_1_RLAST
        wait for clock_period;
        read_test_done <= true;
        wait;
        --write(my_line, AXI_1_read_data);
        --writeline(output, my_line);
        --write(my_line, std_logic_vector(to_unsigned(16#ffff#, AXI_1_read_data'length)));
        --writeline(output, my_line);
    end process;
end Behavioral;

