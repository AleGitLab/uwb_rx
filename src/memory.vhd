------------------------------------------------------------
--    Synchronous SRAM - BEHAVIOURAL MODEL
--
--    DO NOT SYNTHESIZE!!
--
--    Tipically it is possible to create memories
--    with special tools such as memory generators...
--    This is only a MODEL...
--
--    It includes the entity and the architecture of
--    a behavioural SRAM memory which can be instantiated 
--    as the final unit in your UWB project
--
--    Place this memory in your project as a component 
--    to verify the overall system behaviour
--
--    Please, create a different system entity and 
--    architecture top hierarchy for synthesis purposes 
--    neglecting this component... 
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;        --  library IEEE with standard common definitions and functions
use IEEE.std_logic_unsigned.all;    
--use IEEE.std_logic_arith.all;     --  this library is useful for appropriate function which 
--					e.g. convert integer to standard_logic_vector...
--					You could use this library in your project files if generic 
--					conversion (for parametric M, N cases) are needed

entity memory is

  generic( DBITS: integer;             
           ABITS: integer);           
           --WORDS: integer:=1024); 			-- WORDS=2**ABITS
  port( DIN:	in std_logic_vector(DBITS-1 downto 0); 	-- input data
        DOUT:   out std_logic_vector(DBITS-1 downto 0); -- output data
        ADD: in std_logic_vector(ABITS-1 downto 0);  	-- addresses
	ck: 	in std_logic;
	WR: in std_logic;
        OE: in std_logic);

end memory;

architecture behavioral of memory is
-- THE MEMORY IS MODELED AS A MATRIX OF 2^ABITS ELEMENTS X DBITS!!
-- 2** MEANS 2^
type datamem is array (0 to 2**ABITS-1) of std_logic_vector(DBITS-1 downto 0);
signal myarray : datamem;

begin
  
-- write and read process
-- the behaviour of the memory is simply given by this 
-- process...

  pwr: process(ck)
  begin

-- On positive clock event... (rising edge) 
-- synchronous SRAM...
    if ck'event and ck='1' then
-- Checks if the Write Enable signal is '1'...
      if WR='1' then
-- If so, updates the marray (which models the overall memory) 
-- with the input data DIN
        myarray(conv_integer(ADD))<=DIN;
-- Otherwise if WR is '0' and OE is '1'...
      elsif WR='0' then
        if OE='1' then
-- Read data and gives it as DOUT to the extern world... 
          DOUT <= myarray(conv_integer(ADD));
        else
-- If OE is '0' puts the memory output at high impedence with this assignment... 
          DOUT <= (others => 'Z');
        end if;
      end if;
    end if;
  end process;
    
end behavioral;
 
