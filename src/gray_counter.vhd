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

entity gray_counter is

    generic (
      M    : integer;
      logM : integer);
    port (
      ck, reset, start : in  std_logic;
      bin_count        : out std_logic_vector(logM-1 downto 0);
      gray_count       : out std_logic_vector(logM-1 downto 0));
		
end gray_counter;


architecture beh of gray_counter is

signal bin_count_i : std_logic_vector(logM-1 downto 0);

begin  -- beh

counter_p: process (ck, reset)
begin  -- process counter_p
  if reset = '0' then                   -- asynchronous reset (active low)
    bin_count_i<=conv_std_logic_vector(1,logM); -- (others=>'0');
  elsif ck'event and ck = '1' then      -- rising clock edge
    if start='1' then
      bin_count_i<=bin_count_i+1;
    end if;-- purpose: 
  end if;
end process counter_p;

bin_count <= bin_count_i;

gray_converter_p: process (bin_count_i)
begin  -- process gray_converter_p
  gray_count( logM-1 ) <= bin_count_i( logM-1 );
    for i in 0 to logM-2  loop
      gray_count(i) <= bin_count_i(i) xor bin_count_i(i+1); 
    end loop;  -- i

end process gray_converter_p;



end beh;
