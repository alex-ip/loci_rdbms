select feature_uri, ST_Force2D(ST_Transform(feature_geometry, 4326)) as feature_geometry
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
	  --where feature_uri = 'http://linked.data.gov.au/dataset/electorates-2019/federal/canberra'
	  where feature_uri = 'http://linked.data.gov.au/dataset/electorates-2019-08/state/ACT15'
	  --and rdf_type_id = (select rdf_type_id from rdf_type where rdf_type_uri = 'http://linked.data.gov.au/dataset/gnaf-2016-05/address')