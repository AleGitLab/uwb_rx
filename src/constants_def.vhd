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

package constants_def is

  constant  M           : integer := 8;
  constant  N           : integer := 8;
  constant  NQ          : integer := 4;
  constant  logM        : integer := 3;
  constant  logN        : integer := 3;
  constant  NSYMBW      : integer := 4;                 -- number of simbol for a word (from spreadsheet)
  constant  NBIT1SYMB   : integer := logM;              -- number of bit of one symbol
  constant  logMN       : integer := logM + logN;
  constant  DIMMEM      : integer := 12288;             -- dimension of total memory
  constant  NBANKS      : integer := 4;                 -- number of banks (from spreadsheet)
  constant  NBIT1WORD   : integer := NSYMBW*NBIT1SYMB;
  constant  NROW1BANK   : integer := (DIMMEM/NBANKS)/NBIT1WORD;
  constant  NADD1BANK   : integer := 8;                 -- log2 NROW1BANK
  constant  NBITDEMUX   : integer := 2;                 -- log2 NBANKS
  constant  NBITDEMUXB  : integer := 2;

 
  type arr_add is array (0 to NBANKS-1) of std_logic_vector(NADD1BANK-1 downto 0);	 
  type arr_data is array (0 to NBANKS-1) of std_logic_vector(NBIT1WORD-1 downto 0);
  type arr_inQ is array (0 to NSYMBW-1) of std_logic_vector(NBIT1SYMB-1 downto 0);
  
end constants_def;

package body constants_def is

end constants_def;
