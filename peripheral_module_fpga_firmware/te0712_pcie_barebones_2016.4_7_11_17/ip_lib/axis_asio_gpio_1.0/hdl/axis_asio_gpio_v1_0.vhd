library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library asio_lib;
    use asio_lib.all;

entity axis_asio_gpio_v1_0 is
	generic (
		-- Users to add parameters here
        C_PORT_ADDR_WIDTH	: integer range 1 to 8 := 8; -- BIT select field width

        C_P0_BITS	: integer range 1 to 256   := 8;
        C_P1_BITS	: integer range 1 to 256   := 8;
        C_P2_BITS	: integer range 1 to 256   := 8;
        C_P3_BITS	: integer range 1 to 256   := 8;
        
        C_P0_MODE	: integer range 0 to 3   := 3;
        C_P1_MODE	: integer range 0 to 3   := 0;
        C_P2_MODE	: integer range 0 to 3   := 0;
        C_P3_MODE	: integer range 0 to 3   := 0;
        
        

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXIS
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M_AXIS
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here

        P0_o: out std_logic_vector(C_P0_BITS-1 downto 0);
        P0_t: out std_logic_vector(C_P0_BITS-1 downto 0);
        P0_i:  in std_logic_vector(C_P0_BITS-1 downto 0);
        
        P1_o: out std_logic_vector(C_P1_BITS-1 downto 0);
        P1_t: out std_logic_vector(C_P1_BITS-1 downto 0);
        P1_i:  in std_logic_vector(C_P1_BITS-1 downto 0);
        
        P2_o: out std_logic_vector(C_P2_BITS-1 downto 0);
        P2_t: out std_logic_vector(C_P2_BITS-1 downto 0);
        P2_i:  in std_logic_vector(C_P2_BITS-1 downto 0);
        
        P3_o: out std_logic_vector(C_P3_BITS-1 downto 0);
        P3_t: out std_logic_vector(C_P3_BITS-1 downto 0);
        P3_i: in std_logic_vector(C_P3_BITS-1 downto 0);
         

        asio_out : out std_logic;


		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXIS
		axis_aclk	: in std_logic;
		axis_aresetn	: in std_logic;
		
		--s_axis_tready	: out std_logic;
		s_axis_tdata	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		s_axis_tlast	: in std_logic;
		s_axis_tvalid	: in std_logic;
		s_axis_tready	: out std_logic;

		-- Ports of Axi Master Bus Interface M_AXIS
		m_axis_tvalid	: out std_logic;
		m_axis_tdata	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0) := (others=>'0');
		m_axis_tlast	: out std_logic;
		m_axis_tready	: in std_logic
	);
end axis_asio_gpio_v1_0;


architecture arch_imp of axis_asio_gpio_v1_0 is

signal P0_o_i: std_logic_vector(C_P0_BITS-1 downto 0) := (others => '1');
signal P1_o_i: std_logic_vector(C_P1_BITS-1 downto 0) := (others => '1');
signal P2_o_i: std_logic_vector(C_P2_BITS-1 downto 0) := (others => '1');
signal P3_o_i: std_logic_vector(C_P3_BITS-1 downto 0) := (others => '1');

signal P0_t_i: std_logic_vector(C_P0_BITS-1 downto 0) := (others => '1');
signal P1_t_i: std_logic_vector(C_P1_BITS-1 downto 0) := (others => '1');
signal P2_t_i: std_logic_vector(C_P2_BITS-1 downto 0) := (others => '1');
signal P3_t_i: std_logic_vector(C_P3_BITS-1 downto 0) := (others => '1');

-- input mux outputs for ports P0..P15
signal P_in: std_logic_vector(16-1 downto 0) := (others => '0');

-- Port select
signal PSEL: std_logic_vector(16-1 downto 0) := (others => '0');
-- Bit select
signal BSEL: std_logic_vector(256-1 downto 0) := (others => '0');

-- internal signals 
signal s_axis_tdata_i	 : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
signal s_axis_tvalid_i : std_logic;

signal s_axis_addrcmd_i : std_logic_vector(16-1 downto 0);
signal s_axis_data_i : std_logic_vector(16-1 downto 0);

signal asio_input_mux_i : std_logic;

signal out_flag			: STD_LOGIC;

begin
    s_axis_tdata_i <= s_axis_tdata;
    s_axis_tvalid_i <= s_axis_tvalid;
    s_axis_tready <= '1';
    
    --
    s_axis_data_i <= s_axis_tdata_i(15 downto 0);
    s_axis_addrcmd_i <= s_axis_tdata_i(31 downto 16);
    
    
--    PSEL(0) <= '1' when (s_axis_tvalid_i & s_axis_addrcmd_i(11 downto 8)) = "10000" else '0';
    PSEL(1) <= '1' when (s_axis_tvalid_i & s_axis_addrcmd_i(11 downto 8)) = "10001" else '0';
    PSEL(2) <= '1' when (s_axis_tvalid_i & s_axis_addrcmd_i(11 downto 8)) = "10010" else '0';
    PSEL(3) <= '1' when (s_axis_tvalid_i & s_axis_addrcmd_i(11 downto 8)) = "10011" else '0';

PSEL(0) <= s_axis_tvalid_i;

    
-- AAAAAAAAAAAAAAAAAAAAAA!!!!!!!!!!!!!!!!!!!!
-- BSEL_gen: for i in 0 to C_PORT_ADDR_WIDTH-1 generate
   -- begin
        -- BSEL(i) <= '1' when s_axis_addrcmd_i(C_PORT_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(i, C_PORT_ADDR_WIDTH)) else '0';
   -- end generate BSEL_gen;

BSEL_gen: for i in 0 to C_P0_BITS-1 generate	-- FIXME!!!!
begin
	BSEL(i) <= '1' when s_axis_addrcmd_i(C_PORT_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(i, C_PORT_ADDR_WIDTH)) else '0';
end generate BSEL_gen;
        

P0_gen:

	-- process(axis_aclk);
	-- begin
		-- if(axis_aclk = '1' and axis_aclk'event)then
			-- m_axis_tvalid <= out_flag;
			-- if(s_axis_tvalid_i = '1')then
				-- out_flag	<= s_axis_data_i(1);
			-- else
				-- out_flag	<= '0';
			-- end if;
		-- end if;
	-- end process;

   for i in 0 to C_P0_BITS-1 generate
   begin
        process (axis_aclk)
            begin
            if axis_aclk'event and axis_aclk='1' then  
                if axis_aresetn='0' then   
                    P0_o_i(i) <= '0';
                    P0_t_i(i) <= '1';
                elsif (PSEL(0)='1' and BSEL(i)='1') then
                    P0_o_i(i) <= s_axis_data_i(0);
                    P0_t_i(i) <= s_axis_data_i(1);
                end if;
            end if;
        end process;
   end generate P0_gen;




    P0_o <= P0_o_i;
    P1_o <= P1_o_i;
    P2_o <= P2_o_i;
    P3_o <= P3_o_i;
    
    P0_t <= P0_t_i;
    P1_t <= P1_t_i;
    P2_t <= P2_t_i;
    P3_t <= P3_t_i;
    

P0_muxin_inst: entity asio_widemux 
generic map (C_WIDTH=>C_P0_BITS,C_SEL_BITS=>C_PORT_ADDR_WIDTH) 
port map (din=>P0_i(C_P0_BITS-1 downto 0),sel=>s_axis_addrcmd_i(C_PORT_ADDR_WIDTH-1 downto 0),q=>P_in(0));
P1_muxin_inst: entity asio_widemux 
generic map (C_WIDTH=>C_P1_BITS,C_SEL_BITS=>C_PORT_ADDR_WIDTH) 
port map (din=>P1_i(C_P1_BITS-1 downto 0),sel=>s_axis_addrcmd_i(C_PORT_ADDR_WIDTH-1 downto 0),q=>P_in(1));
P2_muxin_inst: entity asio_widemux 
generic map (C_WIDTH=>C_P2_BITS,C_SEL_BITS=>C_PORT_ADDR_WIDTH) 
port map (din=>P2_i(C_P2_BITS-1 downto 0),sel=>s_axis_addrcmd_i(C_PORT_ADDR_WIDTH-1 downto 0),q=>P_in(2));
P3_muxin_inst: entity asio_widemux 
generic map (C_WIDTH=>C_P3_BITS,C_SEL_BITS=>C_PORT_ADDR_WIDTH) 
port map (din=>P3_i(C_P3_BITS-1 downto 0),sel=>s_axis_addrcmd_i(C_PORT_ADDR_WIDTH-1 downto 0),q=>P_in(3));




-- P_muxin_inst: entity asio_widemux 
-- generic map (
	-- C_WIDTH		=>16,
	-- C_SEL_BITS	=>4
-- ) 
-- port map (
	-- din			=> P_in(16-1 downto 0),
	-- sel			=> s_axis_addrcmd_i(11 downto 8),
	-- q			=> asio_input_mux_i
-- );
asio_input_mux_i	<= P_in(0);

asio_out <= asio_input_mux_i;
m_axis_tdata(0) <= asio_input_mux_i;

m_axis_tvalid <= '1';

end arch_imp;
