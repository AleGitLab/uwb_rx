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
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.constants_def.all;

entity mem_FSM is
  
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
    
end mem_FSM;


architecture struct of mem_FSM is

  component mem_gray_counter
    generic (
      M    : integer;
      logM : integer;
      N    : integer;
      logN : integer);
    port (
      start, ck, reset : in  std_logic;
      bin              : in  std_logic_vector(logM-1 downto 0);
      bin_count        : out std_logic_vector(logN-1 downto 0);
      gray_count       : out std_logic_vector(logN-1 downto 0));
  end component;
  
  component mod_M_counter
    generic (
      M    : integer;
      logM : integer);
    port (
      start, ck, reset  : in  std_logic;
      bin_count         : out std_logic_vector(logM-1 downto 0));
  end component;

  component ADD_counter
     generic (
      NADD1BANK : integer;
      NBITDEMUX : integer);
    port (
      start, ck, reset : in  std_logic;
      enable           : in  std_logic;
      address          : out std_logic_vector(NADD1BANK-1 downto 0);
      ctrl_demux       : out std_logic_vector(NBITDEMUX-1 downto 0)); 
  end component;

  signal int_store_reg_CG : std_logic_vector(NSYMBW-1 downto 0);
  signal start_i, enable_rx_ff_ii, enable_rx_ff_iii, latch_enable_i, latch_enable_ii : std_logic; -- , start_i_i, address_enable 
  signal int_ctrl_demux_buf : std_logic_vector(NBITDEMUXB-1 downto 0);
  signal int_ctrl_demux : std_logic_vector(NBITDEMUX-1 downto 0);
  signal bin_count_i : std_logic_vector(logMN-1 downto 0);
  signal bin_count_i_i : std_logic_vector(NBITDEMUXB-1 downto 0);
  signal dec_ctrl_demux_buf : std_logic_vector(NSYMBW-1 downto 0);
  
begin  -- struct


start_i <= start;
store_reg_CG <= int_store_reg_CG;
ctrl_demux_buf <= int_ctrl_demux_buf;
ctrl_demux <= int_ctrl_demux;


inst_count_NSYMBW : mem_gray_counter generic map (
    M          => M*N,
    logM       => logMN,
    N          => NSYMBW,
    logN       => NBITDEMUXB)
  port map (
    start      => start_i,
    ck         => ck,
    reset      => reset,
    bin        => bin_count_i,
    bin_count  => bin_count_i_i,
    gray_count => int_ctrl_demux_buf);

  inst_count_MN : mod_M_counter generic map (
    M          => M*N,
    logM       => logMN)
  port map (
    start      => start_i,
    ck         => ck,
    reset      => reset,
    bin_count  => bin_count_i);

  ADD_counter_inst : ADD_counter generic map (
    NADD1BANK => NADD1BANK,
    NBITDEMUX => NBITDEMUX)
    port map (
      start      => start,
      ck         => ck,
      reset      => reset,
      enable     => latch_enable_ii,
      address    => address,
      ctrl_demux => int_ctrl_demux);

-- purpose: clock gating enables for rx ff
-- type   : combinational
-- inputs : int_bin_count_latch, bin_count_i
-- outputs: enable_rx_ff
rx_ff_CG_p: process (bin_count_i)
begin  -- mem_CG_p
  if conv_integer(bin_count_i) = M*N-1 then
	 enable_rx_ff <= '1';
  else
    enable_rx_ff <= '0';
  end if;

end process rx_ff_CG_p;

rx_ff_i_CG_p: process (bin_count_i)
begin  -- mem_CG_p
  if conv_integer(bin_count_i) = 2 then
	 enable_rx_ff_i <= '1';
  else
    enable_rx_ff_i <= '0';
  end if;

end process rx_ff_i_CG_p;

rx_ff_ii_CG_p: process (bin_count_i)
begin  -- mem_CG_p
  if conv_integer(bin_count_i) = 3 then
    enable_rx_ff_ii <= '1';
  else
    enable_rx_ff_ii <= '0';
  end if;

end process rx_ff_ii_CG_p;


rx_ff_iii_CG_p: process (bin_count_i)
begin  -- mem_CG_p
  if conv_integer(bin_count_i) = 4 then
    enable_rx_ff_iii <= '1';
  else
    enable_rx_ff_iii <= '0';
  end if;

end process rx_ff_iii_CG_p;

dec_ctrl_demux_buf_p: process (int_ctrl_demux_buf)
begin  -- process dec_ctrl_demux_buf_p
  dec_ctrl_demux_buf<=(others=>'0');
  dec_ctrl_demux_buf(conv_integer(int_ctrl_demux_buf))<='1';
end process dec_ctrl_demux_buf_p;

int_store_reg_CG_p: process (enable_rx_ff_ii, dec_ctrl_demux_buf)
begin  -- process int_store_reg_CG_p
  for i in 0 to NSYMBW-1 loop
    int_store_reg_CG(i)<=dec_ctrl_demux_buf(i) and enable_rx_ff_ii;
  end loop;  -- i
end process int_store_reg_CG_p;

latch_enable_ii_p: process (enable_rx_ff_iii, bin_count_i_i)
begin  -- process latch_enable_ii_p
  if enable_rx_ff_iii='1' and conv_integer(bin_count_i_i)= NSYMBW-1  then
    latch_enable_ii<='1';
  else
    latch_enable_ii<='0';
  end if;
end process latch_enable_ii_p;

latch_enable_i_p: process (ck, reset)
begin  -- process latch_enable_i
  if reset = '0' then                   -- asynchronous reset (active low)
    latch_enable_i<='0';
  elsif ck'event and ck = '1' then      -- rising clock edge
    latch_enable_i<=latch_enable_ii;
  end if;
end process latch_enable_i_p;

latch_enable<=latch_enable_i;


end struct;
