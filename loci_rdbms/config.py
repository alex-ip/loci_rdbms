'''
Created on 20 Nov 2019

@author: Alex Ip
'''
DB_CONFIG = {
"POSTGRES_SERVER": "localhost",
"POSTGRES_PORT": 5432,
"POSTGRES_DBNAME": "loci_test",
"POSTGRES_USER": "loci",
"POSTGRES_PASSWORD": "loci",
"AUTOCOMMIT": True,
}

#SPARQL_ENDPOINT = 'http://db.loci.cat/repositories/loci-cache' # CSIRO Large
#SPARQL_ENDPOINT = 'http://ec2-13-211-132-204.ap-southeast-2.compute.amazonaws.com:80/repositories/loci-cache' # GA Small
SPARQL_ENDPOINT = 'http://ec2-54-252-177-202.ap-southeast-2.compute.amazonaws.com/repositories/loci-cache' # GA Large

PAGE_SIZE = 100000

MAX_RETRIES = 0