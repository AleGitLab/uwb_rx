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
use work.constants_def.all;


entity ADD_counter is
     generic (
      NADD1BANK : integer;
      NBITDEMUX : integer);
    port (
      start, ck, reset : in  std_logic;
      enable           : in  std_logic;
      address          : out std_logic_vector(NADD1BANK-1 downto 0);
      ctrl_demux       : out std_logic_vector(NBITDEMUX-1 downto 0)); 
end ADD_counter;


architecture beh of ADD_counter is

  signal fl : std_logic;
  signal bin_count : std_logic_vector(NADD1BANK-1 downto 0);
  signal demux_bin_count : std_logic_vector(NBITDEMUX-1 downto 0);

begin  -- beh

  bin_count_p: process (ck, reset)
  begin  -- process bin_count_p
    if reset = '0' then                 -- asynchronous reset (active low)
      bin_count<=(others=>'0');
    elsif ck'event and ck = '1' then    -- rising clock edge
      if enable = '1'and start='1' and conv_integer(demux_bin_count)=integer(2**NBITDEMUX-1) then
        if conv_integer(bin_count) < integer(2**(NADD1BANK)-1) then
            bin_count<=bin_count+'1';
        else
          bin_count<=(others=>'0');
        end if;
      end if;
    end if;
  end process bin_count_p;



  demux_bin_count_p: process (ck, reset)
  begin  -- process demux_bin_count_p
    if reset = '0' then                 -- asynchronous reset (active low)
      demux_bin_count<=(others=>'0');
      fl<='0';
    elsif ck'event and ck = '1' then    -- rising clock edge
      if enable='1'and start='1' then
        if conv_integer(demux_bin_count)< integer(2**NBITDEMUX-1) then
          if fl='0' then
            fl<='1';
          else
            demux_bin_count<= demux_bin_count+'1';
          end if;
        else
          demux_bin_count<=(others=>'0');
        end if;
      end if;
    end if;
  end process demux_bin_count_p;

 address_gray_conv: process (bin_count)
 begin  -- process address_gray_conv
   address(NADD1BANK-1)<= bin_count(NADD1BANK-1);
   for i in 0 to NADD1BANK-2 loop
     address(i)<= bin_count(i) xor bin_count(i+1);
   end loop;  -- i
 end process address_gray_conv;


  demux_gray_conv: process (demux_bin_count)
  begin  -- process demux_gray_conv
    ctrl_demux(NBITDEMUX-1)<=demux_bin_count(NBITDEMUX-1);
    for i in 0 to NBITDEMUX-2 loop
      ctrl_demux(i)<=demux_bin_count(i) xor demux_bin_count(i+1);
    end loop;  -- i
  end process demux_gray_conv;



end beh;
