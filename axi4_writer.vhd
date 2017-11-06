library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 

entity axi4_writer is
    generic (
        axi_data_width_log2b    :   natural range 5 to natural'high := 6;
        axi_address_width_log2b :   natural range 5 to natural'high := 5
    );
    port (
        clk                 :   in std_logic;
        rst                 :   in std_logic;
        write_addr          :   in  std_logic_vector(31 downto 2);
        write_data          :   in  std_logic_vector(31 downto 0);
        write_start         :   in  std_logic;
        write_complete      :   out std_logic;
        write_result        :   out std_logic_vector(1 downto 0);
        write_mask          :   in  std_logic_vector(3 downto 0);
        -- Write address channel signals
        M_AXI_AWADDR        :   out std_logic_vector(2**axi_address_width_log2b - 1 downto 0);
        M_AXI_AWLEN         :   out std_logic_vector(3 downto 0);
        M_AXI_AWSIZE        :   out std_logic_vector(2 downto 0);
        M_AXI_AWCACHE       :   out std_logic_vector(3 downto 0);
        M_AXI_AWUSER        :   out std_logic_vector(4 downto 0);
        M_AXI_AWBURST       :   out std_logic_vector(1 downto 0);
        M_AXI_AWVALID       :   out std_logic;
        M_AXI_AWREADY       :   in  std_logic;
        -- Write data channel signals
        M_AXI_WDATA         :   out std_logic_vector(2**axi_data_width_log2b - 1 downto 0);
        M_AXI_WSTRB         :   out std_logic_vector(2**(axi_data_width_log2b - 3) - 1 downto 0);
        M_AXI_WLAST         :   out std_logic;
        M_AXI_WVALID        :   out std_logic;
        M_AXI_WREADY        :   in  std_logic;
        --  Write response channel signals
        M_AXI_BRESP         :   in  std_logic_vector(1 downto 0);
        M_AXI_BVALID        :   in  std_logic;
        M_AXI_BREADY        :   out std_logic
    );
end axi4_writer;

ARCHITECTURE Behavioral of axi4_writer is
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
        variable bresp_safe         : std_logic_vector(M_AXI_BRESP'range);
        variable shift_modifier     : natural;
        variable wdata_reg          : std_logic_vector(M_AXI_WDATA'range);
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
                bresp_safe      := M_AXI_BRESP;
            end if;
        end if;
        -- The address is right now aligned to 32 bit and needs to be aligned to 2**axi_data_width_log2b
        -- We want the first axi_data_width_log2b-3 bits to be zero, counted from the right.
        -- Now, it might be the case that axi_data_width_log2b-3 > 32. But that is really weird.
        M_AXI_AWADDR                <= (M_AXI_AWADDR'high downto write_addr_safe'left + 1 => '0') & write_addr_safe(write_addr_safe'left downto axi_data_width_log2b - 3) & (axi_data_width_log2b - 4 downto 0 => '0');
        shift_modifier                  := to_integer(unsigned(write_addr_safe(axi_data_width_log2b - 3 downto 2)));
        wdata_reg                       := (wdata_reg'left downto write_data_safe'left + 1 => '0') & write_data_safe;
        M_AXI_WDATA                 <= std_logic_vector(shift_left(unsigned(wdata_reg), shift_modifier*4));
        write_result                    <= bresp_safe;
        -- Write strobe, which bytes of the WDATA are useful?
        -- The write mask is the inverse write strobe, so use that and shift it
        M_AXI_WSTRB                 <= std_logic_vector(shift_left(unsigned(not write_mask), 4*shift_modifier));
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

    state_decider : process(cur_state, write_start, M_AXI_AWREADY, M_AXI_WREADY, M_AXI_BVALID)
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
                if M_AXI_AWREADY = '1' and M_AXI_WREADY = '1' then
                    next_state <= assert_bready;
                elsif M_AXI_AWREADY = '1' then
                    next_state <= wait_for_wready;
                elsif M_AXI_WREADY = '1' then
                    next_state <= wait_for_awready;
                end if;
            when wait_for_awready =>
                if M_AXI_AWREADY = '1' then
                    next_state <= assert_bready;
                end if;
            when wait_for_wready =>
                if M_AXI_WREADY = '1' then
                    next_state <= assert_bready;
                end if;
            when assert_bready =>
                if M_AXI_BVALID = '1' then
                    next_state <= wait_for_start;
                end if;
        end case;
    end process;

    output_decider : process(cur_state)
    begin
        case cur_state is
            when rst_state =>
                bresp_read          <= false;
                M_AXI_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= false;
                M_AXI_AWVALID   <= '0';
                write_data_read     <= false;
                M_AXI_WVALID    <= '0';
            when wait_for_start =>
                bresp_read          <= false;
                M_AXI_BREADY    <= '0';
                write_complete      <= '1';
                write_addr_read     <= true;
                M_AXI_AWVALID   <= '0';
                write_data_read     <= true;
                M_AXI_WVALID    <= '0';
            when wait_for_awready_wready =>
                bresp_read          <= true;
                M_AXI_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= false;
                M_AXI_AWVALID   <= '1';
                write_data_read     <= false;
                M_AXI_WVALID    <= '1';
            when wait_for_awready =>
                bresp_read          <= true;
                M_AXI_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= false;
                M_AXI_AWVALID   <= '1';
                write_data_read     <= true;
                M_AXI_WVALID    <= '0';
            when wait_for_wready =>
                bresp_read          <= true;
                M_AXI_BREADY    <= '0';
                write_complete      <= '0';
                write_addr_read     <= true;
                M_AXI_AWVALID   <= '0';
                write_data_read     <= false;
                M_AXI_WVALID    <= '1';
            when assert_bready =>
                bresp_read          <= true;
                M_AXI_BREADY    <= '1';
                write_complete      <= '0';
                write_addr_read     <= true;
                M_AXI_AWVALID   <= '0';
                write_data_read     <= true;
                M_AXI_WVALID    <= '0';
        end case;
        -- Burst length 1, see AXI spec p 46
        M_AXI_AWLEN     <= (others => '0');
        -- 4 bytes (=32bit) per burst, see AXI spec p 47
        M_AXI_AWSIZE    <= "010";
        -- Does not matter, since burst size is 1, see AXI spec p 48
        -- INCR = 0x01
        M_AXI_AWBURST   <= "01";
        -- AWCACHE and AWUSER are specific for ZYNQ
        -- There is a possibility to use the ZYNQ cache, this is ignored.
        M_AXI_AWCACHE   <= (others => '0');
        M_AXI_AWUSER    <= (others => '0');
        -- There is only one transfer, so that one is always the last
        -- See AXI4 spec p 41
        M_AXI_WLAST     <= '1';
    end process;
end Behavioral;
