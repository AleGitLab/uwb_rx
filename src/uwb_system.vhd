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

entity uwb_system is
  
  generic (
    M    : integer := 8;
    N    : integer := 8;
    NQ   : integer := 4;
    logM : integer := 3;
    logN : integer := 3);

  port (
    ck_slow      : in  std_logic;
    ck           : in  std_logic;
    reset        : in  std_logic;
    start        : in  std_logic;
    DIN          : in  std_logic_vector(NQ-1 downto 0);
    DOUT         : out std_logic_vector(M-1 downto 0);
    DBUS         : out std_logic_vector(M-1 downto 0);
    MEMADDBUS    : out arr_add;
    MEMDATABUS   : out arr_data;
    GCLK_mem     : out std_logic_vector(NBANKS-1 downto 0);    
    voutset      : out std_logic);

end uwb_system;


architecture struct of uwb_system is

  signal DATA : std_logic_vector(logM-1 downto 0);
  signal T_CG, dvalid : std_logic;
  signal DBUS_i : std_logic_vector(M-1 downto 0);

component double_digital_backend
    generic (
      N  : integer   :=N;
      M  : integer   :=M;
      NQ : integer   := NQ;
      logM : integer := logM;
      logN : integer := logN;
      ABITS: integer := 2);
    port (
      DIN       : in  std_logic_vector(NQ-1 downto 0);
      start     : in  std_logic;
      DOUT      : out std_logic_vector(logM-1 downto 0);
      T_CG      : out std_logic;
      dvalid    : out std_logic;
      ck_slow, reset : in  std_logic);
end component;

component bus_encoder
  generic (
    M    : integer;
    logM : integer);
  port (
    DATA              : in  std_logic_vector(logM-1 downto 0);
    T_CG              : in  std_logic;  -- active hi
    dvalid, ck, reset : in  std_logic;
    DBUS              : out std_logic_vector(M-1 downto 0));
end component;
  
component rx_and_store is
  port (
    ck,reset           : in  std_logic;
    bus_data           : in  std_logic_vector(M-1 downto 0);
    enable_banks       : out std_logic_vector(NBANKS-1 downto 0);
    DATAOUT            : out arr_data;  -- input data
    ADDOUT             : out arr_add);  -- addresses
end component;

              
begin  -- struct


  ddb_inst : double_digital_backend
    generic map (
      M  => M,
      N  => N,
      NQ => NQ,
      logM => logM,
      logN => logN,
      ABITS => 2)
    port map (
      DIN     => DIN,
      start   => start,
      DOUT    => DATA,
      T_CG    => T_CG,
      dvalid  => dvalid,
      ck_slow => ck_slow,
      reset   => reset);

  bus_enc_inst : bus_encoder
    generic map (
      M    => M,
      logM => logM)
    port map (
      DATA   => DATA,
      T_CG   => T_CG,
      dvalid => dvalid,
      ck     => ck_slow,
      reset  => reset,
      DBUS   => DBUS_i);


    rx_and_store_inst : rx_and_store port map (
      ck           => ck,
      reset        => reset,
      bus_data     => DBUS_i,
      enable_banks => GCLK_mem,
      DATAOUT      => MEMDATABUS,
      ADDOUT       => MEMADDBUS);

DBUS <= DBUS_i;


end struct;
