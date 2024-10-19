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

use work.array_def.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Pos_PU is
  
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

end Pos_PU;

architecture struct of Pos_PU is

  signal int_add_a : std_logic_vector(NQ-1 downto 0);  -- first adder input
  signal int_add_b : std_logic_vector(NQ+N-2 downto 0);  -- second adder input
  signal int_add_out, int_demux_in : std_logic_vector(NQ+N-2 downto 0);  -- adder output
  signal int_mux_out : std_logic_vector(NQ+N-2 downto 0);  -- mux output
  signal int_demux_out : arr;  -- demux output
  signal int_mux_in: arr;  -- mux input
  
  component adder
    generic (
      N  : integer;
      NQ : integer);
    port (
      a : in  std_logic_vector(NQ-1 downto 0);
      b : in  std_logic_vector(NQ+N-2 downto 0);
      c : out std_logic_vector(NQ+N-2 downto 0));
  end component;


  component demux
    generic (
      M     : integer;
      N     : integer;
      NQ    : integer;
      logM  : integer);
    port (
      ser_in  : in  std_logic_vector(NQ+N-2 downto 0);
      reset   : in  std_logic;
      par_out : out arr;
      ctrl    : in  std_logic_vector(logM-1 downto 0)); -- era logK
  end component;

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

  component mux
    generic ( 
      M     : integer;
      N     : integer;
      NQ    : integer;
      logM  : integer);
    port (
      par_in  : in  arr;
      ser_out : out std_logic_vector(NQ+N-2 downto 0);
      ctrl    : in  std_logic_vector(logM-1 downto 0));
  end component;

  
begin  -- struct

  input_reg_a : pos_reg generic map (
    M  => 1,
    N  => 1,
    NQ => NQ)
    port map (
      enable=> add_reg_freeze,
      inQ   => datain,
      outD  => int_add_a,
      ck    => ck,
      reset => reset);

  input_reg_b : pos_reg generic map (
    M  => 1,
    N  => N,
    NQ => NQ)
    port map (
      enable=> add_reg_freeze,
      inQ   => int_mux_out,
      outD  => int_add_b,
      ck    => ck,
      reset => reset);

  inst_adder : adder generic map (
    N  => N,
    NQ => NQ)
    port map (
      a => int_add_a,
      b => int_add_b,
      c => int_add_out);

  inst_demux : demux generic map (
    M  => M,
    N  => N,
    NQ => NQ,
    logM => logM)
    port map (
      ser_in  => int_demux_in,
      par_out => int_demux_out,
      reset   => reset,
      ctrl    => demux_ctrl);
  
  inst_mux : mux generic map (
    M  => M,
    N  => N,
    NQ => NQ,
    logM => logM)
    port map (
      par_in  => int_mux_in,
      ser_out => int_mux_out,
      ctrl    => mux_ctrl);

  -- purpose: latches for demux freezing
  -- type   : combinational
  -- inputs : int_add_out, demux_freeze
  -- outputs: int_demux_in
  p_latch_demux_freeze: process (int_add_out, demux_freeze)
  begin  -- process p_latch_demux_freeze
    if demux_freeze = '1' then
      int_demux_in <= int_add_out;
    end if;
  end process p_latch_demux_freeze;


  int_mux_in_p: process (int_demux_out, force_zero)
  begin  -- process int_mux_in_p
    for i in M-1 downto 0 loop
      for j in NQ+N-2 downto 0 loop
        int_mux_in(i)(j) <= int_demux_out(i)(j) and force_zero; 
      end loop;  -- j
    end loop;  -- i
  end process int_mux_in_p; 

 sum_out <= int_add_out;  
  
end struct;
