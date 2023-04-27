----------------------------------------------------------------------------------
-- Engineer: Daniel Shala, Jurij Scandola
--
-- Module Name: project_reti_logiche
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_w : in STD_LOGIC;

           o_z0 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z1 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z2 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z3 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_done : out STD_LOGIC;

           o_mem_addr : out STD_LOGIC_VECTOR(15 DOWNTO 0);
           i_mem_data : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_mem_we : out STD_LOGIC;
           o_mem_en : out STD_LOGIC);
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    TYPE state_type IS (IDLE, HEADER, GET_ADDR, WAIT_RAM, GET_DATA, WAIT_DATA,WRITE_OUT, DONE);
    SIGNAL state_curr, state_next : state_type;
    SIGNAL selected_out, selected_out_next : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL o_mem_addr_next: STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL mem_reg, mem_reg_next: STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL o_z0_next, sav_z0_reg, z0_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_z1_next, sav_z1_reg, z1_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_z2_next, sav_z2_reg, z2_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_z3_next, sav_z3_reg, z3_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL mem_en_next, mem_we_next : STD_LOGIC := '0';
    SIGNAL o_done_next : STD_LOGIC := '0';

BEGIN
    PROCESS (i_clk, i_rst)
    BEGIN
        IF(i_rst = '1') THEN
            state_curr <= IDLE;
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            o_done <= '0';
            mem_reg <= "0000000000000000";
            sav_z0_reg <= "00000000";
            sav_z1_reg <= "00000000";
            sav_z2_reg <= "00000000";
            sav_z3_reg <= "00000000";

        ELSIF (rising_edge(i_clk)) THEN
            state_curr <= state_next;
            o_mem_addr <= o_mem_addr_next;
            selected_out <= selected_out_next;
            mem_reg <= mem_reg_next;
            o_done <= o_done_next;
            o_z0 <= o_z0_next;
            o_z1 <= o_z1_next;
            o_z2 <= o_z2_next;
            o_z3 <= o_z3_next;
            sav_z0_reg <= z0_reg;
            sav_z1_reg <= z1_reg;
            sav_z2_reg <= z2_reg;
            sav_z3_reg <= z3_reg;
            o_mem_we <= mem_we_next;
            o_mem_en <= mem_en_next;
        END IF;
    END PROCESS;

    PROCESS(state_curr, i_start, i_w, mem_reg, mem_reg_next, i_mem_data, z0_reg, z1_reg, z2_reg, z3_reg, sav_z0_reg, sav_z1_reg, sav_z2_reg, sav_z3_reg, selected_out_next, selected_out, mem_en_next, mem_we_next)
        BEGIN
        mem_reg_next <= mem_reg;
        o_mem_addr_next <= "0000000000000000";
        selected_out_next <= selected_out;
        o_done_next <= '0';
        o_z0_next <= "00000000";
        o_z1_next <= "00000000";
        o_z2_next <= "00000000";
        o_z3_next <= "00000000";
        z0_reg <= sav_z0_reg;
        z1_reg <= sav_z1_reg;
        z2_reg <= sav_z2_reg;
        z3_reg <= sav_z3_reg;
        mem_we_next <= '0';
        mem_en_next <= '0';
        state_next <= state_curr;

        CASE state_curr IS
            WHEN IDLE =>
                IF (i_start = '1') THEN
                    selected_out_next(1) <= i_w;
                    state_next <= HEADER;
                END IF;

            WHEN HEADER =>
                selected_out_next(0) <= i_w;
                state_next <= GET_ADDR;

            WHEN GET_ADDR =>
                IF (i_start = '0') THEN
                    o_mem_addr_next <= mem_reg;
                    mem_en_next <= '1';
                    state_next <= WAIT_RAM;
                ELSE
                    mem_reg_next <= mem_reg(14 DOWNTO 0) & i_w;
                END IF;

            WHEN WAIT_RAM =>
                o_mem_addr_next <= mem_reg;
                mem_en_next <= '1';
                state_next <= GET_DATA;

            WHEN GET_DATA =>
                o_mem_addr_next <= mem_reg;
                mem_en_next <= '1';
                CASE selected_out IS
                    WHEN "00" =>
                        z0_reg <= i_mem_data;
                    WHEN "01" =>
                        z1_reg <= i_mem_data;
                    WHEN "10" =>
                        z2_reg <= i_mem_data;
                    WHEN "11" =>
                        z3_reg <= i_mem_data;
                    WHEN others => null;
                END CASE;
                state_next <= WAIT_DATA;

            WHEN WAIT_DATA =>
                o_mem_addr_next <= mem_reg;
                mem_en_next <= '1';
                state_next <= WRITE_OUT;

            WHEN WRITE_OUT =>
                mem_en_next <= '0';
                o_done_next <= '1';
                mem_reg_next <= "0000000000000000";
                o_mem_addr_next <= mem_reg;
                o_z0_next <= sav_z0_reg;
                o_z1_next <= sav_z1_reg;
                o_z2_next <= sav_z2_reg;
                o_z3_next <= sav_z3_reg;
                state_next <= DONE;

            WHEN DONE =>
                o_done_next <= '0';
                state_next <= IDLE;
                selected_out_next <= "00";
                o_mem_addr_next <= "0000000000000000";

        END CASE;
    END PROCESS;
END behavioral;
