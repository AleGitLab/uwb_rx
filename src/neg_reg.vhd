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

entity neg_reg is
    generic (
      M  : integer;
      N  : integer;
      NQ : integer);
    port (
      enable    : in  std_logic;
      inQ       : in  std_logic_vector(M*(NQ+N-1)-1 downto 0);
      outD      : out std_logic_vector( M*(NQ+N-1)-1 downto 0);
      ck, reset : in  std_logic);
end neg_reg;


architecture beh of neg_reg is

begin  -- beh
                       
   neg_reg_p: process (ck, reset)
   begin  -- process neg_reg_p
     if reset = '0' then                 -- asynchronous reset (active low)
       outD<=(others=>'0');
     elsif ck'event and ck = '0' then    -- falling clock edge
	  if enable = '1' then
            outD<=inQ;
	  end if;
     end if;
   end process neg_reg_p;

  
end beh;
