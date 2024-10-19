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

entity digital_backend is
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
      comp_force_zero       : in  std_logic;    -- active low
      comparator_in_freeze  : in  std_logic;    -- active low
      comparator_out_freeze : in  std_logic);   -- active low);
end digital_backend;


architecture architectural of digital_backend is


component Pos_PU is
  
  generic (
    M    : integer;
    N    : integer;
    NQ   : integer;
    logM : integer);
                 
  port (
    ck                  : in  std_logic;
    reset               : in  std_logic;
    datain              : in  std_logic_vector(NQ-1 downto 0);
    demux_freeze        : in  std_logic;    -- active low
    add_reg_freeze      : in  std_logic;    -- active low
    force_zero          : in  std_logic;    -- active low
    demux_ctrl          : in  std_logic_vector(logM-1 downto 0);
    mux_ctrl            : in  std_logic_vector(logM-1 downto 0);
    sum_out             : out std_logic_vector(NQ+N-2 downto 0));

end component;

component max_detector is
  
  generic (
    M    : integer ;
    N    : integer ;
    NQ   : integer ;
	 logM : integer);
  
  port (
    clk               : in  std_logic;
    reset             : in  std_logic;
    max_detector_CG   : in  std_logic;
    comp_force_zero   : in  std_logic;
    codeout           : out std_logic_vector(logM-1 downto 0);  -- demodulated code
    dataout           : out std_logic_vector(NQ+N-2 downto 0);  -- energy value
    adder_out         : in  std_logic_vector(NQ+N-2 downto 0);
    mux_code          : in  std_logic_vector(logM-1 downto 0));
  
end component;

signal dataout_i : std_logic_vector(NQ+N-2 downto 0);
signal codeout_i : std_logic_vector(logM-1 downto 0);
signal sum_out : std_logic_vector(NQ+N-2 downto 0);

begin  -- architectural


  PU_inst : Pos_PU
     generic map (
       M  => M,
       N  => N,
       NQ => NQ,
		 logM => logM)
     port map (
       ck             => ck,
       reset          => reset,
       datain         => DIN,
       demux_freeze   => demux_freeze,
       add_reg_freeze => add_reg_freeze,
       force_zero     => force_zero,
       demux_ctrl     => demux_ctrl,
       mux_ctrl       => mux_ctrl,
       sum_out        => sum_out);

  max_det_inst : max_detector
     generic map (
       M  => M,
       N  => N,
       NQ => NQ,
       logM => logM)
     port map (
       clk             => ck,
       reset           => reset,
       comp_force_zero => comp_force_zero,
       max_detector_CG => comparator_in_freeze,
       codeout         => codeout_i,
       dataout         => dataout_i,
       adder_out       => sum_out,
       mux_code        => bin_count);

  outputs_p: process (codeout_i, dataout_i, comparator_out_freeze)
  begin  -- process outputs_p
    if comparator_out_freeze='1' then
      codeout<=codeout_i;
      dataout<=dataout_i;
    end if;
  end process outputs_p;
  

end architectural;
