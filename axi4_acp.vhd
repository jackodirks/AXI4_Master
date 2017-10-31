library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi4_acp_master is
    port (
        clk                 :   in  std_logic;
        rst                 :   in  std_logic;
        write_addr          :   in  std_logic_vector(31 downto 0);
        write_data          :   in  std_logic_vector(31 downto 0);
        read_addr           :   in  std_logic_vector(31 downto 0);
        read_data           :   out std_logic_vector(31 downto 0);
        write_start         :   in  std_logic;
        write_complete      :   out std_logic;
        write_result        :   out std_logic_vector(1 downto 0);
        read_start          :   in  std_logic;
        read_complete       :   out std_logic;
        read_result         :   out std_logic_vector(1 downto 0);
        -- Global Signals
        M_AXI_ACP_ACLK      :   out std_logic;
        -- No reset
        -- Write address channel signals
        M_AXI_ACP_AWID      :   out std_logic_vector(2 DOWNTO 0);
        M_AXI_ACP_AWADDR    :   out std_logic_vector(31 downto 0);
        M_AXI_ACP_AWLEN     :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_AWSIZE    :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_AWBURST   :   out std_logic_vector(1 downto 0);
        M_AXI_ACP_AWLOCK    :   out std_logic_vector(1 downto 0);
        M_AXI_ACP_AWCACHE   :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_AWPROT    :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_AWQOS     :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_AWUSER    :   out std_logic_vector(4 downto 0);
        M_AXI_ACP_AWVALID   :   out std_logic;
        M_AXI_ACP_AWREADY   :   in  std_logic;
        -- Write data channel signals
        M_AXI_ACP_WID       :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_WDATA     :   out std_logic_vector(63 downto 0);
        M_AXI_ACP_WSTRB     :   out std_logic_vector(7 downto 0);
        M_AXI_ACP_WLAST     :   out std_logic;
        M_AXI_ACP_WVALID    :   out std_logic;
        M_AXI_ACP_WREADY    :   in  std_logic;
        --  Write response channel signals
        M_AXI_ACP_BID       :   in  std_logic_vector(2 downto 0);
        M_AXI_ACP_BRESP     :   in  std_logic_vector(1 downto 0);
        M_AXI_ACP_BVALID    :   in  std_logic;
        M_AXI_ACP_BREADY    :   out std_logic;
        --  Read address channel signals
        M_AXI_ACP_ARID      :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_ARADDR    :   out std_logic_vector(31 downto 0);
        M_AXI_ACP_ARLEN     :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_ARSIZE    :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_ARBURST   :   out std_logic_vector(1 downto 0);
        M_AXI_ACP_ARLOCK    :   out std_logic_vector(1 downto 0);
        M_AXI_ACP_ARCACHE   :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_ARPROT    :   out std_logic_vector(2 downto 0);
        M_AXI_ACP_ARQOS     :   out std_logic_vector(3 downto 0);
        M_AXI_ACP_ARUSER    :   out std_logic_vector(4 downto 0);
        M_AXI_ACP_ARVALID   :   out std_logic;
        M_AXI_ACP_ARREADY   :   in  std_logic;
        -- Read data channel signals
        M_AXI_ACP_RID       :   in  std_logic_vector(2 downto 0);
        M_AXI_ACP_RDATA     :   in  std_logic_vector(63 downto 0);
        M_AXI_ACP_RRESP     :   in  std_logic_vector(1 downto 0);
        M_AXI_ACP_RLAST     :   in  std_logic;
        M_AXI_ACP_RVALID    :   in  std_logic;
        M_AXI_ACP_RREADY    :   out std_logic
    );
end axi4_acp_master;

architecture Behavioral of axi4_acp_master is
begin
    M_AXI_ACP_ACLK <= clk;
    -- Drive all QOS to 0 to equalize read and write priority, see technical ref man p 132
    M_AXI_ACP_AWQOS <= (others => '0');
    M_AXI_ACP_ARQOS <= (others => '0');
    -- AWLOCK and ARLOCK are ignored in AXI4, see AXI protocol spec p 99
    M_AXI_ACP_AWLOCK <= (others => '0');
    M_AXI_ACP_ARLOCK <= (others => '0');
    -- AWPROT and ARPROT. Bits 0 and 2 are unused (tech ref man p 297).
    -- Bit 1 is about ARM trust zone. Trust zone document page 7 seems to imply 0 is ok.
    M_AXI_ACP_AWPROT <= (others => '0');
    M_AXI_ACP_ARPROT <= (others => '0');
    -- The ID's are used to determine some form of ordering, see AXI protocol page 80.
    -- If all ID's are equal, we force an order in time.
    -- I suppose that is what we want here, so set all ID's to all zero
    M_AXI_ACP_AWID <= (others => '0');
    M_AXI_ACP_WID <= (others => '0');
    M_AXI_ACP_ARID <= (others => '0');
    -- Instantiate the writer
    writer : entity work.axi4_acp_writer
    port map (
        clk                 => clk,
        rst                 => rst,
        write_addr          => write_addr,
        write_data          => write_data,
        write_start         => write_start,
        write_complete      => write_complete,
        write_result        => write_result,
        M_AXI_ACP_AWADDR    => M_AXI_ACP_AWADDR,
        M_AXI_ACP_AWLEN     => M_AXI_ACP_AWLEN,
        M_AXI_ACP_AWSIZE    => M_AXI_ACP_AWSIZE,
        M_AXI_ACP_AWBURST   => M_AXI_ACP_AWBURST,
        M_AXI_ACP_AWCACHE   => M_AXI_ACP_AWCACHE,
        M_AXI_ACP_AWUSER    => M_AXI_ACP_AWUSER,
        M_AXI_ACP_AWVALID   => M_AXI_ACP_AWVALID,
        M_AXI_ACP_AWREADY   => M_AXI_ACP_AWREADY,
        M_AXI_ACP_WDATA     => M_AXI_ACP_WDATA,
        M_AXI_ACP_WSTRB     => M_AXI_ACP_WSTRB,
        M_AXI_ACP_WLAST     => M_AXI_ACP_WLAST,
        M_AXI_ACP_WVALID    => M_AXI_ACP_WVALID,
        M_AXI_ACP_WREADY    => M_AXI_ACP_WREADY,
        M_AXI_ACP_BRESP     => M_AXI_ACP_BRESP,
        M_AXI_ACP_BVALID    => M_AXI_ACP_BVALID,
        M_AXI_ACP_BREADY    => M_AXI_ACP_BREADY
    );
    -- Instantiate the reader
    reader : entity work.axi4_acp_reader
    port map (
        clk                 => clk,
        rst                 => rst,
        read_addr           => read_addr,
        read_data           => read_data,
        read_start          => read_start,
        read_complete       => read_complete,
        read_result         => read_result,
        M_AXI_ACP_ARADDR    => M_AXI_ACP_ARADDR,
        M_AXI_ACP_ARLEN     => M_AXI_ACP_ARLEN,
        M_AXI_ACP_ARSIZE    => M_AXI_ACP_ARSIZE,
        M_AXI_ACP_ARBURST   => M_AXI_ACP_ARBURST,
        M_AXI_ACP_ARCACHE   => M_AXI_ACP_ARCACHE,
        M_AXI_ACP_ARUSER    => M_AXI_ACP_ARUSER,
        M_AXI_ACP_ARVALID   => M_AXI_ACP_ARVALID,
        M_AXI_ACP_ARREADY   => M_AXI_ACP_ARREADY,
        M_AXI_ACP_RDATA     => M_AXI_ACP_RDATA,
        M_AXI_ACP_RRESP     => M_AXI_ACP_RRESP,
        M_AXI_ACP_RLAST     => M_AXI_ACP_RLAST,
        M_AXI_ACP_RVALID    => M_AXI_ACP_RVALID,
        M_AXI_ACP_RREADY    => M_AXI_ACP_RREADY
    );
end Behavioral;
