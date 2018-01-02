# wrapper for fronius, to collect data, and write to archive
# call it using crontab, with your preferred time interval; i use:
# */10 6-18 * * * python3 /home/martin/git/fronius/logger_wrapper.py 192.168.1.60
import datetime
import sys
import os

import solarapi as sol
import db_interface as db
if __name__ == '__main__':
    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else: #convenience for my system
        ip = '192.168.1.60'
    data_store = '/home/martin/solar_data'
    ap = sol.SolarAPI( ip)
    inverter_on = ap.api_info()
    if inverter_on is not False:
        data = {}
        #get relevant data
        #data['logger_info'] = ap.logger_info()
        data['inverter_info'] = ap.inverter_info()
        #data['device_info'] = ap.active_device_info()
        data['cumulative_data'] = ap.inverter_realtime_data()
        data['common_data'] = ap.inverter_common_data()
        data['3P_data'] = ap.inverter_3Pinverter_data()

        # store results to file
        fname = 'data_' + datetime.datetime.now().isoformat() + '.json'
        fname = os.path.join( data_store, fname)
        db.write( fname, data)

