/*
	qWat - QGIS Water Module
	
	SQL file :: pressure zones
*/

BEGIN;

/* CREATE TABLE */
DROP TABLE IF EXISTS distribution.pressurezone CASCADE;
CREATE TABLE distribution.pressurezone (id serial NOT NULL);
COMMENT ON TABLE distribution.pressurezone IS 'Pressure zones.';

/* columns */
ALTER TABLE distribution.pressurezone ADD COLUMN shortname     varchar(10);
ALTER TABLE distribution.pressurezone ADD COLUMN name          varchar(30);
ALTER TABLE distribution.pressurezone ADD COLUMN consummerzone varchar(30);
ALTER TABLE distribution.pressurezone ADD COLUMN colorcode     smallint;

/* geometry */
SELECT AddGeometryColumn('distribution', 'pressurezone', 'geometry', 21781, 'POLYGON', 2);
CREATE INDEX pressurezone_geoidx ON distribution.pressurezone USING GIST ( geometry ); 

/* constraints */
ALTER TABLE distribution.pressurezone ADD CONSTRAINT pressurezone_pkey PRIMARY KEY (id);
ALTER TABLE distribution.pressurezone ADD CONSTRAINT pressurezone_name UNIQUE (name);

        
/* get pressurezone id function */
CREATE OR REPLACE FUNCTION distribution.get_pressurezone_id(geometry) RETURNS integer AS '
	DECLARE
		geom ALIAS FOR $1;
		id_pressurezone integer;
	BEGIN
		SELECT pressurezone.id INTO id_pressurezone
			FROM  distribution.pressurezone
			WHERE ST_Intersects(geom,pressurezone.geometry) IS TRUE
			ORDER BY ST_Length(ST_Intersection(geom,pressurezone.geometry)) DESC
			LIMIT 1;
		RETURN id_pressurezone;
	END
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION distribution.get_pressurezone_id(geometry) IS 'Returns the id of the first overlapping pressurezone.';
        
COMMIT;
