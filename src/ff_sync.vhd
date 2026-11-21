library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ff1_sync is
    Port (
        clk : in  STD_LOGIC;
        d   : in  STD_LOGIC;
        q   : out STD_LOGIC
    );
end ff1_sync;

architecture Behavioral of ff1_sync is
    signal ff2_in : STD_LOGIC := '1';
    signal ff2_out : STD_LOGIC := '1';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            ff2_in <= d;
            ff2_out <= ff2_in;
        end if;
    end process;
    q <= ff2_out;
end Behavioral;

