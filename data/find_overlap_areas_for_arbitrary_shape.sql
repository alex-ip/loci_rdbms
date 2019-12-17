-- Methodology from https://postgis.net/2014/03/14/tip_intersection_faster/
SELECT *,
CASE 
    WHEN feature1_area = 0
   		THEN Null
   	ELSE 
    	intersection_area / feature1_area
	END as feature1_proportion, 
CASE 
    WHEN feature2_area = 0
   		THEN Null
   	ELSE 
    	intersection_area / feature2_area
	END as feature2_proportion
from (
SELECT 
	f1.feature_uri as feature1, 
	ST_Area(f1.feature_geometry) as feature1_area,
	f2.feature_uri as feature2, 
	ST_Area(f2.feature_geometry) as feature2_area,
	ST_Area(CASE 
    	WHEN ST_CoveredBy(f1.feature_geometry, f2.feature_geometry) 
   			THEN f1.feature_geometry
   		WHEN ST_CoveredBy(f2.feature_geometry, f1.feature_geometry) 
   			THEN f2.feature_geometry
   		ELSE 
    		ST_Multi(ST_Intersection(f1.feature_geometry, f2.feature_geometry))
		END) as intersection_area
	,ST_Force2D(ST_Transform(f1.feature_geometry, 4326)) as feature1_geometry
	,ST_Force2D(ST_Transform(f2.feature_geometry, 4326)) as feature2_geometry
FROM (select 
	  	'arbitrary_shape' as feature_uri,
	  	ST_Transform(ST_GeomFromEWKT('SRID=4326;MULTIPOLYGON(((148.50 -36.00,149.50 -36.00,149.50 -35.00,148.50 -35.00,148.50 -36.00)))'), 3577)
	  		as feature_geometry
	 ) f1
--INNER JOIN feature f2
INNER JOIN (select * from feature 
			--where  dataset_id = (select dataset_id from dataset where dataset_uri = 'http://linked.data.gov.au/dataset/asgs2016') -- Only show ASGS results
			--where  dataset_id = (select dataset_id from dataset where dataset_uri = 'http://linked.data.gov.au/dataset/geofabric') -- Only show GeoFabric results
			where  rdf_type_id = (select rdf_type_id from rdf_type where rdf_type_uri = 'http://linked.data.gov.au/dataset/asgs2016/meshblock') -- Meshblocks only
			--where  rdf_type_id = (select rdf_type_id from rdf_type where rdf_type_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05/address') -- Addresses only
			--where  dataset_id != (select dataset_id from dataset where dataset_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05') -- Exclude GNAF results
			) f2 	
	ON (ST_Intersects(f1.feature_geometry, f2.feature_geometry) 
	AND NOT ST_Touches(f1.feature_geometry, f2.feature_geometry)
	)
) areas
order by feature1, feature2