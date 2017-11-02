library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi4_acp_writer is
    port (
        clk                 :   in std_logic;
        rst                 :   in std_logic;
        write_addr          :   in  std_logic_vector(31 downto 0);
        write_data          :   in  std_logic_vector(31 downto 0);
        write_start         :   in  std_logic;
        write_complete      :   out std_logic;
        write_result        :   out std_logic_vector(1 downto 0);
        -- Write address channel signals
        M_AXI_ACP_AWADDR    :   out std_logic_vector(31 downto 0);
        M_AXI_ACP_AWLEN     :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_AWSIZE    :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_AWCACHE   :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_AWUSER    :   out std_logic_vector(4 downto 0);
        M_AXI_ACP_AWBURST   :   out std_logic_vector(1 downto 0);
        M_AXI_ACP_AWVALID   :   out std_logic;
        M_AXI_ACP_AWREADY   :   in  std_logic;
        -- Write data channel signals
        M_AXI_ACP_WDATA     :   out std_logic_vector(63 downto 0);
        M_AXI_ACP_WSTRB     :   out std_logic_vector(7 downto 0);
        M_AXI_ACP_WLAST     :   out std_logic;
        M_AXI_ACP_WVALID    :   out std_logic;
        M_AXI_ACP_WREADY    :   in  std_logic;
        --  Write response channel signals
        M_AXI_ACP_BRESP     :   in  std_logic_vector(1 downto 0);
        M_AXI_ACP_BVALID    :   in  std_logic;
        M_AXI_ACP_BREADY    :   out std_logic
    );
end axi4_acp_writer;

ARCHITECTURE Behavioral of axi4_acp_writer is
    type m_state_type is (rst_state, wait_for_start, wait_for_awready_wready, wait_for_awready, wait_for_wready, assert_bready);

    signal cur_state        : m_state_type      := rst_state;
    signal next_state       : m_state_type      := rst_state;

    signal write_addr_read  : boolean           := false;
    signal write_data_read  : boolean           := false;
    signal bresp_read       : boolean           := false;

begin

    data_safe : process(clk, rst, write_addr_read, write_data_read, bresp_read)
        variable write_addr_safe    : std_logic_vector(write_addr'range);
        variable write_data_safe    : std_logic_vector(write_data'range);
        variable bresp_safe         : std_logic_vector(M_AXI_ACP_BRESP'range);
    begin
        if rst = '1' then
            write_addr_safe     := (others => '0');
            write_data_safe     := (others => '0');
            bresp_safe          := (others => '0');
        elsif rising_edge(clk) then
            if write_addr_read then
                write_addr_safe := write_addr;
            end if;
            if write_data_read then
                write_data_safe := write_data;
            end if;
            if bresp_read then
                bresp_safe      := M_AXI_ACP_BRESP;
            end if;
        end if;
        M_AXI_ACP_AWADDR                <= write_addr_safe;
        M_AXI_ACP_WDATA(31 DOWNTO 0)    <= write_data_safe;
        M_AXI_ACP_WDATA(63 DOWNTO 32)   <= (others => '0');
        write_result                    <= bresp_safe;
    end process;

    state_transition : process(clk, rst)
    begin
        if rst = '1' then
            cur_state       <= rst_state;
            cur_state       <= rst_state;
        elsif rising_edge(clk) then
            cur_state       <= next_state;
            cur_state       <= next_state;
            cur_state       <= next_state;
        end if;
    end process;

    state_decider : process(cur_state, write_start, M_AXI_ACP_AWREADY, M_AXI_ACP_WREADY, M_AXI_ACP_BVALID)
    begin
        next_state <= cur_state;
        case cur_state is
            when rst_state =>
                next_state <= wait_for_start;
            when wait_for_start =>
                if write_start = '1' then
                    next_state <= wait_for_awready_wready;
                end if;
            when wait_for_awready_wready =>
                if M_AXI_ACP_AWREADY = '1' and M_AXI_ACP_WREADY = '1' then
                    next_state <= assert_bready;
                elsif M_AXI_ACP_AWREADY = '1' then
                    next_state <= wait_for_wready;
                elsif M_AXI_ACP_WREADY = '1' then
                    next_state <= wait_for_awready;
                end if;
            when wait_for_awready =>
                if M_AXI_ACP_AWREADY = '1' then
                    next_state <= assert_bready;
                end if;
            when wait_for_wready =>
                if M_AXI_ACP_WREADY = '1' then
                    next_state <= assert_bready;
                end if;
            when assert_bready =>
                if M_AXI_ACP_BVALID = '1' then
                    next_state <= wait_for_start;
                end if;
        end case;
    end process;

    output_decider : process(cur_state)
    begin
        case cur_state is
            when rst_state =>
                bresp_read          <= false;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= false;
                M_AXI_ACP_AWVALID   <= '0';
                write_data_read     <= false;
                M_AXI_ACP_WVALID    <= '0';
            when wait_for_start =>
                bresp_read          <= false;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '1';
                write_addr_read     <= true;
                M_AXI_ACP_AWVALID   <= '0';
                write_data_read     <= true;
                M_AXI_ACP_WVALID    <= '0';
            when wait_for_awready_wready =>
                bresp_read          <= true;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= false;
                M_AXI_ACP_AWVALID   <= '1';
                write_data_read     <= false;
                M_AXI_ACP_WVALID    <= '1';
            when wait_for_awready =>
                bresp_read          <= true;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= false;
                M_AXI_ACP_AWVALID   <= '1';
                write_data_read     <= true;
                M_AXI_ACP_WVALID    <= '0';
            when wait_for_wready =>
                bresp_read          <= true;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= true;
                M_AXI_ACP_AWVALID   <= '0';
                write_data_read     <= false;
                M_AXI_ACP_WVALID    <= '1';
            when assert_bready =>
                bresp_read          <= true;
                M_AXI_ACP_BREADY    <= '1';
                write_complete      <= '0';
                write_addr_read     <= true;
                M_AXI_ACP_AWVALID   <= '0';
                write_data_read     <= true;
                M_AXI_ACP_WVALID    <= '0';
        end case;
        -- Burst length 1, see AXI spec p 46
        M_AXI_ACP_AWLEN     <= (others => '0');
        -- 4 bytes (=32bit) per burst, see AXI spec p 47
        M_AXI_ACP_AWSIZE    <= "010";
        -- Does not matter, since burst size is 1, see AXI spec p 48
        M_AXI_ACP_AWBURST   <= (others => '0');
        -- AWCACHE and AWUSER are specific for ZYNQ
        -- There is a possibility to use the ZYNQ cache, this is ignored.
        M_AXI_ACP_AWCACHE   <= (others => '0');
        M_AXI_ACP_AWUSER    <= (others => '0');
        -- Write strobe, which bytes of the WDATA are useful?
        -- The last 4. See AXI4 spec p 52
        M_AXI_ACP_WSTRB     <= (3 DOWNTO 0 => '1', others => '0');
        -- There is only one transfer, so that one is always the last
        -- See AXI4 spec p 41
        M_AXI_ACP_WLAST     <= '1';
    end process;
end Behavioral;
