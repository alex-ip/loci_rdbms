'''
Created on 13 Nov 2019

@author: Alex Ip
'''
import psycopg2
import requests
import logging
import json
import re
from time import sleep

import loci_rdbms.config as config

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG) # Initial logging level for this module
logger.debug('__name__ = {}'.format(__name__))

class LociRDBMS(object):
    def __init__(self):
        '''
        '''
        logger.debug('Connecting to database {} on host {}'.format(config.DB_CONFIG['POSTGRES_DBNAME'], config.DB_CONFIG['POSTGRES_SERVER']))    
        self.db_connection = psycopg2.connect(host=config.DB_CONFIG['POSTGRES_SERVER'], 
                                              port=config.DB_CONFIG['POSTGRES_PORT'], 
                                              dbname=config.DB_CONFIG['POSTGRES_DBNAME'], 
                                              user=config.DB_CONFIG['POSTGRES_USER'], 
                                              password=config.DB_CONFIG['POSTGRES_PASSWORD'])
            
        if config.DB_CONFIG['AUTOCOMMIT']:
            self.db_connection.autocommit = True
            self.db_connection.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        else:
            self.db_connection.autocommit = False
            self.db_connection.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_READ_COMMITTED)
        
        logger.info('Connected to database {} on host {}'.format(config.DB_CONFIG['POSTGRES_DBNAME'], config.DB_CONFIG['POSTGRES_SERVER']))    
            
        cursor = self.db_connection.cursor()
            
        for dataset_uri in config.DATASETS:
            sql_query = '''insert into dataset (
    dataset_uri 
    )
select '{dataset_uri}'
where not exists (select dataset_uri from dataset where dataset_uri = '{dataset_uri}')
    
'''.format(dataset_uri=dataset_uri) 
                 
            try:
                cursor.execute(sql_query)
                if cursor.rowcount:
                    logger.debug('Inserted new dataset {}'.format(dataset_uri))
            except Exception as e:
                logger.error('Error inserting dataset {}'.format(dataset_uri))
                logger.error(sql_query)
                logger.error(e)                    
    
            
            
    def load_feature_geometry(self, sparql_endpoint=None, offset=0, page_size=None):
        '''
        '''
        def get_feature_geometry(feature_uri):
            '''
            Helper function to retrieve GML geometry from a Linked Data API
            '''
            headers = {'Accept': 'application/json',
                       'Content-Type': 'application/sparql-query',
                       'Accept-Encoding': 'gzip, deflate' # + ', UTF-8'
                       }
            
            if feature_uri.startswith('http://linked.data.gov.au/dataset/asgs2016/'):
                params = {'_view': 'geosparql',
                          '_format': 'application/ld+json'
                          }
                
            elif feature_uri.startswith('http://linked.data.gov.au/dataset/geofabric/'):
                params = {'_view': 'hyfeatures',
                          '_format': 'application/ld+json'
                          }
            else:
                logger.debug('Unable to query GML for {}'.format(feature_uri))
                return
            
            gml = None
            logger.debug('Querying Linked Data API for feature {}'.format(feature_uri))
            
            retries = 0
            while True:
                try:
                    response = requests.get(feature_uri, headers=headers, params=params, stream=False)
                
                    assert response.status_code == 200, 'Response status code {} != 200'.format(response.status_code)
                    break
                except Exception as e:
                    logger.debug('GML query failed: {}'.format(e))
                    #logger.debug('feature_uri={}, headers={}, params={}'.format(feature_uri, headers, params))
                    retries += 1
                    if retries <= config.MAX_RETRIES:
                        sleep(config.RETRY_SLEEPTIME)
                        continue
                    else:
                        return
            
            #logger.debug(response.text)
            for detail in json.loads(response.text):
                try:
                    if detail["@type"][0] == "http://www.opengis.net/ont/geosparql#Geometry":
                        gml = detail["http://www.opengis.net/ont/geosparql#asGML"][0]["@value"]
                except KeyError:
                    pass
            #logger.debug(gml)
            return gml
        
        cursor = self.db_connection.cursor()
            
        sparql_endpoint = sparql_endpoint or config.SPARQL_ENDPOINT
        page_size = page_size or config.PAGE_SIZE
        
        headers = {'Accept': 'application/json',
                   'Content-Type': 'application/sparql-query',
                   'Accept-Encoding': 'gzip, deflate' # + ', UTF-8'
                   }
        params = None
        
        triple_count = offset
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
PREFIX gnaf: <http://linked.data.gov.au/def/gnaf#>

select distinct ?feature ?gml ?wkt
where {
    ?feature geo:hasGeometry ?geometry .
    OPTIONAL {
        ?geometry geo:asGML ?gml .
    }
    OPTIONAL {
        ?geometry geo:asWKT ?wkt .
    }
'''
            
#            sparql_query = sparql_query + '''    FILTER(''' + '\n        || '.join(["STRSTARTS(STR(?feature), '" + dataset + "')" for dataset in config.DATASETS]) + ''')
#'''

            sparql_query = sparql_query + '''}}
#ORDER BY ?feature
LIMIT {page_size} OFFSET {offset}
'''.format(page_size=page_size, offset=offset)

            #logger.debug(sparql_query)

            retries = 0
            while True:
                try:
                    logger.debug('Querying SPARQL endpoint {} for rows {}-{}'.format(sparql_endpoint, offset+1, offset+page_size))
                    response = requests.post(sparql_endpoint, headers=headers, params=params, data=sparql_query, stream=False)
                    
                    assert response.status_code == 200, 'Response status code {} != 200'.format(response.status_code)
                    logger.debug('Request succeeded. Processing response.')
                    break
                except Exception as e:
                    logger.debug('Error posting SPARQL query: {}'.format(e))
                    if retries <= config.MAX_RETRIES:
                        sleep(config.RETRY_SLEEPTIME)
                        continue
                    else:
                        raise
                
            query_row_count = 0
            for row_dict in [{'feature': binding['feature']['value'],
                              'gml': binding['gml']['value'] if binding.get('gml') else None,
                              # Need to convert URI for SRID into conventional EWKT SRID
                              'wkt': (re.sub('<http://www.opengis.net/def/crs/EPSG/(\d+)/(\d+)>\s*', 'SRID=\g<2>; ', binding['wkt']['value']) 
                                      if binding.get('wkt') 
                                      else None
                                      )
                              }
                              for binding in json.loads(response.text)['results']['bindings']]:
                                  
                # Check for feature existence to avoid having to query LD API if already in DB
                sql_query = '''select feature_id 
from feature where feature_uri = '{feature_uri}'
'''.format(feature_uri=row_dict['feature'])
                 
                triple_count += 1
                query_row_count += 1

                cursor.execute(sql_query)
                if cursor.rowcount:
                    logger.debug('Feature {} already exists in database'.format(row_dict['feature']))
                    continue
                elif row_dict['gml'] and  row_dict['wkt'] is None:
                    row_dict['gml'] = get_feature_geometry(row_dict['feature'])
                    
                if row_dict['gml'] is None and  row_dict['wkt'] is None:
                    logger.debug('Unable to obtain geometry for feature {}'.format(row_dict['feature']))
                    continue
                
                #logger.debug('{} {}'.format(triple_count, row_dict))

                # Insert new rdf_type record if required
                rdf_type_uri=re.sub('/\w+$', '', row_dict['feature'])
                sql_query = '''insert into rdf_type (rdf_type_uri)
select '{rdf_type_uri}'
where not exists (select rdf_type_id from rdf_type where rdf_type_uri = '{rdf_type_uri}')
'''.format(rdf_type_uri=rdf_type_uri)
                try:
                    cursor.execute(sql_query)
                    if cursor.rowcount:
                        logger.debug('Inserted new rdf_type {}'.format(rdf_type_uri))
                except Exception as e:
                    logger.error('Error inserting new rdf_type {}'.format(row_dict))
                    logger.error(sql_query)
                    logger.error(e)                    


                # Insert new feature record if required
                sql_query = '''insert into feature (
    feature_uri, 
    feature_geometry,
    dataset_id,
    rdf_type_id
    )
select '{feature_uri}',
'''
               
                if row_dict['gml']:
                    sql_query = sql_query + '''    ST_Transform(ST_GeomFromGML('{gml}'), 3577),
'''
                elif row_dict['wkt']:
                    sql_query = sql_query + '''    ST_Transform(ST_GeomFromEWKT('{wkt}'), 3577),
'''

                sql_query = sql_query + '''    (select dataset_id from dataset where '{feature_uri}' like dataset.dataset_uri || '/%'),
    (select rdf_type_id from rdf_type where '{feature_uri}' like rdf_type.rdf_type_uri || '/%')
where not exists (select feature_uri from feature where feature_uri = '{feature_uri}')
'''

                sql_query = sql_query.format(feature_uri=row_dict['feature'],
                                                   gml=row_dict['gml'],
                                                   wkt=row_dict['wkt']
                                                   )
                 
                try:
                    cursor.execute(sql_query)
                    if cursor.rowcount:
                        logger.debug('Inserted new feature {}'.format(row_dict['feature']))
                except Exception as e:
                    logger.error('Error processing row {}'.format(row_dict))
                    logger.error(sql_query)
                    logger.error(e)                    
                                           
                if triple_count % 10000 == 0:
                    logger.debug('Processed {} results'.format(triple_count))
                    
                # End of row loop
                    
            # Check whether all rows have been processed
            if query_row_count < page_size:
                break
                
            offset += page_size
            # End of page loop
            
        logger.debug('Processed a total of {} results'.format(triple_count))
            
            


        