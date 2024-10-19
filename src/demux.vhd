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

entity demux is
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
end demux;

architecture beh of demux is

begin  -- beh
  
  demux_p: process (ser_in, ctrl, reset)
  begin  -- process demux_p
    if reset = '0' then
      par_out<=(others=>(others=>'0'));
    else
      par_out( conv_integer(ctrl) ) <= ser_in;
    end if;
  end process demux_p;

end beh;
