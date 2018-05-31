# Come creare la roads_network per analisi di routing (civici,saf)

## step 1: utilizzare il database `db_cesbamed.sqlite`, avviare spatialite_gui

![avvio](/img/import_dati/import021.png) 

## step 2: creare un unico vettore puntuale (nodes_all) unendo _civici_cesbamed_ e _servizi_cesbamend_01_:

creo tabella `nodes_all`:

```
CREATE TABLE "nodes_all"
(
"pk_uid" integer PRIMARY KEY autoincrement NOT NULL,"id_civ_saf" text
);

--aggiungo colonna geometry
SELECT AddGeometryColumn ('nodes_all','geom',3045,'POINT','XY');
```
![pre](/img/prepara_rete/pre_rete001.png)
```
--inserisco i civici
INSERT INTO "nodes_all" ("pk_uid","id_civ_saf","geom")
SELECT NULL ,"codice_asc","geom"
FROM "civici_cesbamed";

--inserisco i saf
INSERT INTO "nodes_all" ("pk_uid","id_civ_saf","geom")
SELECT NULL ,"id","geom"
FROM "servizi_cesbamed_01";
```
![pre](/img/prepara_rete/pre_rete002.png)

![pre](/img/prepara_rete/pre_rete003.png)

**NB: civici e saf devono avere geometry-type POINT**

## STEP 3: creazione vertici/nodi, nella rete stradale, in corrispondenza dei civici e dei saf

Questo script va lanciato in un database in cui sono presenti due tabelle:
1. geoTabella `strade_cesbamed` contiene gli assi stradali topologicamente corretti;
2. geoTabella `nodes_all` contiene i punti dei civici e dei saf;
Risultato dello script è una geoTabella 'lines_split' con aggiunta di vertici in corrispondenza dei civici e saf geoTabella pronta per le fasi successive (è topologicamente corretta)

eseguire lo `script_split.sql`

![pre](/img/prepara_rete/pre_rete005.png)

`script_split.sql`:
```
SELECT 'Creazione indice spaziale su ', 'nodes_all','geom',
coalesce(checkspatialindex('nodes_all','geom'),CreateSpatialIndex('nodes_all','geom'));

SELECT 'Creazione indice spaziale su ', 'strade','geom',
coalesce(checkspatialindex('strade_cesbamed','geom'),CreateSpatialIndex('strade_cesbamed','geom'));

SELECT dropgeotable('nearest_strade_to_nodes_all');

CREATE TABLE nearest_strade_to_nodes_all as
            SELECT c.pk_uid, c.id_civ_saf, d.distance as dist, d.fid as strade_pk
            FROM nodes_all as c 
        JOIN 
            (SELECT a.fid as fid, a.distance as distance, zz.pk_uid as pk_uid
            FROM knn as a JOIN nodes_all as zz
            WHERE f_table_name = 'strade_cesbamed' 
            AND f_geometry_column = 'geom' 
            AND ref_geometry = zz.geom 
            AND max_items = 1) as d
        ON (d.pk_uid =c.pk_uid ) 
            ORDER BY c.pk_uid;

SELECT addgeometrycolumn('nearest_strade_to_nodes_all','geom',
        (SELECT cast(srid as integer)
        FROM geometry_columns 
        WHERE lower(f_table_name) = lower('strade_cesbamed') 
        AND lower(f_geometry_column) = lower('geom')),'point', 'xy');

UPDATE nearest_strade_to_nodes_all SET geom = 
    (SELECT ST_ClosestPoint(a.geom, b.geom)
    FROM strade_cesbamed as a, nodes_all as b 
    WHERE a.pk_uid=nearest_strade_to_nodes_all.strade_pk 
    AND b.pk_uid=nearest_strade_to_nodes_all.pk_uid);

SELECT 'Creazione indice spaziale su ', 'nearest_strade_to_nodes_all','geom',
coalesce(checkspatialindex('nearest_strade_to_nodes_all','geom'),
CreateSpatialIndex('nearest_strade_to_nodes_all','geom'));

SELECT DropGeoTable('strade_snapped_to_projections_of_nodes_all');
SELECT CloneTable('main', 'strade_cesbamed', 'strade_snapped_to_projections_of_nodes_all', 1,'::cast2multi::geom');

UPDATE strade_snapped_to_projections_of_nodes_all SET geom=
    CastToMulti(
    RemoveRepeatedPoints(
    ST_Snap( 
            strade_snapped_to_projections_of_nodes_all.geom,
            (SELECT CastToMultiPoint(st_collect(b.geom)) 
            FROM nearest_strade_to_nodes_all as b
            WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid 
            GROUP BY b.strade_pk) , 0.01 
            ), 0.01 
            )
            ) 
WHERE EXISTS(
            SELECT 1 FROM nearest_strade_to_nodes_all as b
            WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid limit 1
            );

UPDATE strade_snapped_to_projections_of_nodes_all SET geom=
    CastToMulti(
                ST_Split(
                        strade_snapped_to_projections_of_nodes_all.geom,
                        (SELECT CastToMultiPoint(st_collect(b.geom)) 
                        FROM nearest_strade_to_nodes_all as b
                        WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid 
                        GROUP BY b.strade_pk)
                        )
                )
WHERE EXISTS(
            SELECT 1 FROM nearest_strade_to_nodes_all as b
            WHERE b.strade_pk = strade_snapped_to_projections_of_nodes_all.pk_uid limit 1
            );

SELECT DropGeoTable('lines_split');
SELECT ElementaryGeometries( 'strade_snapped_to_projections_of_nodes_all' ,
                             'geom' , 'lines_split' ,'out_pk' , 'out_multi_id', 1 ) as num, 'lines splitted' as label;
SELECT 'Creazione indice spaziale su ', 'strade','geom',
coalesce(checkspatialindex('lines_split','geom'),CreateSpatialIndex('lines_split','geom'));

SELECT UpdateLayerStatistics('lines_split');
SELECT DropGeoTable('strade_snapped_to_projections_of_nodes_all');
SELECT DropGeoTable('nearest_strade_to_nodes_all');
```
dopo esecuzione script (circa 20 secondi) comparirà:

![pre](/img/prepara_rete/pre_rete007.png)

![pre](/img/prepara_rete/pre_rete008.png)

NB: se ci fossero degli errori nello script comparirebbe un messaggio ed occorre correggere.

## STEP 4: aggiungere nodi (`nodes`) alla rete stradale e creare la `roads_network`

copiare ed incollare il seguente script in spatialite_gui:
```
CREATE VIEW "tmp_roads" AS
SELECT geom,STARTPOINT(geom) AS startp, ENDPOINT(geom) AS endp
FROM "lines_split";

CREATE TABLE nodes
(pk_uid integer PRIMARY KEY autoincrement NOT NULL, id_nodes_all text);
SELECT AddGeometryColumn ('nodes','geom',3045,'POINT','XY');

INSERT INTO nodes (pk_uid,geom)
SELECT NULL, t.a AS geom 
FROM
(
SELECT DISTINCT "tmp_roads"."startp" AS a FROM "tmp_roads"
UNION
SELECT DISTINCT "tmp_roads"."endp" AS a FROM "tmp_roads"
) t;

CREATE TABLE "roads_network"
(pk_uid integer PRIMARY KEY autoincrement NOT NULL,"start_id" INTEGER, "end_id" INTEGER);

SELECT AddGeometryColumn ('roads_network','geom',3045,'LINESTRING','XY');

INSERT INTO "roads_network" (pk_uid,"start_id","end_id",geom)
SELECT NULL,s.pk_uid ,e.pk_uid,r.geom
FROM "tmp_roads" r
JOIN "nodes" AS s ON (r.startp = s.geom)
JOIN "nodes" AS e ON (r.endp = e.geom);

DROP VIEW "tmp_roads";
```
![pre](/img/prepara_rete/pre_rete009.png)

![pre](/img/prepara_rete/pre_rete010.png)

nodes:
![pre](/img/prepara_rete/pre_rete011.png)

roads_network:
![pre](/img/prepara_rete/pre_rete012.png)
