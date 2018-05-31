-- unica feature linestring tra i punti from e to

SELECT *
FROM "nord-est_net"
WHERE NodeFrom = 1 AND NodeTo = 200;

-- punti che distano Cost dal nodo from

SELECT *
FROM "nord-est_net"
WHERE NodeFrom = 1 AND Cost <=500;
