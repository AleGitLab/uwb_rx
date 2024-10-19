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

entity Clock_gating is
  
  port (
    clk        : in  std_logic;
    enable     : in  std_logic;
    GCLK       : out std_logic);

end Clock_gating;

architecture struct of Clock_gating is

  signal int_enable : std_logic;

begin  -- struct

-- purpose: active low latch
-- type   : combinational
-- inputs : enable, clk
-- outputs: int_enable
p_neg_latch: process (enable, clk)
begin  -- process p_neg_latch
  if clk = '0' then
    int_enable <= enable;
  end if;
end process p_neg_latch;
  

  GCLK <= clk and int_enable; 

  
end struct;
