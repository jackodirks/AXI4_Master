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
    type state_type is (rst_state);

    signal cur_state    : state_type := rst_state;
    signal next_state   : state_type := rst_state;

begin
    state_transition : process(clk, rst)
    begin
        if rst = '1' then
            cur_state <= rst_state;
            next_state <= rst_state;
        elsif rising_edge(clk) then
            cur_state <= next_state;
        end if;
    end process;

    output_decider : process(cur_state, write_addr, M_AXI_ACP_AWREADY, M_AXI_ACP_WREADY, M_AXI_ACP_BRESP, M_AXI_ACP_BVALID)
    begin
        case cur_state is
            when rst_state =>
                write_complete <= '0';
                write_result <= (others => '0');
                M_AXI_ACP_AWADDR <= (others => '0');
                M_AXI_ACP_AWLEN <= (others => '0');
                M_AXI_ACP_AWSIZE <= (others => '0');
                M_AXI_ACP_AWBURST <= (others => '0');
                M_AXI_ACP_AWVALID <= '0';
                M_AXI_ACP_WDATA <= (others => '0');
                M_AXI_ACP_WSTRB <= (others => '0');
                M_AXI_ACP_WLAST <= '0';
                M_AXI_ACP_WVALID <= '0';
                M_AXI_ACP_BREADY <= '0';
        end case;
    end process;
end Behavioral;
