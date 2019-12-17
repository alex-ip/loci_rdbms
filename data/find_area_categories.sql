select feature1,
mb_category_name,
sum(feature1_proportion)*100.0 as percentage
from (
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
		END) as intersection_area,
	f2.feature_id as feature2_id
--	,ST_Force2D(ST_Transform(f2.feature_geometry, 4326)) as feature2_geometry
FROM (select *
	  from feature 
	  --where feature_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05/address/GAACT714962373' -- AI
	  --where feature_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05/address/GANSW716989142' -- AT
	  --where feature_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05/address/GAACT717685531' -- WF
	  --where feature_uri = 'http://linked.data.gov.au/dataset/geofabric/contractedcatchment/12105138'
	  --where feature_uri = 'http://linked.data.gov.au/dataset/asgs2016/meshblock/80005950000'
	  --where feature_uri = 'http://linked.data.gov.au/dataset/asgs2016/statisticalarealevel1/80108109102'
	  --where feature_uri = 'http://linked.data.gov.au/dataset/asgs2016/statisticalarealevel2/801081091'
	  --where feature_uri = 'http://linked.data.gov.au/dataset/asgs2016/statisticalarealevel3/80108'
	  --where feature_uri = 'http://linked.data.gov.au/dataset/asgs2016/statisticalarealevel4/801' -- ACT
	  --where feature_uri = 'http://linked.data.gov.au/dataset/electorates-2019/federal/bean'
	  where feature_uri = 'http://linked.data.gov.au/dataset/electorates-2019-08/state/ACT15'
	  --and rdf_type_id = (select rdf_type_id from rdf_type where rdf_type_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05/address')
	 ) f1
--INNER JOIN feature f2
INNER JOIN (select * from feature 
			--where  dataset_id = (select dataset_id from dataset where dataset_uri = 'http://linked.data.gov.au/dataset/asgs2016') -- Only show ASGS results
			where  rdf_type_id = (select rdf_type_id from rdf_type where rdf_type_uri = 'http://linked.data.gov.au/dataset/asgs2016/meshblock') -- Meshblocks only
			--where  rdf_type_id = (select rdf_type_id from rdf_type where rdf_type_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05/address') -- Addresses only
			--where  dataset_id != (select dataset_id from dataset where dataset_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05') -- Exclude GNAF results
			) f2 	
	ON (ST_Intersects(f1.feature_geometry, f2.feature_geometry) 
	AND NOT ST_Touches(f1.feature_geometry, f2.feature_geometry)
	AND f1.feature_id <> f2.feature_id
	)
) areas
) proportions
inner join mb_attributes on feature2_id = mb_attributes.feature_id
inner join mb_category using(mb_category_id)
group by feature1, mb_category_name
order by 3 desc