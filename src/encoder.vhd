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


entity encoder is

    generic (
      M    : integer;
      logM : integer);
    port (
      en_in  : in  std_logic_vector(logM-1 downto 0);
      en_out : out std_logic_vector(M-1 downto 0) );
  
end encoder;


architecture beh of encoder is

begin  -- beh

  en_p: process (en_in)
  begin  -- process en_p
    en_out<=(others=>'0');
    en_out(conv_integer(en_in))<='1';
  end process en_p;

end beh;
