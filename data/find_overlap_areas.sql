-- Methodology from https://postgis.net/2014/03/14/tip_intersection_faster/
SELECT *,
intersection_area / feature1_area as feature1_proportion,
intersection_area / feature2_area as feature2_proportion
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
FROM (select *
	  from feature 
	  --where feature_uri = 'http://linked.data.gov.au/dataset/geofabric/contractedcatchment/12108152'
	  where dataset_id = (select dataset_id 
						  from dataset 
						  where dataset_uri = 'http://linked.data.gov.au/dataset/geofabric') --'http://linked.data.gov.au/dataset/asgs2016')
	  limit 10
	 ) f1
INNER JOIN (select *
			from feature 
			where feature_uri like 'http://linked.data.gov.au/dataset/asgs2016/meshblock/%'
			and dataset_id = (select dataset_id 
								from dataset 
								where dataset_uri = 'http://linked.data.gov.au/dataset/asgs2016') --'http://linked.data.gov.au/dataset/geofabric')
		   ) f2 	
	ON (ST_Intersects(f1.feature_geometry, f2.feature_geometry) 
	AND NOT ST_Touches(f1.feature_geometry, f2.feature_geometry))
) areas
order by feature1, feature2