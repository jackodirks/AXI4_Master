library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi4_acp_reader is
    port (
        clk                 :   in  std_logic;
        rst                 :   in  std_logic;
        read_addr           :   in  std_logic_vector(31 downto 0);
        read_data           :   out std_logic_vector(31 downto 0);
        read_start          :   in  std_logic;
        read_complete       :   out std_logic;
        read_result         :   out std_logic_vector(1 downto 0);
        --  Read address channel signals
        M_AXI_ACP_ARADDR    :   out std_logic_vector(31 downto 0);
        M_AXI_ACP_ARLEN     :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_ARSIZE    :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_ARBURST   :   out std_logic_vector(1 downto 0);
        M_AXI_ACP_ARVALID   :   out std_logic;
        M_AXI_ACP_ARREADY   :   in  std_logic;
        -- Read data channel signals
        M_AXI_ACP_RDATA     :   in  std_logic_vector(63 downto 0);
        M_AXI_ACP_RRESP     :   in  std_logic_vector(1 downto 0);
        M_AXI_ACP_RLAST     :   in  std_logic;
        M_AXI_ACP_RVALID    :   in  std_logic;
        M_AXI_ACP_RREADY    :   out std_logic
    );
end axi4_acp_reader;

ARCHITECTURE Behavioral of axi4_acp_reader is
    type state_type is (    rst_state, wait_for_start, wait_for_arready_rise, wait_for_arready_fall,
                            wait_for_rvalid_rise, wait_for_rvalid_fall);
    signal cur_state    : state_type := rst_state;
    signal next_state   : state_type := rst_state;

begin
    -- Traps rvalid
    -- Handles the cur_state variable
    sync_proc : process(clk, rst)
    begin
        if rst = '1' then
            cur_state <= rst_state;
        elsif rising_edge(clk) then
            cur_state <= next_state;
        end if;
    end process;

    -- handles the next_state variable
    state_decider : process(cur_state, M_AXI_ACP_ARREADY,
            M_AXI_ACP_RLAST, M_AXI_ACP_RVALID, read_start)
        variable rlast : std_logic := '0';
    begin
        next_state <= cur_state;
        case cur_state is
            when rst_state =>
                RLAST := '0';
                next_state <= wait_for_start;
            when wait_for_start =>
                if read_start = '1' then
                    if M_AXI_ACP_ARREADY = '1' then
                        next_state <= wait_for_arready_fall;
                    else
                        next_state <= wait_for_arready_rise;
                    end if;
                end if;
            when wait_for_arready_rise =>
                if M_AXI_ACP_ARREADY = '1' then
                    next_state <= wait_for_arready_fall;
                end if;
            when wait_for_arready_fall =>
                if M_AXI_ACP_ARREADY = '0' then
                    if M_AXI_ACP_RVALID = '1' then
                        next_state <= wait_for_rvalid_fall;
                    else
                        next_state <= wait_for_rvalid_rise;
                    end if;
                end if;
            when wait_for_rvalid_rise =>
                if M_AXI_ACP_RVALID = '1' then
                    next_state <= wait_for_rvalid_rise;
                end if;
            when wait_for_rvalid_fall =>
                if M_AXI_ACP_RLAST = '1' then
                    rlast := '1';
                end if;
                if M_AXI_ACP_RVALID = '0' then
                    if rlast = '1' then
                        next_state <= wait_for_rvalid_rise;
                    else
                        next_state <= wait_for_start;
                    end if;
                end if;
        end case;
    end process;
    -- The state decides the output
    output_decider : process(cur_state, M_AXI_ACP_RDATA, read_addr, M_AXI_ACP_RRESP)
        variable read_data_store : std_logic_vector(read_data'RANGE) := (others => '0');
        variable read_addr_store : std_logic_vector(read_addr'RANGE) := (others => '0');
        variable read_result_store : std_logic_vector(read_result'RANGE) := (others => '0');
    begin
        case cur_state is
            when rst_state =>
                read_data_store := (others => '0');
                read_addr_store := (others => '0');
                read_result_store := (others => '0');
                read_complete <= '0';
                M_AXI_ACP_ARVALID <= '0';
                M_AXI_ACP_RREADY <= '0';
            when wait_for_start =>
                read_addr_store := read_addr;
                read_complete <= '1';
                M_AXI_ACP_ARVALID <= '0';
                M_AXI_ACP_RREADY <= '0';
            when wait_for_arready_rise =>
                read_complete <= '0';
                M_AXI_ACP_ARVALID <= '1';
                M_AXI_ACP_RREADY <= '0';
            when wait_for_arready_fall =>
                read_complete <= '0';
                M_AXI_ACP_ARVALID <= '1';
                M_AXI_ACP_RREADY <= '1';
            when wait_for_rvalid_rise =>
                read_complete <= '0';
                M_AXI_ACP_ARVALID <= '0';
                M_AXI_ACP_RREADY <= '1';
            when wait_for_rvalid_fall =>
                read_data_store := M_AXI_ACP_RDATA(31 DOWNTO 0);
                read_result_store := M_AXI_ACP_RRESP;
                read_complete <= '1';
                M_AXI_ACP_ARVALID <= '0';
                M_AXI_ACP_RREADY <= '0';
        end case;
        read_data <= read_data_store;
        read_result <= read_result_store;
        M_AXI_ACP_ARADDR <= read_addr_store;
        -- The following signals get a default value because this is still a simple test
        -- One burst:
        M_AXI_ACP_ARLEN <= (others => '0');
        -- 4 bytes in transfer
        M_AXI_ACP_ARSIZE <= "010";
        -- For the test, the burst type does not matter. Keep it at 0 (FIXED)
        M_AXI_ACP_ARBURST <= (others => '0');

    end process;
end Behavioral;

