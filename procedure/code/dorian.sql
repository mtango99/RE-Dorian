dorian.sql

--dorian count
SELECT AddGeometryColumn ('maddie','dorian','geom',4269,'POINT',2, false);
UPDATE dorian set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),4269)

CREATE TABLE dorianct AS
SELECT counties.geoid, counties.geometry, dorian.geom, dorian.status_id
FROM counties LEFT JOIN dorian
ON st_intersects(dorian.geom, counties.geometry)

CREATE TABLE doriangroup AS
SELECT geoid, count(status_id) as doriancount
FROM dorianct GROUP BY dorianct.geoid; 

--november count
SELECT AddGeometryColumn ('maddie','november','geom',4269,'POINT',2, false);
UPDATE november set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),4269)

CREATE TABLE novemberct AS
SELECT counties.geoid, counties.geometry, november.geom, november.status_id
FROM counties LEFT JOIN november
ON st_intersects(november.geom, counties.geometry)

CREATE TABLE novembergroup AS
SELECT geoid, count(status_id) as novembercount
FROM novemberct GROUP BY novemberct.geoid; 


--add dorian & nov counts back to counties
CREATE TABLE counties2 AS
SELECT counties.*, novembergroup.novembercount
FROM counties LEFT JOIN novembergroup
ON novembergroup.geoid = counties.geoid;

CREATE TABLE counties3 AS
SELECT counties2.*, doriangroup.doriancount
FROM counties2 LEFT JOIN doriangroup
ON doriangroup.geoid = counties2.geoid;

ALTER TABLE counties3
ADD COLUMN ndti real;

UPDATE counties3
SET ndti = (doriancount-novembercount)*1.0/(doriancount+novembercount)*1.0 
where doriancount+novembercount!=0


UPDATE counties3
SET ndti = 0
where ndti = NULL

