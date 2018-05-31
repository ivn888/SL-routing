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