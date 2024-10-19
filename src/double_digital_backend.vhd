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

use work.constants_def.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity double_digital_backend is
    generic (
      N  : integer   ;
      M  : integer   ;
      NQ : integer   ;
      logM : integer ;
      logN : integer ;
      ABITS: integer );
    port (
      DIN       : in  std_logic_vector(NQ-1 downto 0);
      start     : in  std_logic;
      DOUT      : out std_logic_vector(logM-1 downto 0);
      T_CG      : out std_logic;
      dvalid    : out std_logic;
      ck_slow   : in  std_logic;
      reset     : in  std_logic);
end double_digital_backend;


architecture struct of double_digital_backend is


component ctrl_FSM is
  
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
    demux_freeze          : out  std_logic;    -- active low
    add_reg_freeze        : out  std_logic;    -- active low
    force_zero            : out  std_logic;    -- active low
    bin_count             : out  std_logic_vector(logM-1 downto 0);
    demux_ctrl            : out  std_logic_vector(logM-1 downto 0);
    mux_ctrl              : out  std_logic_vector(logM-1 downto 0);
    comp_force_zero       : out  std_logic;     -- active low
    comparator_in_freeze  : out  std_logic;     -- active low
    comparator_out_freeze : out  std_logic);    -- active low);

end component;

  component digital_backend

    generic (
      N    : integer ;
      M    : integer ;
      NQ   : integer ;
      logM : integer);
    port (
      DIN                   : in  std_logic_vector(NQ-1 downto 0);
      dataout               : out std_logic_vector(NQ+N-2 downto 0);  -- energy value
      codeout               : out std_logic_vector(logM-1 downto 0);  -- demodulated code
      ck, reset             : in  std_logic;
      demux_freeze          : in  std_logic;    -- active low
      add_reg_freeze        : in  std_logic;    -- active low
      force_zero            : in  std_logic;    -- active low
      bin_count             : in  std_logic_vector(logM-1 downto 0);
      demux_ctrl            : in  std_logic_vector(logM-1 downto 0);
      mux_ctrl              : in  std_logic_vector(logM-1 downto 0);
      comp_force_zero       : in  std_logic;  -- active low
      comparator_in_freeze  : in  std_logic;    -- active low
      comparator_out_freeze : in  std_logic);    -- active low);
    
  end component;

  component neg_digital_backend

    generic (
      N    : integer ;
      M    : integer ;
      NQ   : integer ;
      logM : integer);
    port (
      DIN               : in  std_logic_vector(NQ-1 downto 0);
      dataout           : out std_logic_vector(NQ+N-2 downto 0);  -- energy value
      codeout           : out std_logic_vector(logM-1 downto 0);  -- demodulated code
      ck, reset         : in  std_logic;
      demux_freeze      : in  std_logic;    -- active low
      add_reg_freeze        : in  std_logic;    -- active low
      force_zero            : in  std_logic;    -- active low
      bin_count             : in  std_logic_vector(logM-1 downto 0);
      demux_ctrl            : in  std_logic_vector(logM-1 downto 0);
      mux_ctrl              : in  std_logic_vector(logM-1 downto 0);
      comp_force_zero       : in  std_logic;  -- active low
      comparator_in_freeze  : in  std_logic;    -- active low
      comparator_out_freeze : in  std_logic);    -- active low);
    
  end component;

  component Demod_logic

    generic (
      M    : integer;
      N    : integer;
      NQ   : integer;
      logM : integer);

    port (
      reset     : in  std_logic;
      code_in_a : in  std_logic_vector(logM-1 downto 0);
      code_in_b : in  std_logic_vector(logM-1 downto 0);
      data_in_a : in  std_logic_vector(NQ+N-2 downto 0);
      data_in_b : in  std_logic_vector(NQ+N-2 downto 0);
      dem_code  : out std_logic_vector(logM downto 0));
    
  end component;



  signal demux_freeze, add_reg_freeze, force_zero, comp_force_zero, comparator_in_freeze, comparator_out_freeze : std_logic;
  signal bin_count, demux_ctrl, mux_ctrl : std_logic_vector(logM-2 downto 0); -- log2(M/2)-1 downto 0
  signal demux_freeze_i, force_zero_i, comp_force_zero_i, comparator_in_freeze_i, comparator_out_freeze_i, comparator_out_freeze_ii : std_logic;
  signal bin_count_i, demux_ctrl_i, mux_ctrl_i : std_logic_vector(logM-2 downto 0); -- log(M/2) downto 0
  signal dataout_pos, dataout_pos_i, dataout_neg, dataout_neg_i : std_logic_vector(NQ+N-2 downto 0);
  signal codeout_pos, codeout_pos_i, codeout_neg, codeout_neg_i: std_logic_vector(logM-2 downto 0); -- log(M/2) downto 0


begin  -- struct


  FSM_inst : ctrl_FSM
      generic map (
       M  => integer( M/2 ),
       N  => N,
       NQ => NQ,
       logM => logM-1,
       logN => logN)
      port map (
        ck                    => ck_slow,
        reset                 => reset,
        start                 => start,
        demux_freeze          => demux_freeze,
        add_reg_freeze        => add_reg_freeze,
        force_zero            => force_zero,
        bin_count             => bin_count,
        demux_ctrl            => demux_ctrl,
        mux_ctrl              => mux_ctrl,
        comp_force_zero       => comp_force_zero,
        comparator_in_freeze  => comparator_in_freeze,
        comparator_out_freeze => comparator_out_freeze);

  pos_backend : digital_backend

    generic map (
      M  => integer(M / 2),
      N  => N,
      NQ => NQ,
      logM => logM-1)
    port map (
      DIN                   => DIN,
      dataout               => dataout_pos,
      codeout               => codeout_pos,
      ck                    => ck_slow,
      reset                 => reset,
      demux_freeze          => demux_freeze,
      add_reg_freeze        => add_reg_freeze,
      force_zero            => force_zero,
      bin_count             => bin_count,
      demux_ctrl            => demux_ctrl,
      mux_ctrl              => mux_ctrl,
      comp_force_zero       => comp_force_zero,
      comparator_in_freeze  => comparator_in_freeze,
      comparator_out_freeze => comparator_out_freeze);



  neg_FSM_p: process (ck_slow, reset)
  begin  -- process neg_FSM_p
    if reset = '0' then                 -- asynchronous reset (active low)
        demux_freeze_i          <= '0';
        force_zero_i            <= '0';
        bin_count_i             <= (others=>'0');
        demux_ctrl_i            <= (others=>'0');
        mux_ctrl_i              <= (others=>'0');
        comp_force_zero_i       <= '0';
        comparator_in_freeze_i  <= '0';
        comparator_out_freeze_i <= '0';
    elsif ck_slow'event and ck_slow = '0' then  -- rising clock edge
        demux_freeze_i          <= demux_freeze;
        force_zero_i            <= force_zero;
        bin_count_i             <= bin_count;
        demux_ctrl_i            <= demux_ctrl;
        mux_ctrl_i              <= mux_ctrl;
        comp_force_zero_i       <= comp_force_zero;
        comparator_in_freeze_i  <= comparator_in_freeze;
        comparator_out_freeze_i <= comparator_out_freeze;
    end if;
  end process neg_FSM_p;


  neg_backend : neg_digital_backend

    generic map (
      M  => integer(M / 2),
      N  => N,
      NQ => NQ,
      logM => logM-1)
    port map (
      DIN                   => DIN,
      dataout               => dataout_neg,
      codeout               => codeout_neg,
      ck                    => ck_slow,
      reset                 => reset,
      demux_freeze          => demux_freeze_i,
      add_reg_freeze        => add_reg_freeze,
      force_zero            => force_zero_i,
      bin_count             => bin_count_i,
      demux_ctrl            => demux_ctrl_i,
      mux_ctrl              => mux_ctrl_i,
      comp_force_zero       => comp_force_zero_i,
      comparator_in_freeze  => comparator_in_freeze_i,
      comparator_out_freeze => comparator_out_freeze_i);

  comparator_out_freeze_ii_p: process (ck_slow, reset)
  begin  -- process comparator_out_freeze_ii_p
    if reset = '0' then                 -- asynchronous reset (active low)
      comparator_out_freeze_ii<='0';
    elsif ck_slow'event and ck_slow = '1' then  -- rising clock edge
      comparator_out_freeze_ii<=comparator_out_freeze_i;
    end if;
  end process comparator_out_freeze_ii_p;

  pipe_latches: process (dataout_pos, dataout_neg, codeout_pos, codeout_neg, comparator_out_freeze_ii)
  begin  -- process pipe_latches
    if comparator_out_freeze_ii='1' then
       dataout_pos_i<=dataout_pos;
       dataout_neg_i<=dataout_neg;
       codeout_pos_i<=codeout_pos;
       codeout_neg_i<=codeout_neg;      
    end if;
  end process pipe_latches;

  demod_inst : Demod_logic
    generic map (
      M  => integer(M / 2),
      N  => N,
      NQ => NQ,
      logM => logM-1)
    port map (
      reset     => reset,
      code_in_a => codeout_pos_i,-- (integer(ceil(log2( real(M / 2) )))-1 downto 0),
      code_in_b => codeout_neg_i,-- (integer(ceil(log2( real(M / 2) )))-1 downto 0),
      data_in_a => dataout_pos_i,
      data_in_b => dataout_neg_i,
      dem_code  => DOUT);-- (integer(ceil(log2( real(M / 2) ))) downto 0));


  dvalid_p: process (comparator_out_freeze_ii, reset)
  begin  -- process dvalid_p
    if reset = '0' then
      dvalid<='0';
    elsif comparator_out_freeze_ii='1' then
      dvalid<='1';
    end if;
  end process dvalid_p;
  
  T_CG <= comparator_out_freeze_ii;

end struct;
