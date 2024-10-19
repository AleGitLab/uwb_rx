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

entity Preprocess_comp is
  
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

end Preprocess_comp;

architecture beh of Preprocess_comp is

signal latch_enable : std_logic;        -- latch enable signal for precomputation comparator
signal int_ina, int_inb : std_logic_vector(NQ+N-2 downto 0);  -- internal signal that propagate inputs
signal comp_a, comp_b : std_logic_vector(NQ+N-2 downto 0);  -- inputs of comparator
signal int_mux_ctrl : std_logic;            -- mux control signal

begin

latch_enable <= not(int_ina(NQ+N-2) xor int_inb(NQ+N-2));
comp_a(NQ+N-2) <= int_ina(NQ+N-2);
comp_b(NQ+N-2) <= int_inb(NQ+N-2);
int_inb <= inb;
int_ina <= ina;

 -- purpose: latches for precomputation
 -- type   : combinational
 -- inputs : latch_enable, int_ina, int_inb
 -- outputs: comp_a, comp_b
p_latches_enable: process (latch_enable, int_ina, int_inb, reset)
 begin  -- process p_latches_enable
   if reset='0' then
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
-- outputs: int_mux_ctrl
p_comparator: process (comp_a, comp_b)
 begin  -- process p_comparator
   if comp_a >= comp_b then
     int_mux_ctrl <= '0';
   else
     int_mux_ctrl <= '1';
  end if;
 end process p_comparator;

-- purpose: output mux
-- type   : combinational
-- inputs : int_ina, int_inb
-- outputs: out_comp
p_mux: process (int_ina, int_inb,int_mux_ctrl)
begin  -- process p_mux
  if int_mux_ctrl = '0' then
    out_comp <= int_ina;
  else
    out_comp <= int_inb;
  end if;
end process p_mux;

mux_ctrl_out <= int_mux_ctrl;

end beh;
