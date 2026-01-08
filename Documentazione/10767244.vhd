library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity project_reti_logiche is

    port(
        i_clk       :   in  std_logic;
        i_rst       :   in  std_logic;
        i_start     :   in  std_logic;
        i_add       :   in  std_logic_vector(15 DOWNTO 0);
        i_k         :   in  std_logic_vector(9 DOWNTO 0);
        o_done      :   out std_logic;
        o_mem_addr  :   out std_logic_vector(15 DOWNTO 0);
        i_mem_data  :   in  std_logic_vector(7 DOWNTO 0);
        o_mem_data  :   out std_logic_vector(7 DOWNTO 0);
        o_mem_we    :   out std_logic;
        o_mem_en    :   out std_logic
    );
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    type state_type is (
        START, --stato iniziale della macchina     
        FETCH_DATA_RAM, --si chiede alla memoria RAM il dato
        WAIT_RAM, --si attende la risposta della RAM 
        GET_WORD, --il dato su cui si andrà a elaborare è inviata al modulo
        SETUP, --il dato inviato dalla RAM viene salvato in un apposito segnale, pronto per essere elaborato
        ELAB_WORD, --elaborazione del dato e la sua credibilità
        WRITE_WORD, --scrittura del dato nella memoria RAM
        WRITE_CRED, --scrittura della credibilità nella memoria RAM
        DONE_WRITING, --RAM viene disattivata
        NEXT_STEP, --decremento del valore di k
        VERIFY, --verifica se sono ancora rimaste delle parole della sequenza da elaborare
        DONE, --fine elaborazione
        DONE_WAIT --attesa di un'ulteriore elaborazione
    );
    
    signal state, next_state           : state_type; --memorizza lo stato della FSM
    signal o_done_next                 : std_logic; --memorizza il valore prossimo di o_done
    signal o_mem_en_next, o_mem_we_next: std_logic; --memorizza il valore prossimo di o_mem_en e di o_mem_we
    signal o_mem_addr_next             : std_logic_vector (15 downto 0); --memorizza il valore prossimo di o_mem_addr
    signal o_mem_data_next             : std_logic_vector (7 downto 0); --memorizza il valore prossimo di o_mem_data
    signal temp, temp_next: std_logic_vector (7 downto 0); --memorizzano i valori della sequenza man mano elaborati da mettere in uscita
    signal address, address_next: std_logic_vector (15 downto 0); --memorizzano l'indirizzo da cui recuperare il dato richiesto e successivamente scriverne il dato ottenuto dall'elaborazione
    signal input, input_next: std_logic_vector (7 downto 0); --memorizzano il valore in ingresso dato dalla RAM
    signal cred,cred_next: std_logic_vector (7 downto 0); --memorizza la credibilità del dato in analisi;
    signal k, k_next: std_logic_vector (9 downto 0); --contiene il numero di parole della sequenza ancora da elaborare
    signal k_fixed, k_fixed_next:  std_logic_vector (9 downto 0); --contiene il numero delle parole della sequenza K

begin
    --primo processo
    process (i_clk, i_rst)
    begin 
        if (i_rst = '1') then
            --reset delle uscite
            o_done <= '0';
            o_mem_en <= '0';
            o_mem_we <= '0';
            o_mem_addr <= "0000000000000000";
            o_mem_data <= "00000000";
            
            -- reset dei segnali
            address <= "0000000000000000";
            k <= "0000000000";
            k_fixed <= "0000000000";
            input <= "00000000";
            temp <= "00000000";
            cred <= "00000000";
            
            state <= START;
        elsif (i_rst = '0' and rising_edge(i_clk)) then
            -- Aggiornamento dei segnali al fronte di salita del clock
            o_done        <= o_done_next;
            o_mem_en      <= o_mem_en_next;
            o_mem_we      <= o_mem_we_next;
            o_mem_addr    <= o_mem_addr_next;
            o_mem_data    <= o_mem_data_next;
            address <= address_next;
            k <= k_next;
            k_fixed <= k_fixed_next;
            input <= input_next;
            temp <= temp_next;
            cred <= cred_next;
            
            state <= next_state;
       end if;
    end process;
	
	--secondo processo
    process (state, i_start, i_k, i_add, i_mem_data, address, k, k_fixed, input, temp, cred)     
    begin
        o_done_next      <= '0';
        o_mem_en_next    <= '0';
        o_mem_we_next    <= '0';
        o_mem_addr_next  <= "0000000000000000";
        o_mem_data_next <= "00000000";

        address_next <= address;
        k_next <= k;
        k_fixed_next <= k_fixed;
        input_next <= input;
        temp_next <= temp;
        cred_next <= cred;
        next_state <= state;
        
        --macchina a stati
        case state is
        
            when START =>
                if (i_start = '1') then
                    address_next  <= i_add;
                    k_next <= i_k;
                    k_fixed_next <= i_k;
                    next_state   <= FETCH_DATA_RAM;
                end if;
                
            when FETCH_DATA_RAM =>
                o_mem_en_next    <= '1';
                o_mem_we_next    <= '0';
                o_mem_addr_next  <= address;
                next_state <= WAIT_RAM;
            
            when WAIT_RAM =>
               next_state <= GET_WORD;
            
            when GET_WORD =>
               next_state <= SETUP;
                
            when SETUP =>
                input_next <= i_mem_data;
                next_state <= ELAB_WORD;
            
            --l'algoritmo dell'elaborazione della parola e della sua credibilità è spiegato a parole nella relazione (paragrafo 2.3.2)
            when ELAB_WORD =>
                if (input /= "00000000") then
                    temp_next <= input;
                    cred_next <= "00011111";
                elsif (input = "00000000" and k = k_fixed) then
                    temp_next <= "00000000";
                    cred_next <= "00000000";
                else
                    temp_next <= temp;
                    if (cred = "00000000") then
                        cred_next <= "00000000";
                    else 
                        cred_next <= std_logic_vector ( signed (cred) - 1);
                    end if;
                end if ;
                next_state <= WRITE_WORD;
                
            when WRITE_WORD =>
                o_mem_en_next    <= '1';
                o_mem_we_next    <= '1';
                o_mem_addr_next  <= address;
                o_mem_data_next <= temp;
                
                address_next <= std_logic_vector ( signed (address) + 1);
                next_state <= WRITE_CRED;
                
            when WRITE_CRED =>
                o_mem_en_next    <= '1';
                o_mem_we_next    <= '1';
                o_mem_addr_next  <= address;
                o_mem_data_next <= cred;
    
                address_next <= std_logic_vector ( signed (address) + 1);
                next_state <= DONE_WRITING;
                
            when DONE_WRITING =>
                o_mem_en_next <= '0';
                o_mem_we_next <= '0';
                next_state <= NEXT_STEP;
                
            when NEXT_STEP =>
                    k_next       <= k - "000000001";
                    next_state   <= VERIFY;
                
            when VERIFY =>
                if (k = "0000000000") then
                    address_next <= "0000000000000000";
                    o_done_next <= '1';
                    next_state   <= DONE;
                else
                    address_next <= address;
                    next_state   <= FETCH_DATA_RAM;
                end if;
                
            when DONE =>
                o_done_next <= '1';
                next_state <= DONE_WAIT;
            
            when DONE_WAIT =>
                if (i_start = '0') then
                    -- Reset dei segnali dopo aver completato
                    temp_next       <= "00000000";
                    address_next   <= "0000000000000000";
                    input_next      <= "00000000";
                    cred_next      <= "00000000";
                    k_next          <= "0000000000";
                    k_fixed_next        <= "0000000000";
                    next_state <= START;
                end if;
        end case;
    end process;
    
end behavioral;