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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity max_detector is
  
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
    mux_code          : in  std_logic_vector(logM-1 downto 0) );
  
end max_detector;

architecture struct of max_detector is

signal precedent_sum, precedent_sum_i : std_logic_vector(NQ+N-2 downto 0);  -- precedent sum connected to comparator in feedback
signal out_code, int_code: std_logic_vector(logM-1 downto 0);  -- demodulated code  
signal mux_ctrl: std_logic;            -- internal signal for latch enable and clock gating
signal out_comp : std_logic_vector(NQ+N-2 downto 0);
signal int_adder_out : std_logic_vector(NQ+N-2 downto 0);


component Preprocess_comp
  generic (
    M  : integer;
    N  : integer;
    NQ : integer);
  port (
    reset        : in  std_logic;
    out_comp     : out std_logic_vector(NQ+N-2 downto 0);
    ina          : in  std_logic_vector(NQ+N-2 downto 0);
    inb          : in  std_logic_vector(NQ+N-2 downto 0);
    mux_ctrl_out : out std_logic);
end component;

begin  -- struct


precedent_sum_i_p: process (precedent_sum, comp_force_zero)
begin  -- process precedent_sum_i_p
  for i in 0 to NQ+N-2 loop
    precedent_sum_i(i)<= precedent_sum(i) and comp_force_zero;
  end loop;  -- i
end process precedent_sum_i_p;

inst_comp : Preprocess_comp generic map (
  M  => M,
  N  => N,
  NQ => NQ)
  port map (
    reset        => reset,
    out_comp     => out_comp,
    ina          => precedent_sum_i,
    inb          => int_adder_out,
    mux_ctrl_out => mux_ctrl);

-- purpose: input flip flop 
-- type   : sequential
-- inputs : int_GCLK, reset, adder_out
-- outputs: int_adder_out
p_reg: process (clk, reset)
begin  -- process p_reg
  if reset = '0' then                   -- asynchronous reset (active low)
    int_adder_out <= (others => '0');
  elsif clk'event and clk = '1' then    -- rising clock edge
  if max_detector_CG='1' then
    int_adder_out <= adder_out;
  end if;
  end if;
end process p_reg;

-- purpose: flip flop to store precedent sum
-- type   : sequential
-- inputs : int_GCLK, reset, out_comp
-- outputs: precedent_sum
p_feedback_sum: process (clk, reset)
begin  -- process p_feedback_sum
  if reset = '0' then                   -- asynchronous reset (active low)
    precedent_sum <= (others => '0');
  elsif clk'event and clk = '1' then    -- rising clock edge
  if max_detector_CG='1' then
    precedent_sum <= out_comp;
  end if;
  end if;
end process p_feedback_sum;

p_latch_code: process (mux_ctrl, reset, int_code, clk)
begin  -- process p_latch_code
  if reset = '0' then
    out_code <= (others => '0');
  elsif  clk = '0' then
    if mux_ctrl='1' then
      out_code <= int_code;
    end if;
  end if;
end process p_latch_code;

-- purpose: flip flop to store demux code
-- type   : sequential
-- inputs : int_GCLK, reset, mux_code
-- outputs: int_code
p_code: process (clk, reset)
begin  -- process p_code
  if reset = '0' then                   -- asynchronous reset (active low)
    int_code <= (others => '0');
  elsif clk'event and clk = '1' then    -- rising clock edge
  if max_detector_CG='1' then
    int_code <= mux_code;
  end if;
  end if;
end process p_code;

codeout_p: process (clk, reset)
begin  -- process codeout_p
  if reset = '0' then                   -- asynchronous reset (active low)
    codeout <= (others => '0');
  elsif clk'event and clk = '1' then    -- rising clock edge
    codeout <= out_code;
  end if;
end process codeout_p;

dataout <= out_comp;

end struct;
