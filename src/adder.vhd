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
use ieee.std_logic_unsigned.all;

entity adder is
    generic (
      N  : integer;
      NQ : integer);
    port (
      a : in  std_logic_vector(NQ-1 downto 0);
      b : in  std_logic_vector(NQ+N-2 downto 0);
      c : out std_logic_vector(NQ+N-2 downto 0));
end adder;


architecture beh of adder is

begin  -- beh

  c <= a + b;

end beh;
