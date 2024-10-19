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


entity ctrl_FSM is
  
  generic (
    M    : integer ;
    N    : integer ;
    NQ   : integer ;
    logM : integer ;
    logN : integer );

  port (
    ck                    : in std_logic;
    reset                 : in std_logic;
    start                 : in std_logic;
    demux_freeze          : out  std_logic;     -- active low
    add_reg_freeze        : out  std_logic;     -- active low
    force_zero            : out  std_logic;     -- active low
    bin_count             : out  std_logic_vector(logM-1 downto 0);
    demux_ctrl            : out  std_logic_vector(logM-1 downto 0);
    mux_ctrl              : out  std_logic_vector(logM-1 downto 0);
    comp_force_zero       : out  std_logic;     -- active low
    comparator_in_freeze  : out  std_logic;     -- active low
    comparator_out_freeze : out  std_logic);    -- active low);
    

end ctrl_FSM;


architecture struct of ctrl_FSM is

  component mod_N_counter
    generic (
      M    : integer;
      N    : integer;
      logM : integer;
      logN : integer);
    port (
      start             : in  std_logic;
      ck                : in  std_logic;
      reset             : in  std_logic;
      bin               : in  std_logic_vector(logM-1 downto 0);
      count             : out std_logic_vector(logN-1 downto 0));
  end component;  

  component gray_counter
    generic (
      M    : integer;
      logM : integer);
    port (
      ck, reset, start : in  std_logic;
      bin_count        : out std_logic_vector(logM-1 downto 0);
      gray_count       : out std_logic_vector(logM-1 downto 0));
  end component;

  signal count : std_logic_vector(logN-1 downto 0);
  signal gray_count, bin_count_i, bin_count_ii,  demux_ctrl_i : std_logic_vector(logM-1 downto 0);
  signal add_reg_freeze_i, start_i, start_ii, demux_ctrl_freeze, comparator_in_freeze_i, comp_force_zero_i, comparator_out_freeze_i : std_logic;

begin  -- struct


  start_i_p: process (ck, reset)
  begin  -- process start_i_p
    if reset = '0' then                 -- asynchronous reset (active low)
      start_i<='0';
      start_ii<='0';
    elsif ck'event and ck = '1' then    -- rising clock edge
      start_i <= start;
      start_ii <= start_i;
    end if;
  end process start_i_p;
    
    mod_N : mod_N_counter
      generic map (
        M => M,
        N => N,
        logM => logM,
        logN => logN)
      port map (
        start => start,
        ck    => ck,
        reset => reset,
        bin   => bin_count_ii,
        count => count);

    gray : gray_counter
      generic map (
        M => M,
		  logM => logM)
      port map (
        ck         => ck,
        reset      => reset,
        start      => start,
        bin_count  => bin_count_ii,
        gray_count => gray_count);

    add_reg_freeze_i <= not(start);
    add_reg_freeze <= not(add_reg_freeze_i);

    force_zero_p: process (count)
    begin  -- process force_zero_p
      if conv_integer(count) = 0 then
        force_zero<='0';
      else
        force_zero<='1';
      end if;
    end process force_zero_p;

    demux_ctrl_i_p: process (ck, reset)
    begin  -- process demux_ctrl_i_p
      if reset = '0' then               -- asynchronous reset (active low)
        demux_ctrl_i<=(others=>'0');
      elsif ck'event and ck = '1' then  -- rising clock edge
        demux_ctrl_i<=gray_count;
      end if;
    end process demux_ctrl_i_p;


    L1_p: process (demux_ctrl_i, comparator_in_freeze_i, reset)
    begin  -- process L1_p
	   if reset='0' then
		  demux_ctrl<=(others=>'0');
      elsif comparator_in_freeze_i = '0' then
        demux_ctrl <= demux_ctrl_i;
      end if;
    end process L1_p;

    mux_ctrl<=gray_count;

  demux_ctrl_freeze_p: process (count)
  begin  -- process demux_ctrl_freeze_p
    if conv_integer(count)=N-1 then
      demux_ctrl_freeze<='1';
    else
      demux_ctrl_freeze<='0';
    end if;
  end process demux_ctrl_freeze_p;

  demux_freeze<= not(comparator_in_freeze_i);


  comparator_in_freeze_i_p: process (ck, reset)
  begin  -- process comparator_in_freeze_p
    if reset = '0' then                 -- asynchronous reset (active low)
      comparator_in_freeze_i<='0';
    elsif ck'event and ck = '1' then    -- rising clock edge
      comparator_in_freeze_i<=demux_ctrl_freeze;
    end if;
  end process comparator_in_freeze_i_p;


  comparator_in_freeze<=comparator_in_freeze_i;
                 
    comparator_out_freeze_i_p: process (count, gray_count, start_ii)
    begin  -- process comparator_out_i_freeze_p
      if ( conv_integer(count)=0 and conv_integer(gray_count)=1 and start_ii /= '0' ) then
        comparator_out_freeze_i<='1';
      else
        comparator_out_freeze_i<='0';
      end if;
    end process comparator_out_freeze_i_p;

    comparator_out_freeze_p: process (ck, reset)
    begin  -- process comparator_out_freeze_p
      if reset = '0' then               -- asynchronous reset (active low)
        comparator_out_freeze<='0';
      elsif ck'event and ck = '1' then  -- rising clock edge
        comparator_out_freeze<=comparator_out_freeze_i;
      end if;
    end process comparator_out_freeze_p;

  comp_force_zero_i_p: process (count, gray_count)
  begin  -- process comp_force_zero_i_p
    if conv_integer(count)=N-1 nand conv_integer(gray_count)=1 then
      comp_force_zero_i<='1';
    else
      comp_force_zero_i<='0';
    end if;
  end process comp_force_zero_i_p;

  comp_force_zero_p: process (ck, reset)
  begin  -- process comp_force_zero_p
    if reset = '0' then                 -- asynchronous reset (active low)
      comp_force_zero<='0';
    elsif ck'event and ck = '1' then    -- rising clock edge
      comp_force_zero<=comp_force_zero_i;
    end if;
  end process comp_force_zero_p;


  bin_count_p: process (ck, reset)
  begin  -- process bin_count_p
    if reset = '0' then                 -- asynchronous reset (active low)
      bin_count<=(others=>'0');
		bin_count_i<=(others=>'0');
    elsif ck'event and ck = '1' then    -- rising clock edge
	   bin_count_i<=bin_count_ii;
      bin_count<=bin_count_i;
    end if;
  end process bin_count_p;
  

end struct;
