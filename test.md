## prova

ciao

![](/img/grafo01.png)


#!/bin/bash
set -x

for o in $(cat saf.csv);
do
   for i in $(cat civ.csv);
   do
	ogr2ogr -f SQLite -update -append -nln shortestpath -dsco SPATIALITE=YES -dialect sqlite tab_percorsi_saf.sqlite db_rete_civ_saf_01.sqlite -sql "SELECT nodefrom,nodeto,cost,geometry FROM 'roads_network_net' WHERE NodeFrom = $o AND NodeTo = $i limit 1";
   done
done


## Osservazioni

-nln assegna il nome alla tabella, senza creerebbe una tabella dal nome `select`
-dsco SPATIALITE=YES definisce il formato spatialite, senza creerebbe un db sqlite e non spatialite

## fasi

1. creare un database spatialite vuoto;
2. importare nel database:
    1. rete stradale  (topologicamente corretta);
    2. numeri civici;
    3. servizi (saf; ecc..);
    4. tabella residenti;
3. analisi:
    1. estrapolare i nodi alla rete stradale;
    2. creare la roads network


```
for i in $(cat saf.csv);
   do
	ogr2ogr -f SQLite -update -append -nln civici -nlt POINT -dialect sqlite tab_civici_saf.sqlite db_rete_civ_saf_01.sqlite -sql "SELECT nodefrom,nodeto,cost,geometry FROM 'roads_network_net' WHERE NodeFrom = $i AND Cost <=500";
   done;
```

inutile
ogr2ogr -f SQLite -update -append -nln civici2 -nlt POINT -dialect sqlite tab_civici_saf.sqlite tab_civici_saf.sqlite -sql "SELECT ROWID as id , t.geom AS geom FROM (SELECT DISTINCT geometry AS geom FROM civici) t"
