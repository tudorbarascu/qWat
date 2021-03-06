/*
	qWat - QGIS Water Module
	
	SQL file :: print table and function
*/


/* CREATE TABLE */
DROP TABLE IF EXISTS qwat.od_installation_building CASCADE;
CREATE TABLE qwat.od_installation_building (id serial PRIMARY KEY);
COMMENT ON TABLE qwat.od_installation_building IS 'This table is used to define the buildings of installation.';

/* columns */
ALTER TABLE qwat.od_installation_building ADD COLUMN name            varchar(60) default '';
ALTER TABLE qwat.od_installation_building ADD COLUMN identification  varchar(25) default '';
ALTER TABLE qwat.od_installation_building ADD COLUMN id_type         integer not null;
ALTER TABLE qwat.od_installation_building ADD COLUMN _displayname_en varchar(50) default '';
ALTER TABLE qwat.od_installation_building ADD COLUMN _displayname_fr varchar(50) default '';
ALTER TABLE qwat.od_installation_building ADD COLUMN schema_visible  boolean not null default true ;
ALTER TABLE qwat.od_installation_building ADD COLUMN year            smallint    check (year > 1800 AND year < 2100);
ALTER TABLE qwat.od_installation_building ADD COLUMN parcel          varchar(30) default '';
ALTER TABLE qwat.od_installation_building ADD COLUMN eca             varchar(30) default '';

/* geometry */
/* point                              ( table_name,               is_node, create_node, create_schematic, get_pipe, auto_district, auto_pressurezone)*/
SELECT qwat.fn_geom_tool_point('od_installation_building',true,    true,        false,             false,    true         , false);
/* polygon */
SELECT AddGeometryColumn('qwat', 'od_installation_building', 'geometry_polygon', 21781, 'MULTIPOLYGON', 2);
CREATE INDEX installation_building_geoidx ON qwat.od_installation_building USING GIST ( geometry_polygon ); 

/* Constraints */
ALTER TABLE qwat.od_installation_building ADD CONSTRAINT installation_id_type FOREIGN KEY (id_type) REFERENCES qwat.vl_installation_type(id) MATCH FULL; CREATE INDEX fki_installation_id_type ON qwat.od_installation_building(id_type)        ;

/* TRIGGERS */
CREATE OR REPLACE FUNCTION qwat.fn_installation_building_trigger_fcn() RETURNS trigger AS
$BODY$
BEGIN
	 NEW._displayname_en = vl_installation_type.short_en||' '||NEW.name FROM qwat.vl_installation_type WHERE NEW.id_type = vl_installation_type.id;
	 NEW._displayname_fr = vl_installation_type.short_fr||' '||NEW.name FROM qwat.vl_installation_type WHERE NEW.id_type = vl_installation_type.id;
	 RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE TRIGGER fn_installation_building_trigger 
        BEFORE INSERT OR UPDATE OF id_type, name ON qwat.od_installation_building 
        FOR EACH ROW
        EXECUTE PROCEDURE qwat.fn_installation_building_trigger_fcn();
