library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi4_master is
    generic (
        axi_data_width_log2b    :   natural range 5 to 255 := 6;
        axi_address_width_log2b :   natural range 5 to 255 := 5
    );
    port (
        clk                 :   in  std_logic;
        rst                 :   in  std_logic;
        write_addr          :   in  std_logic_vector(31 downto 2);
        write_data          :   in  std_logic_vector(31 downto 0);
        read_addr           :   in  std_logic_vector(31 downto 2);
        read_data           :   out std_logic_vector(31 downto 0);
        write_start         :   in  std_logic;
        write_complete      :   out std_logic;
        write_result        :   out std_logic_vector(1 downto 0);
        write_mask          :   in  std_logic_vector(3 downto 0);
        read_start          :   in  std_logic;
        read_complete       :   out std_logic;
        read_result         :   out std_logic_vector(1 downto 0);
        -- Global Signals
        M_AXI_ACLK          :   out std_logic;
        -- No reset
        -- Write address channel signals
        M_AXI_AWID          :   out std_logic_vector(2 DOWNTO 0);
        M_AXI_AWADDR        :   out std_logic_vector(2**axi_address_width_log2b - 1 downto 0);
        M_AXI_AWLEN         :   out std_logic_vector(3 downto 0);
        M_AXI_AWSIZE        :   out std_logic_vector(2 downto 0);
        M_AXI_AWBURST       :   out std_logic_vector(1 downto 0);
        M_AXI_AWLOCK        :   out std_logic_vector(1 downto 0);
        M_AXI_AWCACHE       :   out std_logic_vector(3 downto 0);
        M_AXI_AWPROT        :   out std_logic_vector(2 downto 0);
        M_AXI_AWQOS         :   out std_logic_vector(3 downto 0);
        M_AXI_AWUSER        :   out std_logic_vector(4 downto 0);
        M_AXI_AWVALID       :   out std_logic;
        M_AXI_AWREADY       :   in  std_logic;
        -- Write data channel signals
        M_AXI_WID           :   out std_logic_vector(2 downto 0);
        M_AXI_WDATA         :   out std_logic_vector(2**axi_data_width_log2b - 1 downto 0);
        M_AXI_WSTRB         :   out std_logic_vector(2**(axi_data_width_log2b - 3) - 1 downto 0);
        M_AXI_WLAST         :   out std_logic;
        M_AXI_WVALID        :   out std_logic;
        M_AXI_WREADY        :   in  std_logic;
        --  Write response channel signals
        M_AXI_BID           :   in  std_logic_vector(2 downto 0);
        M_AXI_BRESP         :   in  std_logic_vector(1 downto 0);
        M_AXI_BVALID        :   in  std_logic;
        M_AXI_BREADY        :   out std_logic;
        --  Read address channel signals
        M_AXI_ARID          :   out std_logic_vector(2 downto 0);
        M_AXI_ARADDR        :   out std_logic_vector(2**axi_address_width_log2b - 1 downto 0);
        M_AXI_ARLEN         :   out std_logic_vector(3 downto 0);
        M_AXI_ARSIZE        :   out std_logic_vector(2 downto 0);
        M_AXI_ARBURST       :   out std_logic_vector(1 downto 0);
        M_AXI_ARLOCK        :   out std_logic_vector(1 downto 0);
        M_AXI_ARCACHE       :   out std_logic_vector(3 downto 0);
        M_AXI_ARPROT        :   out std_logic_vector(2 downto 0);
        M_AXI_ARQOS         :   out std_logic_vector(3 downto 0);
        M_AXI_ARUSER        :   out std_logic_vector(4 downto 0);
        M_AXI_ARVALID       :   out std_logic;
        M_AXI_ARREADY       :   in  std_logic;
        -- Read data channel signals
        M_AXI_RID           :   in  std_logic_vector(2 downto 0);
        M_AXI_RDATA         :   in  std_logic_vector(2**axi_data_width_log2b - 1 downto 0);
        M_AXI_RRESP         :   in  std_logic_vector(1 downto 0);
        M_AXI_RLAST         :   in  std_logic;
        M_AXI_RVALID        :   in  std_logic;
        M_AXI_RREADY        :   out std_logic
    );
end axi4_master;

architecture Behavioral of axi4_master is
begin
    M_AXI_ACLK <= clk;
    -- Drive all QOS to 0 to equalize read and write priority, see technical ref man p 132
    M_AXI_AWQOS <= (others => '0');
    M_AXI_ARQOS <= (others => '0');
    -- AWLOCK and ARLOCK are ignored in AXI4, see AXI protocol spec p 99
    M_AXI_AWLOCK <= (others => '0');
    M_AXI_ARLOCK <= (others => '0');
    -- AWPROT and ARPROT. Bits 0 and 2 are unused (tech ref man p 297).
    -- Bit 1 is about ARM trust zone. Trust zone document page 7 seems to imply 0 is ok.
    M_AXI_AWPROT <= (others => '0');
    M_AXI_ARPROT <= (others => '0');
    -- The ID's are used to determine some form of ordering, see AXI protocol page 80.
    -- If all ID's are equal, we force an order in time.
    -- I suppose that is what we want here, so set all ID's to all zero
    M_AXI_AWID <= (others => '0');
    M_AXI_WID <= (others => '0');
    M_AXI_ARID <= (others => '0');
    -- Instantiate the writer
    writer : entity work.axi4_writer
    generic map (
        axi_data_width_log2b    => axi_data_width_log2b,
        axi_address_width_log2b => axi_address_width_log2b
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        write_addr          => write_addr,
        write_data          => write_data,
        write_start         => write_start,
        write_complete      => write_complete,
        write_result        => write_result,
        write_mask          => write_mask,
        M_AXI_AWADDR        => M_AXI_AWADDR,
        M_AXI_AWLEN         => M_AXI_AWLEN,
        M_AXI_AWSIZE        => M_AXI_AWSIZE,
        M_AXI_AWBURST       => M_AXI_AWBURST,
        M_AXI_AWCACHE       => M_AXI_AWCACHE,
        M_AXI_AWUSER        => M_AXI_AWUSER,
        M_AXI_AWVALID       => M_AXI_AWVALID,
        M_AXI_AWREADY       => M_AXI_AWREADY,
        M_AXI_WDATA         => M_AXI_WDATA,
        M_AXI_WSTRB         => M_AXI_WSTRB,
        M_AXI_WLAST         => M_AXI_WLAST,
        M_AXI_WVALID        => M_AXI_WVALID,
        M_AXI_WREADY        => M_AXI_WREADY,
        M_AXI_BRESP         => M_AXI_BRESP,
        M_AXI_BVALID        => M_AXI_BVALID,
        M_AXI_BREADY        => M_AXI_BREADY
    );
    -- Instantiate the reader
    reader : entity work.axi4_reader
    generic map (
        axi_data_width_log2b    => axi_data_width_log2b,
        axi_address_width_log2b => axi_address_width_log2b
    )
    port map (
        clk                     => clk,
        rst                     => rst,
        read_addr               => read_addr,
        read_data               => read_data,
        read_start              => read_start,
        read_complete           => read_complete,
        read_result             => read_result,
        M_AXI_ARADDR            => M_AXI_ARADDR,
        M_AXI_ARLEN             => M_AXI_ARLEN,
        M_AXI_ARSIZE            => M_AXI_ARSIZE,
        M_AXI_ARBURST           => M_AXI_ARBURST,
        M_AXI_ARCACHE           => M_AXI_ARCACHE,
        M_AXI_ARUSER            => M_AXI_ARUSER,
        M_AXI_ARVALID           => M_AXI_ARVALID,
        M_AXI_ARREADY           => M_AXI_ARREADY,
        M_AXI_RDATA             => M_AXI_RDATA,
        M_AXI_RRESP             => M_AXI_RRESP,
        M_AXI_RLAST             => M_AXI_RLAST,
        M_AXI_RVALID            => M_AXI_RVALID,
        M_AXI_RREADY            => M_AXI_RREADY
    );
end Behavioral;
