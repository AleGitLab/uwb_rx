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

entity sel_mem_banks is
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

end sel_mem_banks;

architecture beh of sel_mem_banks is

signal int_out_latch_i : std_logic_vector(NBIT1WORD-1 downto 0);
signal enable_store_reg : std_logic_vector(NSYMBW-1 downto 0);
signal demux_inQ , int_outD, int_out_latch: arr_inQ;
signal int_DATA : arr_data;
signal int_ADD : arr_add;
signal int_enable_latch : std_logic;
signal clks_enable : std_logic_vector(NBANKS-1 downto 0);

component pos_reg
    generic (
      M  : integer;
      N  : integer;
      NQ : integer);
    port (
      enable    : in  std_logic;
      inQ       : in  std_logic_vector(M*(NQ+N-1)-1 downto 0);
      outD      : out std_logic_vector( M*(NQ+N-1)-1 downto 0);
      ck, reset : in  std_logic);
end component;

component Clock_gating

  port (
    clk        : in  std_logic;
    enable     : in  std_logic;
    GCLK       : out std_logic);
  
end component;
  
begin  -- beh

enable_store_reg <= store_reg_CG; 
 
DATAOUT <= int_DATA;
int_enable_latch <= enable_latch;

reg_inst: for i in NSYMBW-1 downto 0 generate
  inst_reg : pos_reg generic map (
    M  => 1,
    N  => 1,
    NQ => NBIT1SYMB)
  port map (
    enable => enable_store_reg(i),
    inQ   => demux_inQ(i),
    outD  => int_outD(i),
    ck    => clk,
    reset => reset);
end generate reg_inst;

demux_data: process (int_out_latch_i, ctrl_demux)
begin  -- process demux_data
  int_DATA( conv_integer(ctrl_demux) ) <= int_out_latch_i;	 
end process demux_data;

adapt_array: for i in NSYMBW-1 downto 0  generate
  int_out_latch_i( ((i+1)*(NBIT1SYMB))-1 downto (i*(NBIT1SYMB)) ) <= int_out_latch(i);
end generate adapt_array;


-- purpose: latch array
-- type   : combinational
-- inputs : ck, reset, int_inQ
-- outputs: int_out_latch
latch_array: process (int_outD, int_enable_latch, reset)
begin  -- process latch_array
  if reset = '0' then
    int_out_latch <= (others=>(others=>'0'));
  else
    if int_enable_latch = '1' then
      int_out_latch <= int_outD;
    end if;
  end if;
end process latch_array; 

demux_buff: process (datain, ctrl_demux_buf)
  begin  -- process demux_buff
  
    demux_inQ <= (others=>(others=>'0'));
    demux_inQ( conv_integer(ctrl_demux_buf) ) <= datain;
	 
end process demux_buff;


demux_add: process (address, ctrl_demux)
begin  -- process demux_add
  int_ADD<=(others=>(others=>'0'));
  int_ADD( conv_integer(ctrl_demux) ) <= address;	 
end process demux_add;


ADDOUT_p: process (clk, reset)
begin  -- process ADDOUT_p
  if reset = '0' then                   -- asynchronous reset (active low)
    ADDOUT<=(others=>(others=>'0'));
  elsif clk'event and clk = '1' then      -- rising clock edge
    for i in 0 to NBANKS-1 loop
      if clks_enable(i) = '1' then
           ADDOUT(i)(NADD1BANK-1 downto 0)<=int_ADD(i)(NADD1BANK-1 downto 0);
      end if;
    end loop;  -- i
  end if;
end process ADDOUT_p;

clks_enable_p: process (int_enable_latch, ctrl_demux)
begin  -- process clks_enable_p
  clks_enable<=(others=>'0');
  clks_enable(conv_integer(ctrl_demux))<=int_enable_latch;
end process clks_enable_p;


mem_CG: for i in 0 to NBANKS-1 generate
  CG : Clock_gating
    port map (
      clk    => clk,
      enable => clks_enable(i),
      GCLK   => enable_banks(i));
end generate mem_CG;

end beh;
