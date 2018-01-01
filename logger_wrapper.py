# wrapper for fronius, to collect data, and write to archive
# call it using cronjob, with your preferred time interval
import os
import datetime
import sys
import json

import solarapi as sol
import db_interface as db
if __name__ == '__main__':
    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip = '192.168.1.60'
    data_store = '/home/martin/solar_data'
    
    ap = sol.SolarAPI( ip)
    #check inverter is powered
    inverter_on = True
    
    if inverter_on:
        #get relevant data
        #print( api.logger_info() )
        #print( api.api_info() )
        print( ap.inverter_realtime_data("System") )

        # #store results to file
        # fname = 'data_' + datetime.datetime.now().isoformat() + '.json'
        # fname = os.path.join( data_store, fname)
        # db.write( fname, data)

