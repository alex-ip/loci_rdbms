'''
Created on 13 Nov 2019

@author: Alex Ip
'''
import psycopg2
import requests
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG) # Initial logging level for this module
logger.debug('__name__ = {}'.format(__name__))

class LociRDBMS(object):
    DB_CONFIG = {
    "POSTGRES_SERVER": "localhost",
    "POSTGRES_PORT": 5432,
    "POSTGRES_DBNAME": "loci_test",
    "POSTGRES_USER": "loci",
    "POSTGRES_PASSWORD": "loci",
    "AUTOCOMMIT": True,
    }
    
    SPARQL_ENDPOINT = 'http://db.loci.cat/repositories/loci-cache'
    
    PAGE_SIZE = 100000
    
    def __init__(self):
        '''
        '''
        logger.debug('Connecting to database {} on host {}'.format(LociRDBMS.DB_CONFIG['POSTGRES_DBNAME'], LociRDBMS.DB_CONFIG['POSTGRES_SERVER']))    
        self.db_connection = psycopg2.connect(host=LociRDBMS.DB_CONFIG['POSTGRES_SERVER'], 
                                              port=LociRDBMS.DB_CONFIG['POSTGRES_PORT'], 
                                              dbname=LociRDBMS.DB_CONFIG['POSTGRES_DBNAME'], 
                                              user=LociRDBMS.DB_CONFIG['POSTGRES_USER'], 
                                              password=LociRDBMS.DB_CONFIG['POSTGRES_PASSWORD'])
            
        if LociRDBMS.DB_CONFIG['AUTOCOMMIT']:
            self.db_connection.autocommit = True
            self.db_connection.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        else:
            self.db_connection.autocommit = False
            self.db_connection.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_READ_COMMITTED)
        
        logger.info('Connected to database {} on host {}'.format(LociRDBMS.DB_CONFIG['POSTGRES_DBNAME'], LociRDBMS.DB_CONFIG['POSTGRES_SERVER']))    
            
    
    def load(self, sparql_endpoint=None, offset=0, page_size=None):
        '''
        '''
        cursor = self.db_connection.cursor()
            
        sparql_endpoint = sparql_endpoint or LociRDBMS.SPARQL_ENDPOINT
        page_size = page_size or LociRDBMS.PAGE_SIZE
        
        headers = {'Content-Type': 'application/sparql-query',
                   'Accept-Encoding': 'UTF-8'
                   }
        params = None
        
        while True:
            sparql_query = '''PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX qudt: <http://qudt.org/schema/qudt#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xml: <http://www.w3.org/XML/1998/namespace>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dbp: <http://dbpedia.org/property/>
PREFIX geo: <http://www.opengis.net/ont/geosparql#>
PREFIX gx: <http://linked.data.gov.au/def/geox#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX dcat: <http://www.w3.org/ns/dcat#>
PREFIX void: <http://rdfs.org/ns/void#>
PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
PREFIX loci: <http://linked.data.gov.au/def/loci#>
PREFIX : <http://linked.data.gov.au/dataset/mb16cc/statement/>
PREFIX i: <http://purl.org/dc/terms/isPartOf>
PREFIX l: <http://linked.data.gov.au/dataset/mb16cc>
PREFIX from: <http://linked.data.gov.au/dataset/asgs2016/meshblock/>
PREFIX to: <http://linked.data.gov.au/dataset/geofabric/contractedcatchment/>
PREFIX s: <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject>
PREFIX p: <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate>
PREFIX o: <http://www.w3.org/1999/02/22-rdf-syntax-ns#object>
PREFIX m: <http://linked.data.gov.au/def/loci/hadGenerationMethod>
PREFIX w: <http://www.opengis.net/ont/geosparql#sfWithin>
PREFIX c: <http://www.opengis.net/ont/geosparql#sfContains>
PREFIX ov: <http://www.opengis.net/ont/geosparql#sfOverlaps>
PREFIX tso: <http://linked.data.gov.au/def/geox#transitiveSfOverlap>
PREFIX f: <http://www.opengis.net/ont/geosparql#Feature>
PREFIX am2: <http://linked.data.gov.au/def/geox#hasAreaM2>
PREFIX dv: <http://linked.data.gov.au/def/datatype/value>
PREFIX crs: <http://www.w3.org/ns/qb4st/crs>
PREFIX albers: <http://www.opengis.net/def/crs/EPSG/0/3577>

select distinct ?linkset ?from ?from_area ?to ?to_area ?intersection ?intersection_area
where {{
    ?s1 i: ?linkset .
    ?s1 s: ?from .
    ?s1 p: c: .
    ?s1 o: ?intersection .
    ?s2 i: ?l .
    ?s2 s: ?to .
    ?s2 p: c: .
    ?s2 o: ?intersection .
    filter (?from != ?to)
    ?s3 i: ?linkset .
    ?s3 s: ?from .
    ?s3 p: tso: .
    ?s3 o: ?to .
    ?from am2: ?from_am2 .
    ?from_am2 dv: ?from_area .
    ?from_am2 crs: albers: .
    ?to am2: ?to_am2 .
    ?to_am2 dv: ?to_area .
    ?to_am2 crs: albers: .
    ?intersection am2: ?intersection_am2 .
    ?intersection_am2 dv: ?intersection_area .
    ?intersection_am2 crs: albers: .
}}
LIMIT {page_size} OFFSET {offset}
'''.format(page_size=page_size, offset=offset)

            logger.debug('Querying SPARQL endpoint {} for rows {}-{}'.format(sparql_endpoint, offset+1, offset+page_size))
            response = requests.post(sparql_endpoint, headers=headers, params=params, data=sparql_query)
            
            assert response.status_code == 200, 'Response status code {} != 200'.format(response.status_code)
            
            header = None
            for line in response.text.split('\r\n'):
                line = line.strip()
                
                if header is None:
                    header = line.split(',')
                    continue
                
                if not line:
                    continue
                
                row_dict = dict(zip(header, line.split(',')))
                
                for key, value in row_dict.items():
                    try:
                        row_dict[key] = float(value)
                    except ValueError:
                        pass
                
                #logger.debug(str(row_dict))
                
                sql_query = '''insert into linkset (linkset_uri)
select '{linkset_uri}'
where not exists (select linkset_id from linkset where linkset_uri = '{linkset_uri}')
'''.format(linkset_uri=row_dict['linkset'])
                
                cursor.execute(sql_query)
                if cursor.rowcount:
                    logger.debug('Inserted new linkset {}'.format(row_dict['linkset']))
                           
                sql_query = '''insert into feature (feature_uri, feature_area_m2)
select '{feature_uri}', 
    {feature_area_m2}
where not exists (select feature_id from feature where feature_uri = '{feature_uri}')
'''.format(feature_uri=row_dict['from'], feature_area_m2=row_dict['from_area'])
                
                cursor.execute(sql_query)
                if cursor.rowcount:
                    logger.debug('Inserted new feature {}'.format(row_dict['from']))
                
                sql_query = '''insert into feature (feature_uri, feature_area_m2)
select '{feature_uri}', 
    {feature_area_m2}
where not exists (select feature_id from feature where feature_uri = '{feature_uri}')
'''.format(feature_uri=row_dict['to'], feature_area_m2=row_dict['to_area'])
                
                cursor.execute(sql_query)
                if cursor.rowcount:
                    logger.debug('Inserted new feature {}'.format(row_dict['to']))
                
                sql_query = '''insert into overlap (feature1_id, 
    feature2_id, 
    linkset_id, 
    overlap_area_m2
    )
select (select feature_id from feature where feature_uri = '{feature1_uri}'), 
    (select feature_id from feature where feature_uri = '{feature2_uri}'), 
    (select linkset_id from linkset where linkset_uri = '{linkset_uri}'), 
    {overlap_area_m2}
where not exists (select overlap.feature1_id, overlap.feature2_id from overlap 
                  inner join feature f1 on f1.feature_id = overlap.feature1_id
                  inner join feature f2 on f2.feature_id = overlap.feature2_id
                  where (f1.feature_uri = '{feature1_uri}' and f2.feature_uri = '{feature2_uri}')
                      or (f1.feature_uri = '{feature2_uri}' and f2.feature_uri = '{feature1_uri}')
                  )

'''.format(feature1_uri=row_dict['from'], 
           feature2_uri=row_dict['to'], 
           linkset_uri=row_dict['linkset'],
           overlap_area_m2=row_dict['intersection_area'],
           )
                
                cursor.execute(sql_query)
                if cursor.rowcount:
                    logger.debug('Inserted new overlap {}'.format(row_dict['intersection']))
                
                # End of row loop
                
            offset += page_size
            # End of page loop
            
            

        