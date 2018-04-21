# SpatiaLite routing
[estratto dal CookBook italiano di Alessandro Furieri pp.129](http://www.gaia-gis.it/spatialite-3.0.0-BETA/SpatiaLite-Cookbook_ITA.pdf)

SpatiaLite gestisce un modulo di “routing” denominato VirtualNetwork (rete virtuale). Lavorando su una
rete arbitraria questo modulo consente di identificare le connessioni di percorso minimo (shortest path) con
una semplice interrogazione SQL.
Il modulo VirtualNetwork si appoggia su algoritmi sofisticati ed altamente ottimizzati, così è veramente
veloce ed efficiente anche nel caso di reti di grande dimensione.

# Nozioni basilari sulle reti
Non potete presumere che qualsiasi generica mappa di strade corrisponda ad una rete. Una vera rete deve
soddisfare parecchi requisiti specifici, ad es. deve essere un grafo.
La teoria dei Grafi è un'ampia e complessa area della matematica; se siete interessati a ciò, qui potete trovare
ulteriori dettagli:
* [Teoria Dei Grafi (Graph Theory)](https://en.wikipedia.org/wiki/Graph_theory)
* [Problema del Percorso Minimo (Shortest Path Problem)](https://en.wikipedia.org/wiki/Shortest_path_problem)
* [Algoritmo di Dijkstra (Dijkstra's Algorithm)](https://en.wikipedia.org/wiki/Dijkstra's_algorithm)
* [Algoritmo A* (A* Algorithm)](https://en.wikipedia.org/wiki/A*_search_algorithm)

<img src='https://upload.wikimedia.org/wikipedia/commons/5/5b/6n-graf.svg'>

Spiegato in poche parole:
* una rete è un insieme di **archi**
* ogni arco connette due **nodi**
* ogni arco ha una **direzione** univoca: ad es. l'arco dal nodo A al nodo B non è necessariamente lo stesso
dell'arco che va dal nodo B al nodo A;
* ogni arco ha un “**costo**” conosciuto (ad es. lunghezza, tempo di percorrenza, capacità, ....)
* archi e nodi devono essere **univocamente identificati** da etichette
* la geometria del grafo (archi e nodi) deve soddisfare una **forte coerenza topologica**.
Partendo da una **rete** (o **grafo**) sia l'algoritmo di **Dijkstra** che l'algoritmo **A*** possono individuare il **percorso
minimo** (connessione con il minimo costo) che connette ogni coppia arbitraria di punti.

## Fonti dati

Vi sono parecchie fonti che distribuiscono dati di tipo rete. Una delle più note e largamente usate è **`OSM`**
[Open Street Map], un archivio di dimensione planetaria _completamente libero._ Vi sono parecchi siti dove
scaricare OSM; tanto per citarne qualcuno:
* [http://www.openstreetmap.org/](https://www.openstreetmap.org)
* [http://download.geofabrik.de/osm/](http://download.geofabrik.de/)
* [http://downloads.cloudmade.com/](http://downloads.cloudmade.com/)
* [Sub-region Italia](http://download.geofabrik.de/europe/italy.html)

<img src='https://github.com/pigreco/SL-routing/blob/master/img/sub-region-italy.jpg' width=700>

----
<img src='https://github.com/pigreco/SL-routing/blob/master/img/licenza.jpg'>

