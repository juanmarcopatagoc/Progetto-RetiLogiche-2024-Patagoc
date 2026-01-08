# Progetto di Reti Logiche 
## Prova Finale del Corso di Reti Logiche – Politecnico di Milano, A.A. 2023/2024**
**Votazione: 30/30L**

# Descrizione
Il progetto consiste nello sviluppo di un modulo hardware in grado di interfacciarsi con una memoria. A partire da una sequenza di parole di ingresso, definita dall’indirizzo del primo elemento e dalla sua lunghezza, il modulo deve completare la sequenza sostituendo eventuali valori nulli con l’ultimo valore valido precedentemente letto. A ciascuna parola viene inoltre associato un valore di credibilità: tale valore è pari a 31 nel caso in cui non avvengano sostituzioni, mentre in presenza di sostituzioni viene calcolato decrementando la credibilità della parola precedente.

# Implementazione
Il componente è implementato in VHDL come una Macchina a Stati Finiti (FSM) a 13 stati. L'architettura utilizza due processi (sequenziale e combinatorio) per gestire l'interfaccia con la memoria RAM, l'elaborazione della sequenza dati e il calcolo della credibilità secondo le specifiche.

---

## Final Project for the Logic Design Course – Politecnico di Milano, A.Y. 2023/2024
**Grade: 30/30 cum laude**

# Description
The project involves the development of a hardware module capable of interfacing with a memory. Starting from an input sequence of words, defined by the address of the first element and its length , the module must complete the sequence by replacing any null values with the last valid value previously read. A credibility value is also associated with each word: this value is set to 31 if no substitutions occur, while in the presence of substitutions, it is calculated by decrementing the credibility of the previous word.

## Implementation
The component is implemented in VHDL as a Finite State Machine (FSM) with 13 states. The architecture uses two processes (sequential and combinatorial) to manage the RAM interface, data sequence processing, and credibility calculation according to specifications.