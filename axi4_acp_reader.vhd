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
--    type state_type is (    rst_state, wait_for_start, wait_for_arready_rise, wait_for_arready_fall,
--                           wait_for_rvalid);
    type state_type is (rst_state);

    signal cur_state    : state_type := rst_state;
    signal next_state   : state_type := rst_state;

begin
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
    --state_decider : process(cur_state, M_AXI_ACP_ARREADY,
    --    M_AXI_ACP_RLAST, M_AXI_ACP_RVALID, read_start)
    --begin
    --    case cur_state is
    --        when rst_state =>
    --            next_state <= wait_for_start;
    --        when wait_for_start =>
    --            if read_start = '1' then
    --end process;
    -- The state decides the output
    output_decider : process(cur_state, M_AXI_ACP_RDATA, read_addr, M_AXI_ACP_RRESP)
    begin
        case cur_state is
            when rst_state =>
                read_data <= (others => '0');
                read_complete <= '0';
                read_result <= (others => '0');
                M_AXI_ACP_ARADDR <= (others => '0');
                M_AXI_ACP_ARLEN <= (others => '0');
                M_AXI_ACP_ARSIZE <= (others => '0');
                M_AXI_ACP_ARBURST <= (others => '0');
                M_AXI_ACP_ARVALID <= '0';
                M_AXI_ACP_RREADY <= '0';
        end case;
    end process;
end Behavioral;

