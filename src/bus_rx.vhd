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
use ieee.std_logic_1164.all;        --  library IEEE with standard common definitions and functions
use ieee.std_logic_unsigned.all;    
use ieee.std_logic_arith.all;
use work.constants_def.all;

entity Bus_rx is
  
    port (
    ck                          : in  std_logic;
    reset                       : in  std_logic;
    enable_rx_ff                : in  std_logic;
    enable_rx_ff_i              : in  std_logic;
    start                       : out std_logic;
    bus_data                    : in  std_logic_vector(M-1 downto 0);
    dataout                     : out std_logic_vector(NBIT1SYMB-1 downto 0));  -- demodulated data

end Bus_rx;

architecture struct of Bus_rx is

signal bus_data_i, data_outD, unmod_data, unmod_data_i: std_logic_vector(M-1 downto 0);
signal start_i : std_logic;

begin  -- struct

  bus_data_i <= bus_data;
  
  -- purpose: instantation of input ff
  -- type   : sequential
  -- inputs : ck, reset, bus_data
  -- outputs: bus_data_i
  ff_in: process (ck, reset)
  begin  -- process ff_in
    if reset = '0' then                 -- asynchronous reset (active low)
      data_outD <= (others => '0');
    elsif ck'event and ck = '1' then    -- rising clock edge
      if enable_rx_ff = '1' then             -- clock gating
        data_outD <= bus_data_i;
      end if;
    end if;
  end process ff_in;

  xor_inst: for i in M-1 downto 0 generate
      unmod_data(i) <= bus_data_i(i) xor data_outD(i);
  end generate xor_inst;

-- purpose: comparator for signal start_i
-- type   : combinational
-- inputs : unmod_data
-- outputs: start_i
comp_start_inst: process (unmod_data)
begin  -- process comp_start_inst
  if conv_integer(unmod_data) /= 0 then
    start_i <= '1';
  else
    start_i <= '0';
  end if;
end process comp_start_inst;


start_p: process (ck, reset)
begin  -- process start_p
  if reset = '0' then                   -- asynchronous reset (active low)
    start<='0';
  elsif ck'event and ck = '1' then      -- rising clock edge
    start<=start_i;
  end if;
end process start_p;

  unmod_data_i_p: process (ck, reset)
  begin  -- process unmod_data_i_p
    if reset = '0' then                 -- asynchronous reset (active low)
      unmod_data_i <= (others=>'0');
    elsif ck'event and ck = '1' then    -- rising clock edge
        if enable_rx_ff_i = '1' then
          unmod_data_i <= unmod_data;
        end if;
    end if;
  end process unmod_data_i_p;


  -- purpose: encoder for rx receiver
  -- type   : combinationalint_ctrl_demux
  -- inputs : unmod_data_i
  -- outputs: dataout
  enc_rx_inst: process (unmod_data_i)
  begin  -- process dec_rx_inst
    if conv_integer(unmod_data_i) = 0 then
      dataout <= (others => '0');	 
    else
      dataout <= (others => '0');
      for j in M-1 downto 0 loop
        if unmod_data_i(j) = '1' then
          dataout <= conv_std_logic_vector(j,NBIT1SYMB);
        end if;
      end loop;  -- j
    end if;
  end process enc_rx_inst;
  

end struct;
