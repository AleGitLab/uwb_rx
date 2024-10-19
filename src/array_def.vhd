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


package array_def is
  constant  K  : integer:=4; -- M/2!!!!!
  constant  N  : integer:=8;
  constant  NQ : integer:=4;

	 
  type arr is array (0 to integer(K)-1) of std_logic_vector(NQ+N-2 downto 0);

end array_def;

package body array_def is

end array_def;
