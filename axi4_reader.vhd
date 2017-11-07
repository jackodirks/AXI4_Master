library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity axi4_reader is
    generic (
        axi_data_width_log2b    :   natural range 5 to 255 := 5;
        axi_address_width_log2b :   natural range 5 to 255 := 6
    );
    port (
        clk                 :   in  std_logic;
        rst                 :   in  std_logic;
        read_addr           :   in  std_logic_vector(31 downto 2);
        read_data           :   out std_logic_vector(31 downto 0);
        read_start          :   in  std_logic;
        read_complete       :   out std_logic;
        read_result         :   out std_logic_vector(1 downto 0);
        --  Read address channel signals
        M_AXI_ARADDR        :   out std_logic_vector(2**axi_address_width_log2b - 1 downto 0);
        M_AXI_ARLEN         :   out std_logic_vector(3 downto 0);
        M_AXI_ARSIZE        :   out std_logic_vector(2 downto 0);
        M_AXI_ARBURST       :   out std_logic_vector(1 downto 0);
        M_AXI_ARCACHE       :   out std_logic_vector(3 downto 0);
        M_AXI_ARUSER        :   out std_logic_vector(4 downto 0);
        M_AXI_ARVALID       :   out std_logic;
        M_AXI_ARREADY       :   in  std_logic;
        -- Read data channel signals
        M_AXI_RDATA         :   in  std_logic_vector(2**axi_data_width_log2b - 1 downto 0);
        M_AXI_RRESP         :   in  std_logic_vector(1 downto 0);
        M_AXI_RLAST         :   in  std_logic;
        M_AXI_RVALID        :   in  std_logic;
        M_AXI_RREADY        :   out std_logic
    );
end axi4_reader;

ARCHITECTURE Behavioral of axi4_reader is
    type state_type is (    rst_state, wait_for_start, assert_arvalid,
                            wait_for_rvalid_rise, wait_for_rvalid_fall);
    signal cur_state            : state_type := rst_state;
    signal next_state           : state_type := rst_state;

    signal update_read_data     :   boolean := false;
    signal update_read_addr     :   boolean := false;
    signal update_read_result   :   boolean := false;

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
    state_decider : process(cur_state, M_AXI_ARREADY,
            M_AXI_RLAST, M_AXI_RVALID, read_start)
    begin
        next_state <= cur_state;
        case cur_state is
            when rst_state =>
                next_state <= wait_for_start;
            when wait_for_start =>
                if read_start = '1' then
                    next_state <= assert_arvalid;
                end if;
            when assert_arvalid =>
                if M_AXI_ARREADY = '1' then
                    next_state <= wait_for_rvalid_rise;
                end if;
            when wait_for_rvalid_rise =>
                if M_AXI_RVALID = '1' then
                    if M_AXI_RLAST = '1' then
                        next_state <= wait_for_start;
                    else
                        next_state <= wait_for_rvalid_fall;
                    end if;
                end if;
            when wait_for_rvalid_fall =>
                if M_AXI_RVALID = '0' then
                    next_state <= wait_for_rvalid_rise;
                end if;
        end case;
    end process;

    signal_store : process(clk, rst, update_read_data, update_read_addr, update_read_result)
        variable read_data_store : std_logic_vector(M_AXI_RDATA'RANGE);
        variable read_addr_store : std_logic_vector(read_addr'left downto 0);
        variable read_result_store : std_logic_vector(read_result'RANGE);
        variable shift_modifier     : natural;
    begin
        if rst = '1' then
            read_data_store := (others => '0');
            read_addr_store := (others => '0');
            read_result_store := (others => '0');
        elsif rising_edge(clk) then
            if update_read_data then
                read_data_store := M_AXI_RDATA;
            end if;
            if update_read_addr then
                read_addr_store := read_addr & "00";
            end if;
            if update_read_result then
                read_result_store := M_AXI_RRESP;
            end if;
        end if;
        if axi_data_width_log2b > 5 then
            shift_modifier  := to_integer(unsigned(read_addr_store(axi_data_width_log2b - 4 downto 2)))*4;
        else
            shift_modifier  := 0;
        end if;
        read_data       <= read_data_store(read_data'left + shift_modifier*8 downto shift_modifier*8);
        read_result     <= read_result_store;
        M_AXI_ARADDR    <= (M_AXI_ARADDR'left downto read_addr_store'left + 1 => '0') & read_addr_store(read_addr_store'left downto axi_data_width_log2b - 3) & (axi_data_width_log2b - 4 downto 0 => '0');
        -- 2**axi_data_width_log2b / 8 bytes per transfer
        M_AXI_ARSIZE    <= std_logic_vector(to_unsigned(axi_data_width_log2b - 3, M_AXI_ARSIZE'length));
    end process;

    -- The state decides the output
    output_decider : process(cur_state, M_AXI_RDATA, read_addr, M_AXI_RRESP)
    begin
        case cur_state is
            when rst_state =>
                read_complete <= '0';
                M_AXI_ARVALID <= '0';
                M_AXI_RREADY <= '0';
                update_read_data <= false;
                update_read_addr <= false;
                update_read_result <= false;
            when wait_for_start =>
                read_complete <= '1';
                M_AXI_ARVALID <= '0';
                M_AXI_RREADY <= '0';
                update_read_data <= false;
                update_read_addr <= true;
                update_read_result <= false;
            when assert_arvalid =>
                read_complete <= '0';
                M_AXI_ARVALID <= '1';
                M_AXI_RREADY <= '0';
                update_read_data <= true;
                update_read_addr <= false;
                update_read_result <= true;
            when wait_for_rvalid_rise =>
                read_complete <= '0';
                M_AXI_ARVALID <= '0';
                M_AXI_RREADY <= '1';
                update_read_data <= true;
                update_read_addr <= false;
                update_read_result <= true;
            when wait_for_rvalid_fall =>
                read_complete <= '0';
                M_AXI_ARVALID <= '0';
                M_AXI_RREADY <= '0';
                update_read_data <= true;
                update_read_addr <= false;
                update_read_result <= true;
        end case;
        -- The following signals get a default value because this is still a simple test
        -- One burst:
        M_AXI_ARLEN <= (others => '0');
        -- For the test, the burst type does not matter. Keep it at 0 (FIXED)
        M_AXI_ARBURST <= (others => '0');
        -- See tech ref page 103. ARCACHE and AWCACHE control wether or not the processor cache is involved in this transaction
        -- For now, they are set to 0, no cache involvement. In the future this feature should be added
        M_AXI_ARCACHE <= (others => '0');
        M_AXI_ARUSER <= (others => '0');

    end process;
end Behavioral;

