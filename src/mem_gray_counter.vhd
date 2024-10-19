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

entity mem_gray_counter is

    generic (
      M    : integer;
      logM : integer;
      N    : integer;
      logN : integer);
    port (
      start, ck, reset : in  std_logic;
      bin              : in  std_logic_vector(logM-1 downto 0);
      bin_count        : out std_logic_vector(logN-1 downto 0);
      gray_count       : out std_logic_vector(logN-1 downto 0));
  
end mem_gray_counter;

architecture beh of mem_gray_counter is

signal count_i : std_logic_vector( logN-1 downto 0 );

begin  -- beh

counter_p: process (ck, reset)
begin  -- process counter_p
  if reset = '0' then                   -- asynchronous reset (active low)
    count_i<=(others=>'0');
  elsif ck'event and ck = '1' then      -- rising clock edge
    if start='1' and conv_integer(bin)=0 then
	   if conv_integer(count_i)< (N-1) then
             count_i<=count_i+1;
           else
             count_i<=(others=>'0');
	   end if;
    elsif start='0' then
      count_i<=conv_std_logic_vector(0,logN);
    end if;
  end if;
end process counter_p;

gray_converter_p: process (count_i)
begin  -- process gray_converter_p
  gray_count( logN-1 ) <= count_i( logN-1 );
    for i in 0 to logN-2  loop
      gray_count(i) <= count_i(i) xor count_i(i+1); 
    end loop;  -- i

end process gray_converter_p;
  
bin_count<=count_i;

end beh;
