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

entity Demod_logic is
  
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

end Demod_logic;

architecture struct of Demod_logic is

signal latch_enable : std_logic;                                -- latch enable signal for precomputation comparator
signal int_ina, int_inb : std_logic_vector(NQ+N-2 downto 0);    -- internal signal that propagate inputs
signal comp_a, comp_b : std_logic_vector(NQ+N-2 downto 0);      -- inputs of comparator
signal int_mux_ctrl : std_logic;                                -- mux control signal
signal unmod_code : std_logic_vector(logM-1 downto 0);
  
begin  -- struct

latch_enable <= not(int_ina(NQ+N-2) xor int_inb(NQ+N-2));
comp_a(NQ+N-2) <= int_ina(NQ+N-2);
comp_b(NQ+N-2) <= int_inb(NQ+N-2);
int_inb <= data_in_b;
int_ina <= data_in_a;
  
 -- purpose: latches for precomputation
 -- type   : combinational
 -- inputs : latch_enable, int_ina, int_inb
 -- outputs: comp_a, comp_b
p_latches_enable: process (latch_enable, int_ina, int_inb, reset)
 begin  -- process p_latches_enable
   if reset = '0' then
     comp_a(NQ+N-2-1 downto 0) <= (others=>'0');
     comp_b(NQ+N-2-1 downto 0) <= (others=>'0');	  
   elsif latch_enable = '1' then
     comp_a(NQ+N-2-1 downto 0) <= int_ina(NQ+N-2-1 downto 0);
     comp_b(NQ+N-2-1 downto 0) <= int_inb(NQ+N-2-1 downto 0);
   end if;
 end process p_latches_enable;

-- purpose: comparator
-- type   : combinational
-- inputs : comp_a, comp_b
-- outputs: int_mux_ctrl_
p_comparator: process (comp_a, comp_b)
 begin  -- process p_comparator
   if comp_a >= comp_b then
     int_mux_ctrl <= '0';
   else
     int_mux_ctrl <= '1';
  end if;
 end process p_comparator;

-- purpose: internal mux to choose correct code
-- type   : combinational
-- inputs : code_in_a, code_in_b, int_mux_ctrl
-- outputs: unmod_code
p_mux: process (code_in_a, code_in_b,int_mux_ctrl)
begin  -- process p_mux
  if int_mux_ctrl = '0' then
    unmod_code <= code_in_a;
  else
    unmod_code <= code_in_b;
  end if;
end process p_mux;

dem_code(0) <= int_mux_ctrl;
dem_code(logM downto 1) <= unmod_code;

end struct;
