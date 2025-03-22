LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY axi_id_mapper IS
	GENERIC (

		-- ENFORCEMENT GENERICS
		-- Thread ID Width
		C_M_AXI_ID_WIDTH : INTEGER := 6;
		-- Width of User Write Address Bus
		C_M_AXI_AWUSER_WIDTH : INTEGER := 10;
		-- Width of User Read Address Bus
		C_M_AXI_ARUSER_WIDTH : INTEGER := 10;
		-- AXI ID Mapper constants
		MASTERS_NUMBER : POSITIVE := 2;
		POOL_SIZE : POSITIVE := 6;
		READ_BURST_BUFFER_SIZE : POSITIVE := 8;
		READ_REQ_BUFFER_SIZE : POSITIVE := 8;
		WRITE_BURST_BUFFER_SIZE : POSITIVE := 8;
		WRITE_RSP_BUFFER_SIZE : POSITIVE := 8;
		WRITE_REQ_BUFFER_SIZE : POSITIVE := 8;

		-- each generic represents the mapping for the corresponding lut. E.g. if NMaster is set 5, there will be 5 LUTs of index 0 to 4 (the first 4 maps)
		-- AXUSER map, the maximum number of masters that can be isolated is 32
		AXUSER_MAP0 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP1 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP2 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP3 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP4 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP5 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP6 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP7 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP8 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP9 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP10 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP11 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP12 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP13 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP14 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP15 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP16 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP17 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP18 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP19 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP20 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP21 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP22 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP23 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP24 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP25 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP26 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP27 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP28 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP29 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP30 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";
		AXUSER_MAP31 : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";

		-- OTHER GENERICS
		-- Width of Address Bus
		C_M_AXI_ADDR_WIDTH : INTEGER := 32;
		-- Width of Data Bus
		C_M_AXI_DATA_WIDTH : INTEGER := 32;
		-- Width of User Write Data Bus
		C_M_AXI_WUSER_WIDTH : INTEGER := 0;
		-- Width of User Read Data Bus
		C_M_AXI_RUSER_WIDTH : INTEGER := 0;
		-- Width of User Response Bus
		C_M_AXI_BUSER_WIDTH : INTEGER := 0
	);
	PORT (

		--- MASTER PORTS ----

		-- Global Clock Signal.
		aclk : IN STD_LOGIC;
		-- Global Reset Singal. This Signal is Active Low
		aresetn : IN STD_LOGIC;
		-- interrupt
		introut : OUT STD_LOGIC;
		-- Master Interface Write Address ID
		M_AXI_AWID : OUT STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
		-- Master Interface Write Address
		M_AXI_AWADDR : OUT STD_LOGIC_VECTOR(C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0);
		-- Burst length. The burst length gives the exact number of transfers in a burst
		M_AXI_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- Burst size. This signal indicates the size of each transfer in the burst
		M_AXI_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Burst type. The burst type and the size information, 
		-- determine how the address for each transfer within the burst is calculated.
		M_AXI_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Lock type. Provides additional information about the
		-- atomic characteristics of the transfer.
		M_AXI_AWLOCK : OUT STD_LOGIC;
		-- Memory type. This signal indicates how transactions
		-- are required to progress through a system.
		M_AXI_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Protection type. This signal indicates the privilege
		-- and security level of the transaction, and whether
		-- the transaction is a data access or an instruction access.
		M_AXI_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Quality of Service, QoS identifier sent for each write transaction.
		M_AXI_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Write address valid. This signal indicates that
		-- the channel is signaling valid write address and control information.
		M_AXI_AWVALID : OUT STD_LOGIC;
		-- Write address ready. This signal indicates that
		-- the slave is ready to accept an address and associated control signals
		M_AXI_AWREADY : IN STD_LOGIC;
		-- Master Interface Write Data.
		M_AXI_WDATA : OUT STD_LOGIC_VECTOR(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
		-- Write strobes. This signal indicates which byte
		-- lanes hold valid data. There is one write strobe
		-- bit for each eight bits of the write data bus.
		M_AXI_WSTRB : OUT STD_LOGIC_VECTOR(C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0);
		-- Write last. This signal indicates the last transfer in a write burst.
		M_AXI_WLAST : OUT STD_LOGIC := '0';
		-- Optional User-defined signal in the write data channel.
		--M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
		-- Write valid. This signal indicates that valid write
		-- data and strobes are available
		M_AXI_WVALID : OUT STD_LOGIC;
		-- Write ready. This signal indicates that the slave
		-- can accept the write data.
		M_AXI_WREADY : IN STD_LOGIC;
		-- Master Interface Write Response.
		M_AXI_BID : IN STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
		-- Write response. This signal indicates the status of the write transaction.
		M_AXI_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Optional User-defined signal in the write response channel
		-- M_AXI_BUSER	: in std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
		-- Write response valid. This signal indicates that the
		-- channel is signaling a valid write response.
		M_AXI_BVALID : IN STD_LOGIC;
		-- Response ready. This signal indicates that the master
		-- can accept a write response.
		M_AXI_BREADY : OUT STD_LOGIC;
		-- Master Interface Read Address.
		M_AXI_ARID : OUT STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
		-- Read address. This signal indicates the initial
		-- address of a read burst transaction.
		M_AXI_ARADDR : OUT STD_LOGIC_VECTOR(C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0);
		-- Burst length. The burst length gives the exact number of transfers in a burst
		M_AXI_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- Burst size. This signal indicates the size of each transfer in the burst
		M_AXI_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Burst type. The burst type and the size information, 
		-- determine how the address for each transfer within the burst is calculated.
		M_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Lock type. Provides additional information about the
		-- atomic characteristics of the transfer.
		M_AXI_ARLOCK : OUT STD_LOGIC;
		-- Memory type. This signal indicates how transactions
		-- are required to progress through a system.
		M_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Protection type. This signal indicates the privilege
		-- and security level of the transaction, and whether
		-- the transaction is a data access or an instruction access.
		M_AXI_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Quality of Service, QoS identifier sent for each read transaction
		M_AXI_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Write address valid. This signal indicates that
		-- the channel is signaling valid read address and control information
		M_AXI_ARVALID : OUT STD_LOGIC;
		-- Read address ready. This signal indicates that
		-- the slave is ready to accept an address and associated control signals
		M_AXI_ARREADY : IN STD_LOGIC;
		-- Read ID tag. This signal is the identification tag
		-- for the read data group of signals generated by the slave.
		M_AXI_RID : IN STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
		-- Master Read Data
		M_AXI_RDATA : IN STD_LOGIC_VECTOR(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
		-- Read response. This signal indicates the status of the read transfer
		M_AXI_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Read last. This signal indicates the last transfer in a read burst
		M_AXI_RLAST : IN STD_LOGIC;
		-- Optional User-defined signal in the read address channel.
		--M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
		-- Read valid. This signal indicates that the channel
		-- is signaling the required read data.
		M_AXI_RVALID : IN STD_LOGIC;
		-- Read ready. This signal indicates that the master can
		-- accept the read data and response information.
		M_AXI_RREADY : OUT STD_LOGIC;

		-- ---- MASTER INVERTED PORTS ----

		-- Master Interface Write Address ID
		S_AXI_AWID : IN STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
		-- Master Interface Write Address
		S_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0);
		-- Burst length. The burst length gives the exact number of transfers in a burst
		S_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- Burst size. This signal indicates the size of each transfer in the burst
		S_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Burst type. The burst type and the size information, 
		-- determine how the address for each transfer within the burst is calculated.
		S_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Lock type. Provides additional information about the
		-- atomic characteristics of the transfer.
		S_AXI_AWLOCK : IN STD_LOGIC;
		-- Memory type. This signal indicates how transactions
		-- are required to progress through a system.
		S_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Protection type. This signal indicates the privilege
		-- and security level of the transaction, and whether
		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Quality of Service, QoS identifier sent for each write transaction.
		S_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Optional User-defined signal in the write address channel.
		S_AXI_AWUSER : IN STD_LOGIC_VECTOR(C_M_AXI_AWUSER_WIDTH - 1 DOWNTO 0);
		-- Write address valid. This signal indicates that
		-- the channel is signaling valid write address and control information.
		S_AXI_AWVALID : IN STD_LOGIC;
		-- Write address ready. This signal indicates that
		-- the slave is ready to accept an address and associated control signals
		S_AXI_AWREADY : OUT STD_LOGIC;
		-- Master Interface Write Data.
		S_AXI_WDATA : IN STD_LOGIC_VECTOR(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
		-- Write strobes. This signal indicates which byte
		-- lanes hold valid data. There is one write strobe
		-- bit for each eight bits of the write data bus.
		S_AXI_WSTRB : IN STD_LOGIC_VECTOR(C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0);
		-- Write last. This signal indicates the last transfer in a write burst.
		S_AXI_WLAST : IN STD_LOGIC;
		-- Optional User-defined signal in the write data channel.
		--S_AXI_WUSER	: in std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
		-- Write valid. This signal indicates that valid write
		-- data and strobes are available
		S_AXI_WVALID : IN STD_LOGIC;
		-- Write ready. This signal indicates that the slave
		-- can accept the write data.
		S_AXI_WREADY : OUT STD_LOGIC := '1';
		-- Master Interface Write Response.
		S_AXI_BID : OUT STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
		-- Write response. This signal indicates the status of the write transaction.
		S_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Optional User-defined signal in the write response channel
		--S_AXI_BUSER	: out std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
		-- Write response valid. This signal indicates that the
		-- channel is signaling a valid write response.
		S_AXI_BVALID : OUT STD_LOGIC;
		-- Response ready. This signal indicates that the master
		-- can accept a write response.
		S_AXI_BREADY : IN STD_LOGIC;
		-- Master Interface Read Address.
		S_AXI_ARID : IN STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
		-- Read address. This signal indicates the initial
		-- address of a read burst transaction.
		S_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0);
		-- Burst length. The burst length gives the exact number of transfers in a burst
		S_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		-- Burst size. This signal indicates the size of each transfer in the burst
		S_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Burst type. The burst type and the size information, 
		-- determine how the address for each transfer within the burst is calculated.
		S_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Lock type. Provides additional information about the
		-- atomic characteristics of the transfer.
		S_AXI_ARLOCK : IN STD_LOGIC;
		-- Memory type. This signal indicates how transactions
		-- are required to progress through a system.
		S_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Protection type. This signal indicates the privilege
		-- and security level of the transaction, and whether
		-- the transaction is a data access or an instruction access.
		S_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Quality of Service, QoS identifier sent for each read transaction
		S_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Optional User-defined signal in the read address channel.
		S_AXI_ARUSER : IN STD_LOGIC_VECTOR(C_M_AXI_ARUSER_WIDTH - 1 DOWNTO 0);
		-- Write address valid. This signal indicates that
		-- the channel is signaling valid read address and control information
		S_AXI_ARVALID : IN STD_LOGIC;
		-- Read address ready. This signal indicates that
		-- the slave is ready to accept an address and associated control signals
		S_AXI_ARREADY : OUT STD_LOGIC;
		-- Read ID tag. This signal is the identification tag
		-- for the read data group of signals generated by the slave.
		S_AXI_RID : OUT STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
		-- Master Read Data
		S_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
		-- Read response. This signal indicates the status of the read transfer
		S_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Read last. This signal indicates the last transfer in a read burst
		S_AXI_RLAST : OUT STD_LOGIC;
		-- Optional User-defined signal in the read address channel.
		--S_AXI_RUSER	: out std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
		-- Read valid. This signal indicates that the channel
		-- is signaling the required read data.
		S_AXI_RVALID : OUT STD_LOGIC;
		-- Read ready. This signal indicates that the master can
		-- accept the read data and response information.
		S_AXI_RREADY : IN STD_LOGIC
	);
END ENTITY axi_id_mapper;

ARCHITECTURE implementation OF axi_id_mapper IS

	-- functions --
	-- select mapping AXUSER
	FUNCTION select_mapping_axuser(input_axuser : STD_LOGIC_VECTOR) RETURN INTEGER IS
	BEGIN
		IF input_axuser = AXUSER_MAP0 AND MASTERS_NUMBER > 0 THEN
			RETURN 0;
		ELSIF input_axuser = AXUSER_MAP1 AND MASTERS_NUMBER > 1 THEN
			RETURN 1;
		ELSIF input_axuser = AXUSER_MAP2 AND MASTERS_NUMBER > 2 THEN
			RETURN 2;
		ELSIF input_axuser = AXUSER_MAP3 AND MASTERS_NUMBER > 3 THEN
			RETURN 3;
		ELSIF input_axuser = AXUSER_MAP4 AND MASTERS_NUMBER > 4 THEN
			RETURN 4;
		ELSIF input_axuser = AXUSER_MAP5 AND MASTERS_NUMBER > 5 THEN
			RETURN 5;
		ELSIF input_axuser = AXUSER_MAP6 AND MASTERS_NUMBER > 6 THEN
			RETURN 6;
		ELSIF input_axuser = AXUSER_MAP7 AND MASTERS_NUMBER > 7 THEN
			RETURN 7;
		ELSIF input_axuser = AXUSER_MAP8 AND MASTERS_NUMBER > 8 THEN
			RETURN 8;
		ELSIF input_axuser = AXUSER_MAP9 AND MASTERS_NUMBER > 9 THEN
			RETURN 9;
		ELSIF input_axuser = AXUSER_MAP10 AND MASTERS_NUMBER > 10 THEN
			RETURN 10;
		ELSIF input_axuser = AXUSER_MAP11 AND MASTERS_NUMBER > 11 THEN
			RETURN 11;
		ELSIF input_axuser = AXUSER_MAP12 AND MASTERS_NUMBER > 12 THEN
			RETURN 12;
		ELSIF input_axuser = AXUSER_MAP13 AND MASTERS_NUMBER > 13 THEN
			RETURN 13;
		ELSIF input_axuser = AXUSER_MAP14 AND MASTERS_NUMBER > 14 THEN
			RETURN 14;
		ELSIF input_axuser = AXUSER_MAP15 AND MASTERS_NUMBER > 15 THEN
			RETURN 15;
		ELSIF input_axuser = AXUSER_MAP16 AND MASTERS_NUMBER > 16 THEN
			RETURN 16;
		ELSIF input_axuser = AXUSER_MAP17 AND MASTERS_NUMBER > 17 THEN
			RETURN 17;
		ELSIF input_axuser = AXUSER_MAP18 AND MASTERS_NUMBER > 18 THEN
			RETURN 18;
		ELSIF input_axuser = AXUSER_MAP19 AND MASTERS_NUMBER > 19 THEN
			RETURN 19;
		ELSIF input_axuser = AXUSER_MAP20 AND MASTERS_NUMBER > 20 THEN
			RETURN 20;
		ELSIF input_axuser = AXUSER_MAP21 AND MASTERS_NUMBER > 21 THEN
			RETURN 21;
		ELSIF input_axuser = AXUSER_MAP22 AND MASTERS_NUMBER > 22 THEN
			RETURN 22;
		ELSIF input_axuser = AXUSER_MAP23 AND MASTERS_NUMBER > 23 THEN
			RETURN 23;
		ELSIF input_axuser = AXUSER_MAP24 AND MASTERS_NUMBER > 24 THEN
			RETURN 24;
		ELSIF input_axuser = AXUSER_MAP25 AND MASTERS_NUMBER > 25 THEN
			RETURN 25;
		ELSIF input_axuser = AXUSER_MAP26 AND MASTERS_NUMBER > 26 THEN
			RETURN 26;
		ELSIF input_axuser = AXUSER_MAP27 AND MASTERS_NUMBER > 27 THEN
			RETURN 27;
		ELSIF input_axuser = AXUSER_MAP28 AND MASTERS_NUMBER > 28 THEN
			RETURN 28;
		ELSIF input_axuser = AXUSER_MAP29 AND MASTERS_NUMBER > 29 THEN
			RETURN 29;
		ELSIF input_axuser = AXUSER_MAP30 AND MASTERS_NUMBER > 30 THEN
			RETURN 30;
		ELSIF input_axuser = AXUSER_MAP31 AND MASTERS_NUMBER > 31 THEN
			RETURN 31;
		ELSE
			RETURN -1; -- default return
		END IF;
	END select_mapping_axuser;

	-- used for the request channels
	FUNCTION direct_mapping(entries : STD_LOGIC_VECTOR; s_axuser : STD_LOGIC_VECTOR; input_axi_id : STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
		VARIABLE pool_idx : INTEGER := select_mapping_axuser(s_axuser) * POOL_SIZE * C_M_AXI_ID_WIDTH;
		VARIABLE result : STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
		-- s_axuser selects the luts according to the map, the input axi_id is then remapped to one of the entries
	BEGIN
		IF to_integer(unsigned(input_axi_id)) > (POOL_SIZE - 1) THEN
			result := (OTHERS => '0');
		ELSIF pool_idx /= - 1 THEN
			result := entries(to_integer(unsigned(input_axi_id)) * C_M_AXI_ID_WIDTH + pool_idx + C_M_AXI_ID_WIDTH - 1 DOWNTO to_integer(unsigned(input_axi_id)) * C_M_AXI_ID_WIDTH + pool_idx);
		END IF;
		RETURN result;
	END FUNCTION direct_mapping;

	-- used for the response channels
	FUNCTION inverse_mapping(input_vector : STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		RETURN STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(input_vector)) MOD POOL_SIZE, C_M_AXI_ID_WIDTH));
	END FUNCTION inverse_mapping;

	-- shift right the vector and update the new entry in the most significant bits
	FUNCTION shift_and_new_entry(InputVector : IN STD_LOGIC_VECTOR; New_Entry : STD_LOGIC_VECTOR; ShiftAmount : IN NATURAL; idx_update : NATURAL) RETURN STD_LOGIC_VECTOR IS
		VARIABLE ResultVector : STD_LOGIC_VECTOR(InputVector'RANGE);
	BEGIN
		ResultVector := STD_LOGIC_VECTOR(shift_right(unsigned(InputVector), ShiftAmount));
		ResultVector(((idx_update + 1) * ShiftAmount) - 1 DOWNTO idx_update * ShiftAmount) := New_Entry;
		RETURN ResultVector;
	END FUNCTION shift_and_new_entry;

	-- shift the buffer and insert the new entry
	FUNCTION shift_and_new_entry(InputVector : IN STD_LOGIC_VECTOR; New_Entry : STD_LOGIC; ShiftAmount : IN NATURAL; idx_update : NATURAL) RETURN STD_LOGIC_VECTOR IS
		VARIABLE ResultVector : STD_LOGIC_VECTOR(InputVector'RANGE);
	BEGIN
		ResultVector := STD_LOGIC_VECTOR(shift_right(unsigned(InputVector), ShiftAmount));
		ResultVector(idx_update) := New_Entry;
		RETURN ResultVector;
	END FUNCTION shift_and_new_entry;

	-- check for violations at the request
	-- if the requests are correctly handled, response cannot produce out-of-bound values
	FUNCTION set_introut(input_axi_id : STD_LOGIC_VECTOR(C_M_AXI_ID_WIDTH - 1 DOWNTO 0)) RETURN STD_LOGIC IS
	BEGIN
		IF to_integer(unsigned(input_axi_id)) > (POOL_SIZE - 1) THEN
			RETURN '1';
		ELSE
			RETURN '0';
		END IF;
	END FUNCTION set_introut;
	-- functions --

	-- lut entries
	SIGNAL lut_entries : STD_LOGIC_VECTOR((MASTERS_NUMBER * POOL_SIZE * C_M_AXI_ID_WIDTH) - 1 DOWNTO 0);
	
	-- read buffer request signals
	SIGNAL araddr_buffer : STD_LOGIC_VECTOR(READ_REQ_BUFFER_SIZE * C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arlen_buffer : STD_LOGIC_VECTOR(READ_REQ_BUFFER_SIZE * 8 - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arsize_buffer : STD_LOGIC_VECTOR(READ_REQ_BUFFER_SIZE * 3 - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arburst_buffer : STD_LOGIC_VECTOR(READ_REQ_BUFFER_SIZE * 2 - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arlock_buffer : STD_LOGIC_VECTOR(READ_REQ_BUFFER_SIZE -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arcache_buffer : STD_LOGIC_VECTOR( READ_REQ_BUFFER_SIZE*4 -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arprot_buffer : STD_LOGIC_VECTOR( READ_REQ_BUFFER_SIZE*3 -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arqos_buffer : STD_LOGIC_VECTOR(READ_REQ_BUFFER_SIZE*4 -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL arid_buffer : STD_LOGIC_VECTOR(READ_REQ_BUFFER_SIZE*C_M_AXI_ID_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL read_buffer_index_req : NATURAL := 0;

	-- write buffer request signals
	SIGNAL awaddr_buffer : STD_LOGIC_VECTOR(WRITE_REQ_BUFFER_SIZE * C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awlen_buffer : STD_LOGIC_VECTOR(WRITE_REQ_BUFFER_SIZE * 8 - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awsize_buffer : STD_LOGIC_VECTOR(WRITE_REQ_BUFFER_SIZE * 3 - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awburst_buffer : STD_LOGIC_VECTOR(WRITE_REQ_BUFFER_SIZE * 2 - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awlock_buffer : STD_LOGIC_VECTOR(WRITE_REQ_BUFFER_SIZE -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awcache_buffer : STD_LOGIC_VECTOR( WRITE_REQ_BUFFER_SIZE*4 -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awprot_buffer : STD_LOGIC_VECTOR( WRITE_REQ_BUFFER_SIZE*3 -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awqos_buffer : STD_LOGIC_VECTOR(WRITE_REQ_BUFFER_SIZE*4 -1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL awid_buffer : STD_LOGIC_VECTOR(WRITE_REQ_BUFFER_SIZE*C_M_AXI_ID_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL write_buffer_index_req : NATURAL := 0;

	-- buffer signals
	-- WRITE channel
	-- data
	SIGNAL WDATA_buffer : STD_LOGIC_VECTOR(WRITE_BURST_BUFFER_SIZE * C_M_AXI_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL WLAST_buffer : STD_LOGIC_VECTOR(WRITE_BURST_BUFFER_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL WSTRB_buffer : STD_LOGIC_VECTOR((WRITE_BURST_BUFFER_SIZE * C_M_AXI_DATA_WIDTH/8) - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL write_buffer_index_data : NATURAL := 0;

	-- resp
	SIGNAL BID_buffer : STD_LOGIC_VECTOR(WRITE_RSP_BUFFER_SIZE * C_M_AXI_ID_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL BRESP_buffer : STD_LOGIC_VECTOR(WRITE_RSP_BUFFER_SIZE * 2 - 1 DOWNTO 0) := (OTHERS => '0'); -- RRESP_width = 2
	SIGNAL write_buffer_index_rsp : NATURAL := 0;

	-- READ channel
	SIGNAL RDATA_buffer : STD_LOGIC_VECTOR(READ_BURST_BUFFER_SIZE * C_M_AXI_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL RID_buffer : STD_LOGIC_VECTOR(READ_BURST_BUFFER_SIZE * C_M_AXI_ID_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL RLAST_buffer : STD_LOGIC_VECTOR(READ_BURST_BUFFER_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL RRESP_buffer : STD_LOGIC_VECTOR(READ_BURST_BUFFER_SIZE * 2 - 1 DOWNTO 0) := (OTHERS => '0'); -- RRESP_width = 2
	SIGNAL read_buffer_index : NATURAL := 0;

	-- introut signals
	SIGNAL introut_read : STD_LOGIC := '0';
	SIGNAL introut_write : STD_LOGIC := '0';

BEGIN

	-- lut entries definition
	entry_GENERATE_FOR : FOR i IN 0 TO (MASTERS_NUMBER * POOL_SIZE) - 1 GENERATE
		lut_entries(((i + 1) * C_M_AXI_ID_WIDTH) - 1 DOWNTO C_M_AXI_ID_WIDTH * i) <= STD_LOGIC_VECTOR(to_unsigned(i, C_M_AXI_ID_WIDTH));
	END GENERATE entry_GENERATE_FOR;

	PROCESS (aclk)
	BEGIN
		IF rising_edge(aclk) THEN
			--------------------------------------------------------------------------- RST-------------------------------------------------------------------------------
			IF aresetn = '0' THEN -- Reset is active low

				-- interrupt output
				introut <= '0';

				-- Master Interface Write Address
				M_AXI_AWADDR <= (OTHERS => '0');
				-- Burst length
				M_AXI_AWLEN <= (OTHERS => '0');
				-- Burst size
				M_AXI_AWSIZE <= (OTHERS => '0');
				-- Burst type
				M_AXI_AWBURST <= (OTHERS => '0');
				-- Lock type
				M_AXI_AWLOCK <= '0';
				-- Memory type
				M_AXI_AWCACHE <= (OTHERS => '0');
				-- Protection type
				M_AXI_AWPROT <= (OTHERS => '0');
				-- Quality of Service
				M_AXI_AWQOS <= (OTHERS => '0');
				-- Write address valid
				M_AXI_AWVALID <= '0';
				-- Master Interface Write Data
				M_AXI_WDATA <= (OTHERS => '0');
				-- Write strobes
				M_AXI_WSTRB <= (OTHERS => '0');
				-- Write last
				M_AXI_WLAST <= '0';
				-- Write valid
				M_AXI_WVALID <= '0';

				-- Master Interface Read Address
				M_AXI_ARADDR <= (OTHERS => '0');
				-- Burst length
				M_AXI_ARLEN <= (OTHERS => '0');
				-- Burst size
				M_AXI_ARSIZE <= (OTHERS => '0');
				-- Burst type
				M_AXI_ARBURST <= (OTHERS => '0');
				-- Lock type
				M_AXI_ARLOCK <= '0';
				-- Memory type
				M_AXI_ARCACHE <= (OTHERS => '0');
				-- Protection type
				M_AXI_ARPROT <= (OTHERS => '0');
				-- Quality of Service
				M_AXI_ARQOS <= (OTHERS => '0');
				-- Read address valid
				M_AXI_ARVALID <= '0';

				-- Inverted Master Interface Write Address
				S_AXI_BID <= (OTHERS => '0');
				S_AXI_BRESP <= (OTHERS => '0');
				-- Write response valid
				S_AXI_BVALID <= '0';

				-- Read ID tag
				S_AXI_RID <= (OTHERS => '0');
				-- Master Read Data
				S_AXI_RDATA <= (OTHERS => '0');
				-- Read response
				S_AXI_RRESP <= (OTHERS => '0');
				-- Read last
				S_AXI_RLAST <= '0';
				-- Read valid
				S_AXI_RVALID <= '0';

				-- READY signals
				M_AXI_BREADY <= '1';
				M_AXI_RREADY <= '1';
				S_AXI_AWREADY <= '1';
				S_AXI_WREADY <= '1';
				S_AXI_ARREADY <= '1';
			END IF;

			--------------------------------------------------------------------------- RST-------------------------------------------------------------------------------

			------------------------------------------------------------------ WRITE CHANNEL -------------------------------------------------------------------

			------------- REQ channel ------------- 
			-- The request channel has simple buffering
			-- FSM on:
			-- M_AXI_AWREADY: 0, 1
			-- S_AXI_AWVALID: 0, 1
			-- BUFFER: empty(0), not empty(1 to WRITE_REQ_BUFFER_SIZE-1), full (WRITE_REQ_BUFFER_SIZE)
			
			IF M_AXI_AWREADY = '0' THEN
				-- M_AXI_AWREADY is 0
				-- xVALID and all the other signals must remain stable until next xREADY = '1'
				IF S_AXI_AWVALID = '0' THEN
					-- S_AXI_AWVALID is 0
					-- M_AXI_AWREADY = 0, S_AXI_AWVALID = 0
					IF write_buffer_index_req = 0 THEN
						-- M_AXI_AWREADY = 0, S_AXI_AWVALID = 0, write_buffer_index_req = 0
						S_AXI_AWREADY <= '1';
					ELSIF write_buffer_index_req = WRITE_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 0, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE
						S_AXI_AWREADY <= '0';
					ELSE
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 0, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						S_AXI_AWREADY <= '1';
					END IF;
				ELSE
					-- S_AXI_WVALID is 1
					-- M_AXI_WREADY = 0, S_AXI_WVALID = 1
					IF write_buffer_index_req = 0 THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = 0
						-- buffering
						awaddr_buffer (C_M_AXI_ADDR_WIDTH -1 DOWNTO 0) <= S_AXI_AWADDR;
						awlen_buffer (7 DOWNTO 0) <= S_AXI_AWLEN;
						awsize_buffer (2 DOWNTO 0) <= S_AXI_AWSIZE;
						awburst_buffer (1 DOWNTO 0) <= S_AXI_AWBURST;
						awlock_buffer (0) <= S_AXI_AWLOCK;
						awcache_buffer (3 DOWNTO 0) <= S_AXI_AWCACHE;
						awprot_buffer(2 DOWNTO 0) <= S_AXI_AWPROT;
						awqos_buffer(3 DOWNTO 0) <= S_AXI_AWQOS;
						awid_buffer (C_M_AXI_ID_WIDTH-1 DOWNTO 0) <= direct_mapping(lut_entries, S_AXI_AWUSER, S_AXI_AWID);
						write_buffer_index_req <= write_buffer_index_req + 1;
						S_AXI_AWREADY <= '1';
					ELSIF write_buffer_index_req = WRITE_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- keep S_AXI_WREADY to '0'
						S_AXI_AWREADY <= '0';
					ELSE
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						-- buffering
						awaddr_buffer (C_M_AXI_ADDR_WIDTH -1 DOWNTO 0) <= S_AXI_AWADDR;
						awlen_buffer (7 DOWNTO 0) <= S_AXI_AWLEN;
						awsize_buffer (2 DOWNTO 0) <= S_AXI_AWSIZE;
						awburst_buffer (1 DOWNTO 0) <= S_AXI_AWBURST;
						awlock_buffer (0) <= S_AXI_AWLOCK;
						awcache_buffer (3 DOWNTO 0) <= S_AXI_AWCACHE;
						awprot_buffer(2 DOWNTO 0) <= S_AXI_AWPROT;
						awqos_buffer(3 DOWNTO 0) <= S_AXI_AWQOS;
						awid_buffer (C_M_AXI_ID_WIDTH-1 DOWNTO 0) <= direct_mapping(lut_entries, S_AXI_AWUSER, S_AXI_AWID);
						-- update
						write_buffer_index_req <= write_buffer_index_req + 1;
						IF write_buffer_index_req = WRITE_REQ_BUFFER_SIZE - 1 THEN
							S_AXI_AWREADY <= '0';
						ELSE
							S_AXI_AWREADY <= '1';
						END IF;
					END IF;
				END IF;
			ELSE
				-- M_AXI_WREADY is 1
				IF S_AXI_AWVALID = '0' THEN
					-- S_AXI_WVALID is 0
					IF write_buffer_index_req = 0 THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = 0
						S_AXI_AWREADY <= '1';
						-- all 0s
						M_AXI_AWVALID <= '0';
						M_AXI_AWADDR <= (others => '0');
						M_AXI_AWLEN <= (others => '0');
						M_AXI_AWSIZE <= (others => '0');
						M_AXI_AWBURST <= (others => '0');
						M_AXI_AWLOCK <= '0';
						M_AXI_AWCACHE <= (others => '0');
						M_AXI_AWPROT <= (others => '0');
						M_AXI_AWQOS <= (others => '0');
						M_AXI_AWID <= (others => '0');
					ELSIF write_buffer_index_req = WRITE_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- send the response
						M_AXI_AWVALID <= '1';
						M_AXI_AWADDR <= awaddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_AWLEN <= awlen_buffer(7 DOWNTO 0);
						M_AXI_AWSIZE <= awsize_buffer(2 DOWNTO 0);
						M_AXI_AWBURST <= awburst_buffer(1 DOWNTO 0);
						M_AXI_AWLOCK <= awlock_buffer(0);
						M_AXI_AWCACHE <= awcache_buffer(3 DOWNTO 0);
						M_AXI_AWPROT <= awprot_buffer(2 DOWNTO 0);
						M_AXI_AWQOS <= awqos_buffer(3 DOWNTO 0);
						M_AXI_AWID <= awid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer & index
						-- shift the current active values of one position
						awaddr_buffer <= std_logic_vector (shift_right(unsigned(awaddr_buffer), C_M_AXI_ADDR_WIDTH));
						awlen_buffer <= std_logic_vector(shift_right(unsigned(awlen_buffer), 8));
						awsize_buffer <= std_logic_vector(shift_right(unsigned(awsize_buffer), 3));
						awburst_buffer <= std_logic_vector(shift_right(unsigned(awburst_buffer), 2));
						awlock_buffer <= std_logic_vector(shift_right(unsigned(awlock_buffer), 1));
						awcache_buffer <= std_logic_vector(shift_right(unsigned(awcache_buffer), 4));
						awprot_buffer <= std_logic_vector(shift_right(unsigned(awprot_buffer), 3));
						awqos_buffer <= std_logic_vector(shift_right(unsigned(awqos_buffer), 4));
						awid_buffer <= std_logic_vector(shift_right(unsigned(awid_buffer), C_M_AXI_ID_WIDTH));
						write_buffer_index_req <= write_buffer_index_req - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_AWREADY <= '1';
					ELSE
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						-- send the response
						M_AXI_AWVALID <= '1';
						M_AXI_AWADDR <= awaddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_AWLEN <= awlen_buffer(7 DOWNTO 0);
						M_AXI_AWSIZE <= awsize_buffer(2 DOWNTO 0);
						M_AXI_AWBURST <= awburst_buffer(1 DOWNTO 0);
						M_AXI_AWLOCK <= awlock_buffer(0);
						M_AXI_AWCACHE <= awcache_buffer(3 DOWNTO 0);
						M_AXI_AWPROT <= awprot_buffer(2 DOWNTO 0);
						M_AXI_AWQOS <= awqos_buffer(3 DOWNTO 0);
						M_AXI_AWID <= awid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer & index
						-- shift the current active values of one position
						awaddr_buffer <= std_logic_vector (shift_right(unsigned(awaddr_buffer), C_M_AXI_ADDR_WIDTH));
						awlen_buffer <= std_logic_vector(shift_right(unsigned(awlen_buffer), 8));
						awsize_buffer <= std_logic_vector(shift_right(unsigned(awsize_buffer), 3));
						awburst_buffer <= std_logic_vector(shift_right(unsigned(awburst_buffer), 2));
						awlock_buffer <= std_logic_vector(shift_right(unsigned(awlock_buffer), 1));
						awcache_buffer <= std_logic_vector(shift_right(unsigned(awcache_buffer), 4));
						awprot_buffer <= std_logic_vector(shift_right(unsigned(awprot_buffer), 3));
						awqos_buffer <= std_logic_vector(shift_right(unsigned(awqos_buffer), 4));
						awid_buffer <= std_logic_vector(shift_right(unsigned(awid_buffer), C_M_AXI_ID_WIDTH));
						write_buffer_index_req <= write_buffer_index_req - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_AWREADY <= '1';
					END IF;
				ELSE
					-- S_AXI_WVALID is 1
					-- M_AXI_WREADY = 1, S_AXI_WVALID = 1
					IF write_buffer_index_req = 0 THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = 0
						-- buffering
						awaddr_buffer (C_M_AXI_ADDR_WIDTH -1 DOWNTO 0) <= S_AXI_AWADDR;
						awlen_buffer (7 DOWNTO 0) <= S_AXI_AWLEN;
						awsize_buffer (2 DOWNTO 0) <= S_AXI_AWSIZE;
						awburst_buffer (1 DOWNTO 0) <= S_AXI_AWBURST;
						awlock_buffer (0) <= S_AXI_AWLOCK;
						awcache_buffer (3 DOWNTO 0) <= S_AXI_AWCACHE;
						awprot_buffer(2 DOWNTO 0) <= S_AXI_AWPROT;
						awqos_buffer(3 DOWNTO 0) <= S_AXI_AWQOS;
						awid_buffer (C_M_AXI_ID_WIDTH-1 DOWNTO 0) <= direct_mapping(lut_entries, S_AXI_AWUSER, S_AXI_AWID);
						write_buffer_index_req <= write_buffer_index_req + 1;
						-- update
						write_buffer_index_req <= write_buffer_index_req + 1;
						-- all 0s
						M_AXI_AWVALID <= '0';
						M_AXI_AWADDR <= (others => '0');
						M_AXI_AWLEN <= (others => '0');
						M_AXI_AWSIZE <= (others => '0');
						M_AXI_AWBURST <= (others => '0');
						M_AXI_AWLOCK <= '0';
						M_AXI_AWCACHE <= (others => '0');
						M_AXI_AWPROT <= (others => '0');
						M_AXI_AWQOS <= (others => '0');
						M_AXI_AWID <= (others => '0');
						-- S_AXI_WREADY set to '1'
						S_AXI_AWREADY <= '1';
					ELSIF write_buffer_index_req = WRITE_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- the value of S_AXI_WREADY is currently at '0' but the mapper will capture the next transaction on the next clock
						-- send the response
						M_AXI_AWVALID <= '1';
						M_AXI_AWADDR <= awaddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_AWLEN <= awlen_buffer(7 DOWNTO 0);
						M_AXI_AWSIZE <= awsize_buffer(2 DOWNTO 0);
						M_AXI_AWBURST <= awburst_buffer(1 DOWNTO 0);
						M_AXI_AWLOCK <= awlock_buffer(0);
						M_AXI_AWCACHE <= awcache_buffer(3 DOWNTO 0);
						M_AXI_AWPROT <= awprot_buffer(2 DOWNTO 0);
						M_AXI_AWQOS <= awqos_buffer(3 DOWNTO 0);
						M_AXI_AWID <= awid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer
						-- shift the current active values of one position
						awaddr_buffer <= std_logic_vector (shift_right(unsigned(awaddr_buffer), C_M_AXI_ADDR_WIDTH));
						awlen_buffer <= std_logic_vector(shift_right(unsigned(awlen_buffer), 8));
						awsize_buffer <= std_logic_vector(shift_right(unsigned(awsize_buffer), 3));
						awburst_buffer <= std_logic_vector(shift_right(unsigned(awburst_buffer), 2));
						awlock_buffer <= std_logic_vector(shift_right(unsigned(awlock_buffer), 1));
						awcache_buffer <= std_logic_vector(shift_right(unsigned(awcache_buffer), 4));
						awprot_buffer <= std_logic_vector(shift_right(unsigned(awprot_buffer), 3));
						awqos_buffer <= std_logic_vector(shift_right(unsigned(awqos_buffer), 4));
						awid_buffer <= std_logic_vector(shift_right(unsigned(awid_buffer), C_M_AXI_ID_WIDTH));
						write_buffer_index_req <= write_buffer_index_req - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_AWREADY <= '1';
					ELSE
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						S_AXI_AWREADY <= '1';
						-- a new transaction is buffered and another is sent so write_buffer_index_data keep the same value
						-- send the response
						M_AXI_AWVALID <= '1';
						M_AXI_AWADDR <= awaddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_AWLEN <= awlen_buffer(7 DOWNTO 0);
						M_AXI_AWSIZE <= awsize_buffer(2 DOWNTO 0);
						M_AXI_AWBURST <= awburst_buffer(1 DOWNTO 0);
						M_AXI_AWLOCK <= awlock_buffer(0);
						M_AXI_AWCACHE <= awcache_buffer(3 DOWNTO 0);
						M_AXI_AWPROT <= awprot_buffer(2 DOWNTO 0);
						M_AXI_AWQOS <= awqos_buffer(3 DOWNTO 0);
						M_AXI_AWID <= awid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer
						-- shift the current active values of one position and set the new one. The index to use is the previous one (write_buffer_index_data).
						-- in this case i cannot use shift_right because it would overwrite the new entry
						awaddr_buffer <= shift_and_new_entry(awaddr_buffer, S_AXI_AWADDR, C_M_AXI_ADDR_WIDTH, write_buffer_index_req -1);
						awlen_buffer <= shift_and_new_entry(awlen_buffer, S_AXI_AWLEN, 8, write_buffer_index_req -1);
						awsize_buffer <= shift_and_new_entry(awsize_buffer, S_AXI_AWSIZE, 3, write_buffer_index_req -1);
						awburst_buffer <= shift_and_new_entry(awburst_buffer, S_AXI_AWBURST, 2, write_buffer_index_req -1);
						awlock_buffer <= shift_and_new_entry(awlock_buffer, S_AXI_AWLOCK, 1, write_buffer_index_req -1);
						awcache_buffer <= shift_and_new_entry(awcache_buffer, S_AXI_AWCACHE, 4, write_buffer_index_req -1);
						awprot_buffer <= shift_and_new_entry(awprot_buffer, S_AXI_AWPROT, 3, write_buffer_index_req -1);
						awqos_buffer <= shift_and_new_entry(awqos_buffer, S_AXI_AWQOS, 4, write_buffer_index_req -1);
						awid_buffer <= shift_and_new_entry(awid_buffer, direct_mapping(lut_entries, S_AXI_AWUSER, S_AXI_AWID), C_M_AXI_ID_WIDTH, write_buffer_index_req -1);
						-- a new transaction is buffered and another is sent so write_buffer_index_data has the same value, S_AXI_WREADY is still '1'
						S_AXI_AWREADY <= '1';
					END IF;
				END IF;
			END IF;


			------------- REQ channel ------------- 

			------------- DATA channel ------------- 
			-- FSM on:
			-- M_AXI_WREADY: 0, 1
			-- S_AXI_WVALID: 0, 1
			-- BUFFER: empty(0), not empty(1 to WRITE_BURST_BUFFER_SIZE-1), full (WRITE_BURST_BUFFER_SIZE)

			IF M_AXI_WREADY = '0' THEN
				-- M_AXI_WREADY is 0
				-- xVALID and all the other signals must remain stable until next xREADY = '1'
				IF S_AXI_WVALID = '0' THEN
					-- S_AXI_WVALID is 0
					-- M_AXI_WREADY = 0, S_AXI_WVALID = 0
					IF write_buffer_index_data = 0 THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 0, write_buffer_index_data = 0
						S_AXI_WREADY <= '1';
					ELSIF write_buffer_index_data = WRITE_BURST_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 0, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE
						S_AXI_WREADY <= '0';
					ELSE
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 0, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						S_AXI_WREADY <= '1';
					END IF;
				ELSE
					-- S_AXI_WVALID is 1
					-- M_AXI_WREADY = 0, S_AXI_WVALID = 1
					IF write_buffer_index_data = 0 THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = 0
						-- buffering
						WDATA_buffer (C_M_AXI_DATA_WIDTH - 1 DOWNTO 0) <= S_AXI_WDATA;
						WLAST_buffer (0) <= S_AXI_WLAST;
						WSTRB_buffer (C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0) <= S_AXI_WSTRB;
						write_buffer_index_data <= write_buffer_index_data + 1;
						S_AXI_WREADY <= '1';
					ELSIF write_buffer_index_data = WRITE_BURST_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- keep S_AXI_WREADY to '0'
						S_AXI_WREADY <= '0';
					ELSE
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						-- buffering
						WDATA_buffer ((C_M_AXI_DATA_WIDTH * (write_buffer_index_data + 1)) - 1 DOWNTO C_M_AXI_DATA_WIDTH * write_buffer_index_data) <= S_AXI_WDATA;
						WLAST_buffer (write_buffer_index_data) <= S_AXI_WLAST;
						WSTRB_buffer((C_M_AXI_DATA_WIDTH/8 * (write_buffer_index_data + 1)) - 1 DOWNTO C_M_AXI_DATA_WIDTH/8 * write_buffer_index_data) <= S_AXI_WSTRB;
						-- update
						write_buffer_index_data <= write_buffer_index_data + 1;
						IF write_buffer_index_data = WRITE_BURST_BUFFER_SIZE - 1 THEN
							S_AXI_WREADY <= '0';
						ELSE
							S_AXI_WREADY <= '1';
						END IF;
					END IF;
				END IF;
			ELSE
				-- M_AXI_WREADY is 1
				IF S_AXI_WVALID = '0' THEN
					-- S_AXI_WVALID is 0
					IF write_buffer_index_data = 0 THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = 0
						S_AXI_WREADY <= '1';
						-- all 0s
						M_AXI_WVALID <= '0';
						M_AXI_WDATA <= (OTHERS => '0');
						M_AXI_WSTRB <= (OTHERS => '0');
						M_AXI_WLAST <= '0';
					ELSIF write_buffer_index_data = WRITE_BURST_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- send the response
						M_AXI_WDATA <= WDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						M_AXI_WLAST <= WLAST_buffer(0);
						M_AXI_WSTRB <= WSTRB_buffer (C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0);
						M_AXI_WVALID <= '1';
						-- update buffer & index
						-- shift the current active values of one position
						WDATA_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WDATA_buffer), C_M_AXI_DATA_WIDTH));
						WLAST_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WLAST_buffer), 1));
						WSTRB_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WSTRB_buffer), C_M_AXI_DATA_WIDTH/8));
						write_buffer_index_data <= write_buffer_index_data - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_WREADY <= '1';
					ELSE
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						-- send the response
						M_AXI_WDATA <= WDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						M_AXI_WLAST <= WLAST_buffer(0);
						M_AXI_WSTRB <= WSTRB_buffer (C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0);
						M_AXI_WVALID <= '1';
						-- update buffer & index
						-- shift the current active values of one position
						WDATA_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WDATA_buffer), C_M_AXI_DATA_WIDTH));
						WLAST_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WLAST_buffer), 1));
						WSTRB_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WSTRB_buffer), C_M_AXI_DATA_WIDTH/8));
						write_buffer_index_data <= write_buffer_index_data - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_WREADY <= '1';
					END IF;
				ELSE
					-- S_AXI_WVALID is 1
					-- M_AXI_WREADY = 1, S_AXI_WVALID = 1
					IF write_buffer_index_data = 0 THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = 0
						-- buffering
						WDATA_buffer (C_M_AXI_DATA_WIDTH - 1 DOWNTO 0) <= S_AXI_WDATA;
						WLAST_buffer (0) <= S_AXI_WLAST;
						WSTRB_buffer (C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0) <= S_AXI_WSTRB;
						-- update
						M_AXI_WVALID <= '0';
						write_buffer_index_data <= write_buffer_index_data + 1;
						-- all 0s
						M_AXI_WDATA <= (OTHERS => '0');
						M_AXI_WSTRB <= (OTHERS => '0');
						M_AXI_WLAST <= '0';
						-- S_AXI_WREADY set to '1'
						S_AXI_WREADY <= '1';
					ELSIF write_buffer_index_data = WRITE_BURST_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- the value of S_AXI_WREADY is currently at '0' but the mapper will capture the next transaction on the next clock
						-- send the response
						M_AXI_WDATA <= WDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						M_AXI_WLAST <= WLAST_buffer(0);
						M_AXI_WSTRB <= WSTRB_buffer (C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0);
						M_AXI_WVALID <= '1';
						-- update buffer
						-- shift the current active values of one position
						WDATA_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WDATA_buffer), C_M_AXI_DATA_WIDTH));
						WLAST_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WLAST_buffer), 1));
						WSTRB_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(WSTRB_buffer), C_M_AXI_DATA_WIDTH/8));
						write_buffer_index_data <= write_buffer_index_data - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_WREADY <= '1';
					ELSE
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						S_AXI_WREADY <= '1';
						-- a new transaction is buffered and another is sent so write_buffer_index_data keep the same value
						-- send the response
						M_AXI_WDATA <= WDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						M_AXI_WLAST <= WLAST_buffer(0);
						M_AXI_WSTRB <= WSTRB_buffer(C_M_AXI_DATA_WIDTH/8 - 1 DOWNTO 0);
						M_AXI_WVALID <= '1';
						-- update buffer
						-- shift the current active values of one position and set the new one. The index to use is the previous one (write_buffer_index_data).
						-- in this case i cannot use shift_right because it would overwrite the new entry
						WDATA_buffer <= shift_and_new_entry(WDATA_buffer, S_AXI_WDATA, C_M_AXI_DATA_WIDTH, write_buffer_index_data - 1);
						WLAST_buffer <= shift_and_new_entry(WLAST_buffer, S_AXI_WLAST, 1, write_buffer_index_data - 1);
						WSTRB_buffer <= shift_and_new_entry(WSTRB_buffer, S_AXI_WSTRB, C_M_AXI_DATA_WIDTH/8, write_buffer_index_data - 1);
						-- a new transaction is buffered and another is sent so write_buffer_index_data has the same value, S_AXI_WREADY is still '1'
						S_AXI_WREADY <= '1';
					END IF;
				END IF;
			END IF;
			------------- DATA channel ------------- 

			------------- RSP channel ------------- 
			-- FSM on:
			-- S_AXI_BREADY: 0, 1
			-- M_AXI_BVALID: 0, 1
			-- BUFFER: empty(0), not empty(1 to WRITE_RSP_BUFFER_SIZE-1), full (WRITE_RSP_BUFFER_SIZE)

			IF S_AXI_BREADY = '0' THEN
				-- S_AXI_BREADY is 0
				IF M_AXI_BVALID = '0' THEN
					-- M_AXI_BVALID is 0
					-- S_AXI_BREADY = 0, M_AXI_BVALID = 0
					IF write_buffer_index_rsp = 0 THEN
						-- S_AXI_BREADY = 0, M_AXI_BVALID = 0, write_buffer_index_rsp = 0
						M_AXI_BREADY <= '1';
					ELSIF write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE THEN
						-- S_AXI_BREADY = 0, M_AXI_BVALID = 0, write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE
						M_AXI_BREADY <= '0';
					ELSE
						-- S_AXI_BREADY = 0, M_AXI_BVALID = 0, write_buffer_index_rsp = (1 to WRITE_RSP_BUFFER_SIZE - 1)
						M_AXI_BREADY <= '1';
					END IF;
				ELSE
					-- M_AXI_BVALID is 1
					-- S_AXI_BREADY = 0, M_AXI_BVALID = 1
					IF write_buffer_index_rsp = 0 THEN
						-- S_AXI_BREADY = 0, M_AXI_BVALID = 1, write_buffer_index_rsp = 0
						-- buffering
						BID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0) <= inverse_mapping(M_AXI_BID);
						BRESP_buffer(1 DOWNTO 0) <= M_AXI_BRESP;
						write_buffer_index_rsp <= write_buffer_index_rsp + 1;
						M_AXI_BREADY <= '1';
					ELSIF write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE THEN
						-- S_AXI_BREADY = 0, M_AXI_BVALID = 1, write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE 
						-- keep M_AXI_BREADY to '0'
						M_AXI_BREADY <= '0';
					ELSE
						-- S_AXI_BREADY = 0, M_AXI_BVALID = 1, write_buffer_index_rsp = (1 to WRITE_RSP_BUFFER_SIZE - 1)
						-- buffering
						BID_buffer((C_M_AXI_ID_WIDTH * (write_buffer_index_rsp + 1)) - 1 DOWNTO C_M_AXI_ID_WIDTH * write_buffer_index_rsp) <= inverse_mapping(M_AXI_BID);
						BRESP_buffer((2 * (write_buffer_index_rsp + 1)) - 1 DOWNTO 2 * write_buffer_index_rsp) <= M_AXI_BRESP;
						-- update
						write_buffer_index_rsp <= write_buffer_index_rsp + 1;
						IF write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE - 1 THEN
							M_AXI_BREADY <= '0';
						ELSE
							M_AXI_BREADY <= '1';
						END IF;
					END IF;
				END IF;
			ELSE
				-- S_AXI_BREADY is 1
				IF M_AXI_BVALID = '0' THEN
					-- M_AXI_BVALID is 0
					IF write_buffer_index_rsp = 0 THEN
						-- S_AXI_BREADY = 1, M_AXI_BVALID = 0, write_buffer_index_rsp = 0
						M_AXI_BREADY <= '1';
						S_AXI_BVALID <= '0';
						S_AXI_BRESP <= (OTHERS => '0');
						S_AXI_BID <= (OTHERS => '0');
					ELSIF write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE THEN
						-- S_AXI_BREADY = 1, M_AXI_BVALID = 0, write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE 
						-- send the response
						S_AXI_BID <= BID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_BRESP <= BRESP_buffer(1 DOWNTO 0);
						S_AXI_BVALID <= '1';
						-- update buffer & index
						-- shift the current active values of one position
						BID_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(BID_buffer), C_M_AXI_ID_WIDTH));
						BRESP_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(BRESP_buffer), 2));
						write_buffer_index_rsp <= write_buffer_index_rsp - 1;
						-- M_AXI_BREADY set to '1'
						M_AXI_BREADY <= '1';
					ELSE
						-- S_AXI_BREADY = 1, M_AXI_BVALID = 0, write_buffer_index_rsp = (1 to WRITE_RSP_BUFFER_SIZE - 1)
						-- send the response
						S_AXI_BID <= BID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_BRESP <= BRESP_buffer(1 DOWNTO 0);
						S_AXI_BVALID <= '1';
						-- update buffer & index
						-- shift the current active values of one position
						BID_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(BID_buffer), C_M_AXI_ID_WIDTH));
						BRESP_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(BRESP_buffer), 2));
						write_buffer_index_rsp <= write_buffer_index_rsp - 1;
						-- M_AXI_BREADY set to '1'
						M_AXI_BREADY <= '1';
					END IF;
				ELSE
					-- M_AXI_BVALID is 1
					-- S_AXI_BREADY = 1, M_AXI_BVALID = 1
					IF write_buffer_index_rsp = 0 THEN
						-- S_AXI_BREADY = 1, M_AXI_BVALID = 1, write_buffer_index_rsp = 0
						-- buffering
						BID_buffer((C_M_AXI_ID_WIDTH * (write_buffer_index_rsp + 1)) - 1 DOWNTO C_M_AXI_ID_WIDTH * write_buffer_index_rsp) <= inverse_mapping(M_AXI_BID);
						BRESP_buffer((2 * (write_buffer_index_rsp + 1)) - 1 DOWNTO 2 * write_buffer_index_rsp) <= M_AXI_BRESP;
						-- update
						S_AXI_BVALID <= '0';
						S_AXI_BRESP <= (OTHERS => '0');
						S_AXI_BID <= (OTHERS => '0');
						write_buffer_index_rsp <= write_buffer_index_rsp + 1;
						-- M_AXI_BREADY set to '1'
						M_AXI_BREADY <= '1';
					ELSIF write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE THEN
						-- S_AXI_BREADY = 1, M_AXI_BVALID = 1, write_buffer_index_rsp = WRITE_RSP_BUFFER_SIZE 
						-- the value of M_AXI_BREADY is currently at '0' but the mapper will capture the next transaction on the next clock
						-- send the response
						S_AXI_BID <= BID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_BRESP <= BRESP_buffer(1 DOWNTO 0);
						S_AXI_BVALID <= '1';
						-- update buffer
						-- shift the current active values of one position
						BID_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(BID_buffer), C_M_AXI_ID_WIDTH));
						BRESP_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(BRESP_buffer), 2));
						write_buffer_index_rsp <= write_buffer_index_rsp - 1;
						-- M_AXI_BREADY set to '1'
						M_AXI_BREADY <= '1';
					ELSE
						-- S_AXI_BREADY = 1, M_AXI_BVALID = 1, write_buffer_index_rsp = (1 to WRITE_RSP_BUFFER_SIZE - 1)
						-- a new transaction is buffered and another is sent so write_buffer_index_rsp keep the same value
						-- send the response
						S_AXI_BID <= BID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_BRESP <= BRESP_buffer(1 DOWNTO 0);
						S_AXI_BVALID <= '1';
						-- update buffer
						-- shift the current active values of one position and set the new one. The index to use is the previous one (write_buffer_index_rsp).
						-- in this case i cannot use shift_right because it would overwrite the new entry
						BID_buffer <= shift_and_new_entry(BID_buffer, inverse_mapping(M_AXI_BID), C_M_AXI_ID_WIDTH, write_buffer_index_rsp - 1);
						BRESP_buffer <= shift_and_new_entry(BRESP_buffer, M_AXI_BRESP, 2, write_buffer_index_rsp - 1);
						-- a new transaction is buffered and another is sent so write_buffer_index_rsp has the same value, M_AXI_BREADY is still '1'
						M_AXI_BREADY <= '1';
					END IF;
				END IF;
			END IF;
			------------- RSP channel ------------- 
			------------------------------------------------------------------ WRITE CHANNEL -------------------------------------------------------------------

			------------------------------------------------------------------ READ CHANNEL -------------------------------------------------------------------

			------------- REQ channel ------------- 
			-- The request channel has simple buffering
			-- FSM on :
			-- M_AXI_ARREADY: 0, 1
			-- S_AXI_ARVALID: 0, 1
			-- -- BUFFER: empty(0), not empty(1 to READ_REQ_BUFFER_SIZE-1), full (READ_REQ_BUFFER_SIZE)
			
			IF M_AXI_ARREADY = '0' THEN
				-- M_AXI_AWREADY is 0
				-- xVALID and all the other signals must remain stable until next xREADY = '1'
				IF S_AXI_ARVALID = '0' THEN
					-- S_AXI_AWVALID is 0
					-- M_AXI_AWREADY = 0, S_AXI_AWVALID = 0
					IF read_buffer_index_req = 0 THEN
						-- M_AXI_AWREADY = 0, S_AXI_AWVALID = 0, write_buffer_index_req = 0
						S_AXI_ARREADY <= '1';
					ELSIF read_buffer_index_req = READ_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 0, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE
						S_AXI_ARREADY <= '0';
					ELSE
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 0, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						S_AXI_ARREADY <= '1';
					END IF;
				ELSE
					-- S_AXI_WVALID is 1
					-- M_AXI_WREADY = 0, S_AXI_WVALID = 1
					IF read_buffer_index_req = 0 THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = 0
						-- buffering
						araddr_buffer (C_M_AXI_ADDR_WIDTH -1 DOWNTO 0) <= S_AXI_ARADDR;
						arlen_buffer (7 DOWNTO 0) <= S_AXI_ARLEN;
						arsize_buffer (2 DOWNTO 0) <= S_AXI_ARSIZE;
						arburst_buffer (1 DOWNTO 0) <= S_AXI_ARBURST;
						arlock_buffer (0) <= S_AXI_ARLOCK;
						arcache_buffer (3 DOWNTO 0) <= S_AXI_ARCACHE;
						arprot_buffer(2 DOWNTO 0) <= S_AXI_ARPROT;
						arqos_buffer(3 DOWNTO 0) <= S_AXI_ARQOS;
						arid_buffer (C_M_AXI_ID_WIDTH-1 DOWNTO 0) <= direct_mapping(lut_entries, S_AXI_ARUSER, S_AXI_ARID);
						read_buffer_index_req <= read_buffer_index_req + 1;
						S_AXI_ARREADY <= '1';
					ELSIF read_buffer_index_req = READ_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- keep S_AXI_WREADY to '0'
						S_AXI_ARREADY <= '0';
					ELSE
						-- M_AXI_WREADY = 0, S_AXI_WVALID = 1, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						-- buffering
						araddr_buffer(C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0) <= S_AXI_ARADDR;
						arlen_buffer(7 DOWNTO 0) <= S_AXI_ARLEN;
						arsize_buffer(2 DOWNTO 0) <= S_AXI_ARSIZE;
						arburst_buffer(1 DOWNTO 0) <= S_AXI_ARBURST;
						arlock_buffer(0) <= S_AXI_ARLOCK;
						arcache_buffer(3 DOWNTO 0) <= S_AXI_ARCACHE;
						arprot_buffer(2 DOWNTO 0) <= S_AXI_ARPROT;
						arqos_buffer(3 DOWNTO 0) <= S_AXI_ARQOS;
						arid_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0) <= direct_mapping(lut_entries, S_AXI_ARUSER, S_AXI_ARID);
						-- update
						read_buffer_index_req <= read_buffer_index_req + 1;
						IF read_buffer_index_req = READ_REQ_BUFFER_SIZE - 1 THEN
							S_AXI_ARREADY <= '0';
						ELSE
							S_AXI_ARREADY <= '1';
						END IF;
					END IF;
				END IF;
			ELSE
				-- M_AXI_WREADY is 1
				IF S_AXI_ARVALID = '0' THEN
					-- S_AXI_WVALID is 0
					IF read_buffer_index_req = 0 THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = 0
						S_AXI_ARREADY <= '1';
						-- all 0s
						M_AXI_ARVALID <= '0';
						M_AXI_ARADDR <= (others => '0');
						M_AXI_ARLEN <= (others => '0');
						M_AXI_ARSIZE <= (others => '0');
						M_AXI_ARBURST <= (others => '0');
						M_AXI_ARLOCK <= '0';
						M_AXI_ARCACHE <= (others => '0');
						M_AXI_ARPROT <= (others => '0');
						M_AXI_ARQOS <= (others => '0');
						M_AXI_ARID <= (others => '0');
					ELSIF read_buffer_index_req = READ_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- send the response
						M_AXI_ARVALID <= '1';
						M_AXI_ARADDR <= araddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_ARLEN <= arlen_buffer(7 DOWNTO 0);
						M_AXI_ARSIZE <= arsize_buffer(2 DOWNTO 0);
						M_AXI_ARBURST <= arburst_buffer(1 DOWNTO 0);
						M_AXI_ARLOCK <= arlock_buffer(0);
						M_AXI_ARCACHE <= arcache_buffer(3 DOWNTO 0);
						M_AXI_ARPROT <= arprot_buffer(2 DOWNTO 0);
						M_AXI_ARQOS <= arqos_buffer(3 DOWNTO 0);
						M_AXI_ARID <= arid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer & index
						-- shift the current active values of one position
						araddr_buffer <= std_logic_vector(shift_right(unsigned(araddr_buffer), C_M_AXI_ADDR_WIDTH));
						arlen_buffer <= std_logic_vector(shift_right(unsigned(arlen_buffer), 8));
						arsize_buffer <= std_logic_vector(shift_right(unsigned(arsize_buffer), 3));
						arburst_buffer <= std_logic_vector(shift_right(unsigned(arburst_buffer), 2));
						arlock_buffer <= std_logic_vector(shift_right(unsigned(arlock_buffer), 1));
						arcache_buffer <= std_logic_vector(shift_right(unsigned(arcache_buffer), 4));
						arprot_buffer <= std_logic_vector(shift_right(unsigned(arprot_buffer), 3));
						arqos_buffer <= std_logic_vector(shift_right(unsigned(arqos_buffer), 4));
						arid_buffer <= std_logic_vector(shift_right(unsigned(arid_buffer), C_M_AXI_ID_WIDTH));
						read_buffer_index_req <= read_buffer_index_req - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_ARREADY <= '1';
					ELSE
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 0, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						-- send the response
						M_AXI_ARVALID <= '1';
						M_AXI_ARADDR <= araddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_ARLEN <= arlen_buffer(7 DOWNTO 0);
						M_AXI_ARSIZE <= arsize_buffer(2 DOWNTO 0);
						M_AXI_ARBURST <= arburst_buffer(1 DOWNTO 0);
						M_AXI_ARLOCK <= arlock_buffer(0);
						M_AXI_ARCACHE <= arcache_buffer(3 DOWNTO 0);
						M_AXI_ARPROT <= arprot_buffer(2 DOWNTO 0);
						M_AXI_ARQOS <= arqos_buffer(3 DOWNTO 0);
						M_AXI_ARID <= arid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer & index
						-- shift the current active values of one position
						araddr_buffer <= std_logic_vector(shift_right(unsigned(araddr_buffer), C_M_AXI_ADDR_WIDTH));
						arlen_buffer <= std_logic_vector(shift_right(unsigned(arlen_buffer), 8));
						arsize_buffer <= std_logic_vector(shift_right(unsigned(arsize_buffer), 3));
						arburst_buffer <= std_logic_vector(shift_right(unsigned(arburst_buffer), 2));
						arlock_buffer <= std_logic_vector(shift_right(unsigned(arlock_buffer), 1));
						arcache_buffer <= std_logic_vector(shift_right(unsigned(arcache_buffer), 4));
						arprot_buffer <= std_logic_vector(shift_right(unsigned(arprot_buffer), 3));
						arqos_buffer <= std_logic_vector(shift_right(unsigned(arqos_buffer), 4));
						arid_buffer <= std_logic_vector(shift_right(unsigned(arid_buffer), C_M_AXI_ID_WIDTH));
						read_buffer_index_req <= read_buffer_index_req - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_ARREADY <= '1';
					END IF;
				ELSE
					-- S_AXI_WVALID is 1
					-- M_AXI_WREADY = 1, S_AXI_WVALID = 1
					IF read_buffer_index_req = 0 THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = 0
						-- buffering
						araddr_buffer(C_M_AXI_ADDR_WIDTH - 1 DOWNTO 0) <= S_AXI_ARADDR;
						arlen_buffer(7 DOWNTO 0) <= S_AXI_ARLEN;
						arsize_buffer(2 DOWNTO 0) <= S_AXI_ARSIZE;
						arburst_buffer(1 DOWNTO 0) <= S_AXI_ARBURST;
						arlock_buffer(0) <= S_AXI_ARLOCK;
						arcache_buffer(3 DOWNTO 0) <= S_AXI_ARCACHE;
						arprot_buffer(2 DOWNTO 0) <= S_AXI_ARPROT;
						arqos_buffer(3 DOWNTO 0) <= S_AXI_ARQOS;
						arid_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0) <= direct_mapping(lut_entries, S_AXI_ARUSER, S_AXI_ARID);
						-- update
						read_buffer_index_req <= read_buffer_index_req + 1;
						-- all 0s
						M_AXI_ARVALID <= '0';
						M_AXI_ARADDR <= (others => '0');
						M_AXI_ARLEN <= (others => '0');
						M_AXI_ARSIZE <= (others => '0');
						M_AXI_ARBURST <= (others => '0');
						M_AXI_ARLOCK <= '0';
						M_AXI_ARCACHE <= (others => '0');
						M_AXI_ARPROT <= (others => '0');
						M_AXI_ARQOS <= (others => '0');
						M_AXI_ARID <= (others => '0');
						-- S_AXI_WREADY set to '1'
						S_AXI_ARREADY <= '1';
					ELSIF read_buffer_index_req = READ_REQ_BUFFER_SIZE THEN
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = WRITE_BURST_BUFFER_SIZE 
						-- the value of S_AXI_WREADY is currently at '0' but the mapper will capture the next transaction on the next clock
						-- send the response
						M_AXI_ARVALID <= '1';
						M_AXI_ARADDR <= araddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_ARLEN <= arlen_buffer(7 DOWNTO 0);
						M_AXI_ARSIZE <= arsize_buffer(2 DOWNTO 0);
						M_AXI_ARBURST <= arburst_buffer(1 DOWNTO 0);
						M_AXI_ARLOCK <= arlock_buffer(0);
						M_AXI_ARCACHE <= arcache_buffer(3 DOWNTO 0);
						M_AXI_ARPROT <= arprot_buffer(2 DOWNTO 0);
						M_AXI_ARQOS <= arqos_buffer(3 DOWNTO 0);
						M_AXI_ARID <= arid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer
						-- shift the current active values of one position
						araddr_buffer <= std_logic_vector(shift_right(unsigned(araddr_buffer), C_M_AXI_ADDR_WIDTH));
						arlen_buffer <= std_logic_vector(shift_right(unsigned(arlen_buffer), 8));
						arsize_buffer <= std_logic_vector(shift_right(unsigned(arsize_buffer), 3));
						arburst_buffer <= std_logic_vector(shift_right(unsigned(arburst_buffer), 2));
						arlock_buffer <= std_logic_vector(shift_right(unsigned(arlock_buffer), 1));
						arcache_buffer <= std_logic_vector(shift_right(unsigned(arcache_buffer), 4));
						arprot_buffer <= std_logic_vector(shift_right(unsigned(arprot_buffer), 3));
						arqos_buffer <= std_logic_vector(shift_right(unsigned(arqos_buffer), 4));
						arid_buffer <= std_logic_vector(shift_right(unsigned(arid_buffer), C_M_AXI_ID_WIDTH));
						read_buffer_index_req <= read_buffer_index_req - 1;
						-- S_AXI_WREADY set to '1'
						S_AXI_ARREADY <= '1';
					ELSE
						-- M_AXI_WREADY = 1, S_AXI_WVALID = 1, write_buffer_index_data = (1 to WRITE_BURST_BUFFER_SIZE - 1)
						S_AXI_ARREADY <= '1';
						-- a new transaction is buffered and another is sent so write_buffer_index_data keep the same value
						-- send the response
						M_AXI_ARVALID <= '1';
						M_AXI_ARADDR <= araddr_buffer(C_M_AXI_ADDR_WIDTH -1 DOWNTO 0);
						M_AXI_ARLEN <= arlen_buffer(7 DOWNTO 0);
						M_AXI_ARSIZE <= arsize_buffer(2 DOWNTO 0);
						M_AXI_ARBURST <= arburst_buffer(1 DOWNTO 0);
						M_AXI_ARLOCK <= arlock_buffer(0);
						M_AXI_ARCACHE <= arcache_buffer(3 DOWNTO 0);
						M_AXI_ARPROT <= arprot_buffer(2 DOWNTO 0);
						M_AXI_ARQOS <= arqos_buffer(3 DOWNTO 0);
						M_AXI_ARID <= arid_buffer (C_M_AXI_ID_WIDTH -1 DOWNTO 0);
						-- update buffer
						-- shift the current active values of one position and set the new one. The index to use is the previous one (write_buffer_index_data).
						-- in this case i cannot use shift_right because it would overwrite the new entry
						araddr_buffer <= shift_and_new_entry(araddr_buffer, S_AXI_ARADDR, C_M_AXI_ADDR_WIDTH, read_buffer_index_req -1);
						arlen_buffer <= shift_and_new_entry(arlen_buffer, S_AXI_ARLEN, 8, read_buffer_index_req -1);
						arsize_buffer <= shift_and_new_entry(arsize_buffer, S_AXI_ARSIZE, 3, read_buffer_index_req -1);
						arburst_buffer <= shift_and_new_entry(arburst_buffer, S_AXI_ARBURST, 2, read_buffer_index_req -1);
						arlock_buffer <= shift_and_new_entry(arlock_buffer, S_AXI_ARLOCK, 1, read_buffer_index_req -1);
						arcache_buffer <= shift_and_new_entry(arcache_buffer, S_AXI_ARCACHE, 4, read_buffer_index_req -1);
						arprot_buffer <= shift_and_new_entry(arprot_buffer, S_AXI_ARPROT, 3, read_buffer_index_req -1);
						arqos_buffer <= shift_and_new_entry(arqos_buffer, S_AXI_ARQOS, 4, read_buffer_index_req -1);
						arid_buffer <= shift_and_new_entry(arid_buffer, direct_mapping(lut_entries, S_AXI_ARUSER, S_AXI_ARID), C_M_AXI_ID_WIDTH, read_buffer_index_req -1);
						-- a new transaction is buffered and another is sent so write_buffer_index_data has the same value, S_AXI_WREADY is still '1'
						S_AXI_ARREADY <= '1';
					END IF;
				END IF;
			END IF;
			------------- REQ channel ------------- 

			------------- RSP channel ------------- 

			-- FSM on:
			-- S_AXI_RREADY: 0, 1
			-- M_AXI_RVALID: 0, 1
			-- BUFFER: empty(0), not empty(1 to READ_BURST_BUFFER_SIZE-1), full (READ_BURST_BUFFER_SIZE)

			IF S_AXI_RREADY = '0' THEN
				-- S_AXI_RREADY is 0
				IF M_AXI_RVALID = '0' THEN
					-- M_AXI_RVALID is 0
					-- S_AXI_RREADY = 0, M_AXI_RVALID = 0
					IF read_buffer_index = 0 THEN
						-- S_AXI_RREADY = 0, M_AXI_RVALID = 0, read_buffer_index = 0
						M_AXI_RREADY <= '1';
					ELSIF read_buffer_index = READ_BURST_BUFFER_SIZE THEN
						-- S_AXI_RREADY = 0, M_AXI_RVALID = 0, read_buffer_index = READ_BURST_BUFFER_SIZE
						M_AXI_RREADY <= '0';
					ELSE
						-- S_AXI_RREADY = 0, M_AXI_RVALID = 0, read_buffer_index = (1 to READ_BURST_BUFFER_SIZE - 1)
						M_AXI_RREADY <= '1';
					END IF;
				ELSE
					-- M_AXI_RVALID is 1
					-- S_AXI_RREADY = 0, M_AXI_RVALID = 1
					IF read_buffer_index = 0 THEN
						-- S_AXI_RREADY = 0, M_AXI_RVALID = 1, read_buffer_index = 0
						-- buffering
						RDATA_buffer (C_M_AXI_DATA_WIDTH - 1 DOWNTO 0) <= M_AXI_RDATA;
						RLAST_buffer (0) <= M_AXI_RLAST;
						RID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0) <= inverse_mapping(M_AXI_RID);
						RRESP_buffer(1 DOWNTO 0) <= M_AXI_RRESP;
						read_buffer_index <= read_buffer_index + 1;
						M_AXI_RREADY <= '1';
					ELSIF read_buffer_index = READ_BURST_BUFFER_SIZE THEN
						-- S_AXI_RREADY = 0, M_AXI_RVALID = 1, read_buffer_index = READ_BURST_BUFFER_SIZE 
						-- keep M_AXI_RREADY to '0'
						M_AXI_RREADY <= '0';
					ELSE
						-- S_AXI_RREADY = 0, M_AXI_RVALID = 1, read_buffer_index = (1 to READ_BURST_BUFFER_SIZE - 1)
						-- buffering
						RDATA_buffer ((C_M_AXI_DATA_WIDTH * (read_buffer_index + 1)) - 1 DOWNTO C_M_AXI_DATA_WIDTH * read_buffer_index) <= M_AXI_RDATA;
						RLAST_buffer (read_buffer_index) <= M_AXI_RLAST;
						RID_buffer((C_M_AXI_ID_WIDTH * (read_buffer_index + 1)) - 1 DOWNTO C_M_AXI_ID_WIDTH * read_buffer_index) <= inverse_mapping(M_AXI_RID);
						RRESP_buffer((2 * (read_buffer_index + 1)) - 1 DOWNTO 2 * read_buffer_index) <= M_AXI_RRESP;
						-- update
						read_buffer_index <= read_buffer_index + 1;
						IF read_buffer_index = READ_BURST_BUFFER_SIZE - 1 THEN
							M_AXI_RREADY <= '0';
						ELSE
							M_AXI_RREADY <= '1';
						END IF;
					END IF;
				END IF;
			ELSE
				-- S_AXI_RREADY is 1
				IF M_AXI_RVALID = '0' THEN
					-- M_AXI_RVALID is 0
					IF read_buffer_index = 0 THEN
						-- S_AXI_RREADY = 1, M_AXI_RVALID = 0, read_buffer_index = 0
						M_AXI_RREADY <= '1';
						S_AXI_RVALID <= '0';
						S_AXI_RDATA <= (OTHERS => '0');
						S_AXI_RLAST <= '0';
						S_AXI_RID <= (OTHERS => '0');
						S_AXI_RRESP <= (OTHERS => '0');
					ELSIF read_buffer_index = READ_BURST_BUFFER_SIZE THEN
						-- S_AXI_RREADY = 1, M_AXI_RVALID = 0, read_buffer_index = READ_BURST_BUFFER_SIZE 
						-- send the response
						S_AXI_RDATA <= RDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						S_AXI_RLAST <= RLAST_buffer(0);
						S_AXI_RID <= RID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_RRESP <= RRESP_buffer(1 DOWNTO 0);
						S_AXI_RVALID <= '1';
						-- update buffer & index
						-- shift the current active values of one position
						RDATA_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RDATA_buffer), C_M_AXI_DATA_WIDTH));
						RLAST_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RLAST_buffer), 1));
						RID_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RID_buffer), C_M_AXI_ID_WIDTH));
						RRESP_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RRESP_buffer), 2));
						read_buffer_index <= read_buffer_index - 1;
						-- M_AXI_RREADY set to '1'
						M_AXI_RREADY <= '1';
					ELSE
						-- S_AXI_RREADY = 1, M_AXI_RVALID = 0, read_buffer_index = (1 to READ_BURST_BUFFER_SIZE - 1)
						-- send the response
						S_AXI_RDATA <= RDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						S_AXI_RLAST <= RLAST_buffer(0);
						S_AXI_RID <= RID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_RRESP <= RRESP_buffer(1 DOWNTO 0);
						S_AXI_RVALID <= '1';
						-- update buffer & index
						-- shift the current active values of one position
						RDATA_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RDATA_buffer), C_M_AXI_DATA_WIDTH));
						RLAST_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RLAST_buffer), 1));
						RID_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RID_buffer), C_M_AXI_ID_WIDTH));
						RRESP_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RRESP_buffer), 2));
						read_buffer_index <= read_buffer_index - 1;
						-- M_AXI_RREADY set to '1'
						M_AXI_RREADY <= '1';
					END IF;
				ELSE
					-- M_AXI_RVALID is 1
					-- S_AXI_RREADY = 1, M_AXI_RVALID = 1
					IF read_buffer_index = 0 THEN
						-- S_AXI_RREADY = 1, M_AXI_RVALID = 1, read_buffer_index = 0
						-- buffering
						RDATA_buffer ((C_M_AXI_DATA_WIDTH * (read_buffer_index + 1)) - 1 DOWNTO C_M_AXI_DATA_WIDTH * read_buffer_index) <= M_AXI_RDATA;
						RLAST_buffer (read_buffer_index) <= M_AXI_RLAST;
						RID_buffer((C_M_AXI_ID_WIDTH * (read_buffer_index + 1)) - 1 DOWNTO C_M_AXI_ID_WIDTH * read_buffer_index) <= inverse_mapping(M_AXI_RID);
						RRESP_buffer((2 * (read_buffer_index + 1)) - 1 DOWNTO 2 * read_buffer_index) <= M_AXI_RRESP;
						-- update
						S_AXI_RVALID <= '0';
						S_AXI_RDATA <= (OTHERS => '0');
						S_AXI_RLAST <= '0';
						S_AXI_RID <= (OTHERS => '0');
						S_AXI_RRESP <= (OTHERS => '0');
						read_buffer_index <= read_buffer_index + 1;
						-- M_AXI_RREADY set to '1'
						M_AXI_RREADY <= '1';
					ELSIF read_buffer_index = READ_BURST_BUFFER_SIZE THEN
						-- S_AXI_RREADY = 1, M_AXI_RVALID = 1, read_buffer_index = READ_BURST_BUFFER_SIZE 
						-- the value of M_AXI_RREADY is currently at '0' but the mapper will capture the next transaction on the next clock
						-- send the response
						S_AXI_RDATA <= RDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						S_AXI_RLAST <= RLAST_buffer(0);
						S_AXI_RID <= RID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_RRESP <= RRESP_buffer(1 DOWNTO 0);
						S_AXI_RVALID <= '1';
						-- update buffer
						-- shift the current active values of one position
						RDATA_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RDATA_buffer), C_M_AXI_DATA_WIDTH));
						RLAST_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RLAST_buffer), 1));
						RID_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RID_buffer), C_M_AXI_ID_WIDTH));
						RRESP_buffer <= STD_LOGIC_VECTOR(shift_right(unsigned(RRESP_buffer), 2));
						read_buffer_index <= read_buffer_index - 1;
						-- M_AXI_RREADY set to '1'
						M_AXI_RREADY <= '1';
					ELSE
						-- S_AXI_RREADY = 1, M_AXI_RVALID = 1, read_buffer_index = (1 to READ_BURST_BUFFER_SIZE - 1)
						-- a new transaction is buffered and another is sent so read_buffer_index keep the same value
						-- send the response
						S_AXI_RDATA <= RDATA_buffer(C_M_AXI_DATA_WIDTH - 1 DOWNTO 0);
						S_AXI_RLAST <= RLAST_buffer(0);
						S_AXI_RID <= RID_buffer(C_M_AXI_ID_WIDTH - 1 DOWNTO 0);
						S_AXI_RRESP <= RRESP_buffer(1 DOWNTO 0);
						S_AXI_RVALID <= '1';
						-- update buffer
						-- shift the current active values of one position and set the new one. The index to use is the previous one (read_buffer_index).
						-- in this case i cannot use shift_right because it would overwrite the new entry
						RDATA_buffer <= shift_and_new_entry(RDATA_buffer, M_AXI_RDATA, C_M_AXI_DATA_WIDTH, read_buffer_index - 1);
						RLAST_buffer <= shift_and_new_entry(RLAST_buffer, M_AXI_RLAST, 1, read_buffer_index - 1);
						RID_buffer <= shift_and_new_entry(RID_buffer, inverse_mapping(M_AXI_RID), C_M_AXI_ID_WIDTH, read_buffer_index - 1);
						RRESP_buffer <= shift_and_new_entry(RRESP_buffer, M_AXI_RRESP, 2, read_buffer_index - 1);
						-- a new transaction is buffered and another is sent so read_buffer_index has the same value, M_AXI_RREADY is still '1'
						M_AXI_RREADY <= '1';
					END IF;
				END IF;
			END IF;
			------------- RSP channel ------------- 

			------------------------------------------------------------------- READ CHANNEL -------------------------------------------------------------------	
			-- introut (TODO)
			introut <= introut_read OR introut_write;
		END IF;
	END PROCESS;

END ARCHITECTURE implementation;

