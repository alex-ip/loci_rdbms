'''
Created on 13 Nov 2019

@author: Alex Ip
'''
import logging
import sys
from loci_rdbms import LociRDBMS

logger = logging.getLogger()

def main():
    lrdbms = LociRDBMS()
    
    #lrdbms.load_feature_relationships(offset=0, page_size=0)
    lrdbms.load_feature_geometry(offset=0, page_size=10000)

if __name__ == '__main__':
    # Setup logging handler if required
    if not logger.handlers:
        # Set handler for root root_logger to standard output
        console_handler = logging.StreamHandler(sys.stdout)
        #console_handler.setLevel(logging.INFO)
        console_handler.setLevel(logging.DEBUG)
        console_formatter = logging.Formatter('%(message)s')
        console_handler.setFormatter(console_formatter)
        logger.addHandler(console_handler)

    main()