#!/bin/bash
set -x

mkdir -p ./dati
dati="https://download.geofabrik.de/europe/italy/isole-latest.osm.bz2"
curl -L "$dati" >./dati/dati.osm.bz2
bzip2 -d ./dati/dati.osm.bz2
spatialite_osm_net -o ./dati/dati.osm -d ./dati/dati.sqlite -T nord-est -m
