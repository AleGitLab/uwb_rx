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

use work.constants_def.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bus_encoder is
  
  generic (
    M    : integer;
    logM : integer);

  port (
    DATA              : in  std_logic_vector(logM-1 downto 0);
    T_CG              : in  std_logic;  -- active hi
    dvalid, ck, reset : in  std_logic;
    DBUS              : out std_logic_vector(M-1 downto 0));

end bus_encoder;


architecture struct of bus_encoder is

  component encoder
    generic (
      M    : integer;
      logM : integer);
    port (
      en_in  : in  std_logic_vector(logM-1 downto 0);
      en_out : out std_logic_vector(M-1 downto 0) );
  end component;

  signal en_out, DBUS_i, T_in : std_logic_vector(M-1 downto 0);

begin  -- struct


  enc_inst : encoder
    generic map (
      M    => M,
      logM => logM)
    port map (
      en_in  => DATA,
      en_out => en_out);


  T_in_p: process (en_out, dvalid)
  begin  -- process T_in_p
    for i in 0 to M-1 loop
      T_in(i)<=en_out(i)and dvalid;
    end loop;  -- i
  end process T_in_p;



  T_proc: process (ck, reset)
  begin  -- process T_proc
    if reset = '0' then                 -- asynchronous reset (active low)
      DBUS_i<=(others=>'0');
    elsif ck'event and ck = '1' then    -- rising clock edge
      if T_CG='1' then
        
        for i in 0 to M-1 loop
          if T_in(i)='1' then
            DBUS_i(i)<=not( DBUS_i(i) );
          end if;
        end loop;  -- i
        
      end if;
    end if;
  end process T_proc;

DBUS<=DBUS_i;
  
  

end struct;
