--  ---------------------------------------------------------------------------
--   -- Authors: Colonna Alessandro, Cutrupi Massimo
--   -- Last modification: 11/03/2008
--   -- Revision: 1.0
--   -- Desc: Low-Power System Design project
--   --
--   -- UWB baseband processing power optimization
--   -- Digital-Backend + Bus Encoder/Decoder + Memory Multi-Banks & Multi-
--   -- Symbol for word optimization (see constants_def.vhd & array_def.vhd for
--   -- information)
--   --
--  ---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;        --  library IEEE with standard common definitions and functions
use ieee.std_logic_unsigned.all;    
use ieee.std_logic_arith.all;
use work.constants_def.all;

entity Rx_and_store is
  
  port (
    ck,reset           : in  std_logic;
    bus_data           : in  std_logic_vector(M-1 downto 0);
    enable_banks       : out std_logic_vector(NBANKS-1 downto 0);
    DATAOUT            : out arr_data;  -- input data
    ADDOUT             : out arr_add);  -- addresses

end Rx_and_store;

architecture struct of Rx_and_store is

signal ctrl_demux_i : std_logic_vector(NBITDEMUX-1 downto 0);
signal ctrl_demux_buf_i : std_logic_vector(NBITDEMUXB-1 downto 0);
signal store_reg_CG_i : std_logic_vector(NSYMBW-1 downto 0);  -- active low
signal enable_latch_i, start_i, enable_rx_ff, enable_rx_ff_i : std_logic;
signal address_i : std_logic_vector(NADD1BANK-1 downto 0);
signal datain_i : std_logic_vector(NBIT1SYMB-1 downto 0);
signal bus_data_i : std_logic_vector(M-1 downto 0);

component sel_mem_banks

    generic( NSYMBW     : integer:=NSYMBW;         -- number of simbol for a word (from spreadsheet)<--- ATTENTION!!!!
             NBIT1SYMB  : integer:=NBIT1SYMB;      -- number of bit of one symbol 
             NBANKS     : integer:=NBANKS;     	   -- number of banks (from spreadsheet)<--- ATTENTION!!!!
             NADD1BANK  : integer:=NADD1BANK;      -- number of bit of address
             NBIT1WORD  : integer:=NBIT1WORD;
             NBITDEMUX  : integer:=NBITDEMUX;
             NBITDEMUXB : integer:=NBITDEMUXB); 
	 
	 port (
           ctrl_demux        : in   std_logic_vector(NBITDEMUX-1 downto 0);
           ctrl_demux_buf    : in   std_logic_vector(NBITDEMUXB-1 downto 0);
           address           : in   std_logic_vector(NADD1BANK-1 downto 0);
           datain            : in   std_logic_vector(NBIT1SYMB-1 downto 0);
           store_reg_CG      : in   std_logic_vector(NSYMBW-1 downto 0);  -- active low
           reset,clk         : in   std_logic;
           enable_latch      : in   std_logic;
           enable_banks      : out  std_logic_vector(NBANKS-1 downto 0);
           DATAOUT           : out  arr_data; 	-- input data
           ADDOUT            : out  arr_add);	-- addresses

end component;

component Bus_rx
  
    port (
    ck,reset,enable_rx_ff       : in  std_logic;
    enable_rx_ff_i              : in  std_logic;
    start                       : out std_logic;
    bus_data                    : in  std_logic_vector(M-1 downto 0);
    dataout                     : out std_logic_vector(NBIT1SYMB-1 downto 0));  -- demodulated data

end component;

component mem_FSM
  
  generic( NSYMBW     : integer:= NSYMBW;         -- number of simbol for a word (from spreadsheet)<--- ATTENTION!!!!
           NBIT1SYMB  : integer:= NBIT1SYMB;      -- number of bit of one symbol 
           NBANKS     : integer:= NBANKS;     	  -- number of banks (from spreadsheet)<--- ATTENTION!!!!
           NADD1BANK  : integer:= NADD1BANK;      -- number of bit of address
           NBIT1WORD  : integer:= NBIT1WORD;
           NBITDEMUX  : integer:= NBITDEMUX;
           NBITDEMUXB : integer:= NBITDEMUXB); 
			  
  port (
    ck                          : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    latch_enable                : out std_logic;
    enable_rx_ff                : out std_logic;
    enable_rx_ff_i              : out std_logic;	 
    store_reg_CG                : out std_logic_vector(NSYMBW-1 downto 0);  -- active low
    address                     : out std_logic_vector(NADD1BANK-1 downto 0);
    ctrl_demux_buf              : out std_logic_vector(NBITDEMUXB-1 downto 0); 
    ctrl_demux                  : out std_logic_vector(NBITDEMUX-1 downto 0));  
			  
end component;


begin  -- struct

bus_data_i <= bus_data;

-- mem_FSM instantiation... 
  mem_FSM_inst: mem_FSM
    generic map (
      NSYMBW     => NSYMBW,             -- number of simbol for a word (from spreadsheet)<--- ATTENTION!!!!
      NBIT1SYMB  => NBIT1SYMB,          -- number of bit of one symbol 
      NBANKS     => NBANKS,             -- number of banks (from spreadsheet)<--- ATTENTION!!!!
      NADD1BANK  => NADD1BANK ,         -- number of bit of address
      NBIT1WORD  => NBIT1WORD,
      NBITDEMUX  => NBITDEMUX,
      NBITDEMUXB => NBITDEMUXB)
    port map (
      ck    => ck,
      reset => reset,
      start => start_i,
      latch_enable   => enable_latch_i,
      enable_rx_ff => enable_rx_ff,
      enable_rx_ff_i => enable_rx_ff_i,
      store_reg_CG  => store_reg_CG_i,
      address => address_i,
      ctrl_demux_buf  => ctrl_demux_buf_i,
      ctrl_demux => ctrl_demux_i);
		
-- selection logic memory banks instantiation... 
  sel_mem_banks_inst : sel_mem_banks 
    generic map (
      NSYMBW 	 => NSYMBW,             -- number of simbol for a word (from spreadsheet)<--- ATTENTION!!!!
      NBIT1SYMB  => NBIT1SYMB,          -- number of bit of one symbol 
      NBANKS     => NBANKS,     	-- number of banks (from spreadsheet)<--- ATTENTION!!!!
      NADD1BANK  => NADD1BANK,          -- number of bit of address
      NBIT1WORD  => NBIT1WORD,
      NBITDEMUX  => NBITDEMUX,
      NBITDEMUXB => NBITDEMUXB)
    port map (
      ctrl_demux        => ctrl_demux_i,
      ctrl_demux_buf    => ctrl_demux_buf_i,
      address           =>address_i,
      datain            => datain_i,
      store_reg_CG      => store_reg_CG_i,
      reset             => reset,
      clk               => ck,
      enable_banks      => enable_banks,
      enable_latch      => enable_latch_i,
      DATAOUT           => DATAOUT,	
      ADDOUT            => ADDOUT);

-- Bus receiver instantation...
rx_bus_inst : Bus_rx port map (
  ck       		=> ck,
  start    		=> start_i,
  enable_rx_ff          => enable_rx_ff,  --change
  enable_rx_ff_i        => enable_rx_ff_i,
  reset    		=> reset,
  bus_data 		=> bus_data_i,
  dataout  		=> datain_i);
		
end struct;
