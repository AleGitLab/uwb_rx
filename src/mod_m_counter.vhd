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

entity mod_M_counter is

    generic (
      M    : integer;
      logM : integer);
    port (
      start, ck, reset : in  std_logic;
      bin_count        : out std_logic_vector(logM-1 downto 0));
  
end mod_M_counter;

architecture beh of mod_M_counter is

signal count_i : std_logic_vector( logM-1 downto 0 );

begin  -- beh

counter_p: process (ck, reset)
begin  -- process counter_p
  if reset = '0' then                   -- asynchronous reset (active low)
    count_i<=(others=>'0');
  elsif ck'event and ck = '1' then      -- rising clock edge
    if start='1' then
      if conv_integer(count_i) < (M-1) then
        count_i<=count_i+1;
      else
        count_i<=(others=>'0');
      end if;
    else
      count_i<=conv_std_logic_vector(1,logM);
    end if;
  end if;
end process counter_p;

bin_count<=count_i;

end beh;
