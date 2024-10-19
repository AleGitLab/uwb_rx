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
use ieee.std_logic_unsigned.all;

entity mux is
    generic ( 
      M     : integer;
      N     : integer;
      NQ    : integer;
      logM  : integer);
    port (
      par_in  : in  arr;
      ser_out : out std_logic_vector(NQ+N-2 downto 0);
      ctrl    : in  std_logic_vector(logM-1 downto 0));
end mux;


architecture beh of mux is

begin  -- beh

mux_p: process (par_in, ctrl)
begin  -- process mux_p
  ser_out<= par_in ( conv_integer(ctrl) );
end process mux_p;

end beh;
