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
    type m_state_type is (rst_state, wait_for_start, wait_for_submachines, assert_bready);
    type wad_state_type is (rst_state, wait_for_start, assert_valid);

    signal m_cur_state      : m_state_type      := rst_state;
    signal m_next_state     : m_state_type      := rst_state;
    signal aw_cur_state     : wad_state_type    := rst_state;
    signal aw_next_state    : wad_state_type    := rst_state;
    signal w_cur_state      : wad_state_type    := rst_state;
    signal w_next_state     : wad_state_type    := rst_state;

    signal m_done           : boolean           := false;
    signal aw_done          : boolean           := false;
    signal w_done           : boolean           := false;

    signal write_addr_read  : boolean           := false;
    signal write_data_read  : boolean           := false;
    signal bresp_read       : boolean           := false;

    signal sub_write_start  : boolean           := false;

begin

    sub_write_start <= (write_start = '1') and m_done;

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
            m_cur_state     <= rst_state;
            aw_cur_state    <= rst_state;
        elsif rising_edge(clk) then
            m_cur_state     <= m_next_state;
            aw_cur_state    <= aw_next_state;
            w_cur_state     <= w_next_state;
        end if;
    end process;

    m_state_decider : process(m_cur_state, write_start, aw_done, w_done, M_AXI_ACP_BVALID)
    begin
        m_next_state <= m_cur_state;
        case m_cur_state is
            when rst_state =>
                m_next_state <= wait_for_start;
            when wait_for_start =>
                if write_start = '1' then
                    m_next_state <= wait_for_submachines;
                end if;
            when wait_for_submachines =>
                if aw_done and w_done then
                    m_next_state <= assert_bready;
                end if;
            when assert_bready =>
                if M_AXI_ACP_BVALID = '1' then
                    m_next_state <= wait_for_start;
                end if;
        end case;
    end process;

    m_output_decider : process(m_cur_state)
    begin
        case m_cur_state is
            when rst_state =>
                bresp_read          <= false;
                m_done              <= false;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '0';
            when wait_for_start =>
                bresp_read          <= false;
                m_done              <= true;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '1';
            when wait_for_submachines =>
                bresp_read          <= true;
                m_done              <= false;
                M_AXI_ACP_BREADY    <= '0';
                write_complete      <= '0';
            when assert_bready =>
                bresp_read          <= true;
                m_done              <= false;
                M_AXI_ACP_BREADY    <= '1';
                write_complete      <= '0';
        end case;
    end process;

    --type wad_state_type is (rst_state, wait_for_start, assert_valid, wait_for_completion);
    aw_state_decider : process(aw_cur_state, sub_write_start, M_AXI_ACP_AWREADY)
    begin
        aw_next_state <= aw_cur_state;
        case aw_cur_state is
            when rst_state =>
                aw_next_state <= wait_for_start;
            when wait_for_start =>
                if sub_write_start then
                    aw_next_state <= assert_valid;
                end if;
            when assert_valid =>
                if M_AXI_ACP_AWREADY = '1' then
                    aw_next_state <= wait_for_start;
                end if;
        end case;
    end process;

    aw_output_decider : process(aw_cur_state)
    begin
        case aw_cur_state is
            when rst_state =>
                aw_done             <= false;
                write_addr_read     <= false;
                M_AXI_ACP_AWVALID   <= '0';
            when wait_for_start =>
                aw_done             <= true;
                write_addr_read     <= true;
                M_AXI_ACP_AWVALID   <= '0';
            when assert_valid =>
                aw_done             <= false;
                write_addr_read     <= false;
                M_AXI_ACP_AWVALID   <= '1';
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
    end process;

    w_state_decider : process (w_cur_state, sub_write_start, M_AXI_ACP_WREADY)
    begin
        w_next_state <= w_cur_state;
        case w_cur_state is
            when rst_state =>
                w_next_state <= wait_for_start;
            when wait_for_start =>
                if sub_write_start then
                    w_next_state <= assert_valid;
                end if;
            when assert_valid =>
                if M_AXI_ACP_WREADY = '1' then
                    w_next_state <= wait_for_start;
                end if;
        end case;
    end process;

    w_output_decider : process(w_cur_state)
    begin
        case w_cur_state is
            when rst_state =>
                w_done              <= false;
                write_data_read     <= false;
                M_AXI_ACP_WVALID    <= '0';
            when wait_for_start =>
                w_done              <= true;
                write_data_read     <= true;
                M_AXI_ACP_WVALID    <= '0';
            when assert_valid =>
                w_done              <= false;
                write_data_read     <= false;
                M_AXI_ACP_WVALID    <= '1';
        end case;
        -- Write strobe, which bytes of the WDATA are useful?
        -- The last 4. See AXI4 spec p 52
        M_AXI_ACP_WSTRB     <= (3 DOWNTO 0 => '1', others => '0');
        -- There is only one transfer, so that one is always the last
        -- See AXI4 spec p 41
        M_AXI_ACP_WLAST     <= '1';
    end process;
end Behavioral;
