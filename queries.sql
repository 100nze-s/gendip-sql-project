/*
----------------------------------------------------------------------------------------------------
PROGETTO SQL: Analisi della Rappresentazione di Genere nella Diplomazia Globale (GenDip 1968-2021)
----------------------------------------------------------------------------------------------------

SCALETTA E STRUTTURA DELL'ANALISI:
Il presente file raccoglie le query SQL eseguite su PostgreSQL (pgAdmin) per esplorare 
il dataset "GenDip". L'analisi è suddivisa nelle seguenti fasi:

1. FASE DI CONTROLLO E STATISTICHE DESCRITTIVE GENERALI
    - Verifica della corretta importazione del dataset e conteggio dei record.
    - Distribuzione generale dei diplomatici per genere (gestione dei codici mancanti/sentinella).

2. TREND TEMPORALE ED EVOLUZIONE STORICA (1968 - 2021)
    - Andamento pluriennale della percentuale di donne diplomatiche.
    - Analisi dell'apertura storica verso cariche diplomatiche femminili nel corso dei decenni.

3. ANALISI GEOGRAFICA E MACRO-AREE
    - Esplorazione delle nomine per macro-regioni di invio e ricezione.
    - Differenze territoriali e geografie diplomatiche più inclini alla parità.

4. FATTORI POLITICI E CORRELAZIONI ISTITUZIONALI
    - Impatto delle Politiche Estere Femministe (FFP).
    - Relazione tra la rappresentanza femminile nei parlamenti interni e la carriera diplomatica estera.
*/


----------------------------------------------------------------------------------------------------
-- FASE 0: CREAZIONE DELLA TABELLA E PREPARAZIONE / IMPORTAZIONE DEL DATASET CSV
----------------------------------------------------------------------------------------------------

/*
  PASSAGGI PRELIMINARI PER L'IMPORTAZIONE:
  1. Preparazione del file: Prima dell'importazione su PostgreSQL, il dataset sorgente (GenDip_Dataset_1968-2021.xlsx) 
     è stato analizzato e convertito in formato CSV, verificando che la codifica dei caratteri fosse pulita 
     e che le colonne numeriche fossero compatibili (gestendo correttamente i codici mancanti o sentinella come '99' o '9999').
  2. Creazione della struttura (DDL): È stato eseguito il comando CREATE TABLE sottostante per definire 
     la tabella 'gendip_data' mappando ogni colonna con il tipo di dato corretto (VARCHAR, INTEGER, DOUBLE PRECISION).
  3. Importazione dei dati: Sfruttando gli strumenti di pgAdmin (Import/Export), il file CSV pulito è stato 
     caricato all'interno della tabella creata, completando con successo l'inserimento dei record storici.
*/

-- Obiettivo: Creare la tabella di destinazione 'gendip_data' strutturata con i campi coerenti rispetto al codebook del progetto.
-- Risultato atteso: Creazione corretta della tabella vuota pronta a ricevere i record del file CSV.

CREATE TABLE gendip_data (
    year INTEGER,
    cname_send VARCHAR(100),
    ccode_send INTEGER,
    ccodealp_send VARCHAR(10),
    ccodeCOW_send INTEGER,
    region_send INTEGER,
    GME_send INTEGER,
    name VARCHAR(150),
    gender INTEGER,
    title INTEGER,
    Main_posting INTEGER,
    FFP_send INTEGER,
    V2lgfemleg_send DOUBLE PRECISION,
    cname_receive VARCHAR(100),
    ccode_receive INTEGER,
    ccodealp_receive VARCHAR(10),
    ccodecow_receive INTEGER,
    region_receive INTEGER,
    GME_receive INTEGER,
    FFP_receive INTEGER
);

----------------------------------------------------------------------------------------------------
-- FASE 1: CONTROLLO E STATISTICHE DESCRITTIVE GENERALI
----------------------------------------------------------------------------------------------------

-- Obiettivo: Verificare il corretto caricamento del dataset calcolando il numero totale di righe presenti nella tabella 'gendip_data'.
-- Risultato atteso: Dovremmo visualizzare un totale di 94509 righe, confermando che l'importazione del file CSV è avvenuta senza perdita di dati.

SELECT COUNT(*) AS totale_righe
FROM gendip_data;

-- Obiettivo: Estrarre un'anteprima visiva dei primi record storici presenti nella tabella.
-- Risultato atteso: Visualizzare i primi 5 record storici a partire dall'anno 1968 per verificare la coerenza delle colonne e dei formati.

SELECT *
FROM gendip_data
LIMIT 5;

-- Obiettivo: Analizzare la distribuzione complessiva dei diplomatici per genere all'interno del dataset, escludendo i codici mancanti (99) come indicato nel codebook ufficiale.
-- Risultato atteso: Ottenere una tabella riepilogativa suddivisa tra uomini (0) e donne (1) con i relativi conteggi assoluti, permettendo di verificare il volume complessivo delle nomine classificate per genere.

SELECT 
    gender,
    CASE 
        WHEN gender = 0 THEN 'Uomini'
        WHEN gender = 1 THEN 'Donne'
        ELSE 'Altro / Sconosciuto'
    END AS genere_label,
    COUNT(*) AS numero_nomine
FROM gendip_data
WHERE gender <> 99
GROUP BY gender
ORDER BY gender;

----------------------------------------------------------------------------------------------------
-- FASE 2: TREND TEMPORALE ED EVOLUZIONE STORICA (1968 - 2021)
----------------------------------------------------------------------------------------------------

-- Obiettivo: Analizzare l'andamento temporale anno per anno della rappresentanza diplomatica femminile, calcolando il totale delle nomine e la percentuale di donne sul totale (escludendo i codici mancanti 99).
-- Risultato atteso: Ottenere una serie storica ordinata per anno che mostri la crescita progressiva della percentuale di donne diplomatiche dal 1968 al 2021.

SELECT 
    year,
    COUNT(CASE WHEN gender <> 99 THEN 1 END) AS totale_nomine_valide,
    SUM(CASE WHEN gender = 1 THEN 1 ELSE 0 END) AS nomine_donne,
    ROUND(
        (SUM(CASE WHEN gender = 1 THEN 1 ELSE 0 END)::numeric / NULLIF(COUNT(CASE WHEN gender <> 99 THEN 1 END), 0)) * 100, 
        2
    ) AS percentuale_donne
FROM gendip_data
GROUP BY year
ORDER BY year;
