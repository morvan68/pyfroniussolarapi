# wrapper for fronius, to collect data, and write to archive
# call it using cronjob, with your preferred time interval
import os
import sys
import json

import pyfroniussolar as pfs
if __name__ == '__main__':
    ip = sys.argv[1]
    data_store = ''
    
    #check inverter is powered
    
    if True:
        ap = pfs.SolarAPI( ip)
    
        #get relevant data
    
    #store results to file
    
    