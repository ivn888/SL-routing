# Importazione dei dati in un database Spatialite (>=4.4)

### Per eseguire l'analisi di routing i dati della rete stradale devono essere importati in un database SpatiaLite

### Creare nuovo database e importare una rete stradale (es: uno shapefile)

avviare spatialite_gui:

![grafo](/img/import_dati/import001.png)

creare database vuoto:

![grafo](/img/import_dati/import002.png)

ecco il database caricato in spatialite_gui:

![grafo](/img/import_dati/import003.png)

importare uno shapefile 1:

![grafo](/img/import_dati/import004.png)

importare uno shapefile 2: settare i dati

![grafo](/img/import_dati/import005.png)

importare uno shapefile 3: lettura dati corretta!!!

![grafo](/img/import_dati/import006.png)

importare uno shapefile 4: Fatto!!!

![grafo](/img/import_dati/import007.png)

### nel caso di civici con geometry type MultiPOINT

importare il vettore seguendo la procedura precedente e poi verificare con il 'check Geometries':

![grafo](/img/import_dati/import008.png)

tasto destro del mouse sul campo 'geom' e selezionare 'separating elementary geometries'

![grafo](/img/import_dati/import010.png)

comparirà la finestro sottostante, settare i dati e poi OK:

![grafo](/img/import_dati/import012.png)

cancellare la tabella non più utile:

![grafo](/img/import_dati/import013.png)

### importiamo il vettore dei SAF e rinominare:

![grafo](/img/import_dati/import014.png)

![grafo](/img/import_dati/import015.png)

### infine, importare la tabella alfanumerica in formato csv:

![grafo](/img/import_dati/import017.png)

settare i dati:

![grafo](/img/import_dati/import018.png)

fatto:

![grafo](/img/import_dati/import019.png)

### Verificare la tabella:

![grafo](/img/import_dati/import020.png)

### database con tutti i dati importati:

![grafo](/img/import_dati/import021.png)