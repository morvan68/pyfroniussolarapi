<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2" tnodes="0" max_tnode_index="0" clone_windows="0"/>
<globals body_outline_ratio="0.5" body_secondary_ratio="0.5">
	<global_window_position top="50" left="50" height="500" width="700"/>
	<global_log_window_position top="0" left="0" height="0" width="0"/>
</globals>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="martin.20171015092119.1" a="E"><vh>code</vh>
<v t="martin.20171015090721.1" a="E"><vh>@clean ./logger_wrapper.py</vh>
<v t="martin.20171015090946.1"><vh>docs</vh></v>
<v t="martin.20171015090825.1"><vh>imports</vh></v>
<v t="martin.20171015090921.1"><vh>main</vh></v>
</v>
<v t="martin.20171015093734.1" a="E"><vh>@clean ./db_interface.py</vh>
<v t="martin.20171015093752.1"><vh>docs</vh></v>
<v t="martin.20171015093755.1"><vh>imports</vh></v>
<v t="martin.20180101080101.1"><vh>write</vh></v>
</v>
<v t="martin.20171015085508.1" a="E"><vh>@clean ./solarapi.py</vh>
<v t="martin.20171015085508.2"><vh>Declarations</vh></v>
<v t="martin.20171015085508.3" a="E"><vh>class SolarAPI</vh>
<v t="martin.20171015085508.4"><vh>__init__</vh></v>
<v t="martin.20171015085508.5"><vh>request</vh></v>
<v t="martin.20171015085508.6"><vh>api_info</vh></v>
<v t="martin.20171015085508.10"><vh>inverter_info</vh></v>
<v t="martin.20171015085508.9"><vh>logger_info</vh></v>
<v t="martin.20171015085508.11"><vh>active_device_info</vh></v>
<v t="martin.20171015085508.12"><vh>meter_realtime_data</vh></v>
<v t="martin.20171015085508.7"><vh>inverter_cumulative_data</vh></v>
<v t="martin.20180102050736.1"><vh>inverter common data</vh></v>
<v t="martin.20171015085508.8"><vh>GetStringRealtimeData</vh></v>
<v t="martin.20180102052211.1"><vh>GetSensorRealtimeData</vh></v>
<v t="martin.20171015085508.13"><vh>archive_data</vh></v>
<v t="martin.20171015085508.14"><vh>all_archive_data</vh></v>
</v>
<v t="martin.20171015085625.1"><vh>main</vh></v>
</v>
<v t="martin.20171015092109.1" a="E"><vh>@clean ./__init__.py</vh>
<v t="martin.20171015092109.2"><vh>Declarations</vh></v>
</v>
</v>
<v t="martin.20171015092239.1"><vh>docs</vh>
<v t="martin.20171015092055.1" a="E"><vh>@auto-md ./README.md</vh></v>
</v>
</vnodes>
<tnodes>
<t tx="martin.20171015085508.1">#!/usr/bin/env python

@others
@language python
@tabwidth -4
</t>
<t tx="martin.20171015085508.10">def inverter_info(self):
    """get the inverter information"""
    request_url = "/solar_api/v1/GetInverterInfo.cgi"
    body = self.request(request_url,{})
    return body and body["Data"] or False

</t>
<t tx="martin.20171015085508.11">def active_device_info(self):
    """list of active devices on the system"""
    request_url = "/solar_api/v1/GetActiveDeviceInfo.cgi?DeviceClass=System"
    body = self.request(request_url,{})
    return body and body["Data"] or False

</t>
<t tx="martin.20171015085508.12">def meter_realtime_data(self, scope = 'System', device_id=None):
    """gets info on the meter"""
    request_url = "/solar_api/v1/GetMeterRealTimeData.cgi"
    data = {'Scope': scope}
    if device_id is not None:
        data['DeviceID'] = device_id
    body = self.request(request_url, data)
    return body and body["Data"] or False

</t>
<t tx="martin.20171015085508.13">def archive_data(self, scope="System", series_type="Detail",
        human_readable="False",
        start_date=False, end_date=False,
        channel=False,
        device_class="Inverter", device_id=0):
            
    request_url = "/solar_api/v1/GetArchiveData.cgi"
    end_date = end_date or datetime.datetime.now().strftime('%Y-%m-%d')
                # %H:%M:%S')
    if not start_date:
        start_date = (datetime.datetime.now() + 
            datetime.timedelta(days=-1)).strftime('%Y-%m-%d')# %H:%M:%S')
    if scope == "System":
        device_class = "" 
        device_id = ""
    # see API chapter 4.3
    body = self.request(request_url, {
       "Scope": scope,
       "SeriesType": series_type,
       "HumanReadable": human_readable,
       "StartDate": start_date,
       "EndDate":  end_date,
       "Channel": channel,
       "DeviceClass": device_class,
       "DeviceId": device_id
    })
    return body['Data']

</t>
<t tx="martin.20171015085508.14">def all_archive_data(self):
    archive_fetchem = [
        'TimeSpanInSec', # sec
        #'Digital_PowerManagementRelay_Out_1', # 1
        'EnergyReal_WAC_Sum_Produced', # Wh
        'InverterEvents', # struct
        'InverterErrors', # struct
        'Current_DC_String_1', # 1A
        'Current_DC_String_2', # 1A
        'Voltage_DC_String_1', # 1V
        'Voltage_DC_String_2', # 1V
        'Temperature_Powerstage', # deg C
        'Voltage_AC_Phase_1', # 1V
        'Voltage_AC_Phase_2', # 1V
        'Voltage_AC_Phase_3', # 1V
        'Current_AC_Phase_1', # 1A
        'Current_AC_Phase_2', # 1A
        'Current_AC_Phase_3', # 1A
        'PowerReal_PAC_Sum', # 1W
        'EnergyReal_WAC_Minus_Absolute', # 1Wh
        'EnergyReal_WAC_Plus_Absolute', # 1Wh
        'Meter_Location_Current', # 1
        'Digital_PowerManagementRelay_Out_1', # 1
    ]
    d = dict()
    for item in archive_fetchem:
        data = self.archive_data("System", "Detail", "True", False, False, item, "Inverter", 1)
        if data:
            data = data["inverter/1"]["Data"]
        vals = data[data.keys()[0]]["Values"]
        unit = data[data.keys()[0]]["Unit"]
        d[item] = [vals, unit]
    return d

</t>
<t tx="martin.20171015085508.2">import sys
import json
import requests
import datetime

</t>
<t tx="martin.20171015085508.3">class SolarAPI:
    "Fronius Solar API wrapper"
    @others
</t>
<t tx="martin.20171015085508.4">def __init__(self, host='localhost'):
    self.host = host
    self.protocol = 'http://'
    self.version = '1.0'
    self.inverter_id = 1 #TODO we should dynamically get this using inverter info
    if self.inverter_id == False:
        return False
</t>
<t tx="martin.20171015085508.5">def request(self, url, params={}):
    """generic request handler"""
    request_url = self.protocol + self.host + url
    try:
        data = requests.get(request_url, params)
        data = data.json()
    except ValueError as e:
        print( "Error in JSON response: %s" % e )
        print( data )
        return False
    errorcode = data["Head"]["Status"]["Code"]
    errortext = data["Head"]["Status"]["Reason"]
    if not "Body" in data or errorcode &gt; 0:
        print( "%i - %s" % (errorcode,errortext) )
        return False
    return data["Body"]

</t>
<t tx="martin.20171015085508.6">def api_info(self):
    """get the api version/info:
    {'APIVersion': 1, 'BaseURL': '/solar_api/v1/', 'CompatibilityRange': '1.5-4'}
    will return false if error or system offline"""
    request_url = self.protocol + self.host + '/solar_api/GetAPIVersion.cgi'
    try:
        body = requests.get(request_url).json()
    except ValueError as e:
        return False
    return body
</t>
<t tx="martin.20171015085508.7">def inverter_realtime_data(self, scope="System",
                            device_id=None, data_collection=''):
    """get real time data, defaults return real time cumulativedata"""
    request_url = "/solar_api/v1/GetInverterRealtimeData.cgi"
    data = {'Scope': scope}
    if (device_id is not None) and (data_collection != ''):
        data['DeviceID'] = device_id
        data['DataCollection'] = data_collection
    body = self.request(request_url, data)
    return body and body["Data"] or False

</t>
<t tx="martin.20171015085508.8">def GetStringRealtimeData(self, scope="Device", device_id=0,
                            data_collection="NowStringControlData",
                            time_period="Day"):
    """get data from each string of the panels"""
    request_url = "/solar_api/v1/GetStringRealtimeData.cgi"
    body = self.request( request_url, {
                        "Scope": scope,
                        "DeviceId": device_id,
                        "DataCollection": data_collection,
                        "TimePeriod": time_period
                        })
    return body and body["Data"] or False
</t>
<t tx="martin.20171015085508.9">def logger_info(self):
    """get the logger info"""
    request_url = "/solar_api/v1/GetLoggerInfo.cgi"
    body = self.request(request_url,{})
    return body and body["LoggerInfo"] or False

</t>
<t tx="martin.20171015085625.1">if __name__ == '__main__':
    if len(sys.argv) &lt; 2:
        print( "usage: python3 solarapi.py IP_ADDRESS" )
        exit(1)
    host = sys.argv[1]
    api = SolarAPI(host)
    print( api.logger_info() )
    print( api.api_info() )
    print( api.inverter_info() )
    print( 'cumulative data')
    print( api.inverter_realtime_data("System") )
    print( 'active device info')
    print( api.active_device_info() )
    print( 'inv common data')
    print( api.inverter_common_data() )
    print( 'inv 3P data')
    print( api.inverter_3Pinverter_data() )
#    print( api.archive_data() ) #not available on my system
#    print( api.meter_realtime_data() )
#    print( api.GetStringRealtimeData() )
</t>
<t tx="martin.20171015090721.1">@all
</t>
<t tx="martin.20171015090825.1">import datetime
import sys
import os

import solarapi as sol
import db_interface as db
</t>
<t tx="martin.20171015090921.1">if __name__ == '__main__':
    if len(sys.argv) &gt; 1:
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

</t>
<t tx="martin.20171015090946.1"># wrapper for fronius, to collect data, and write to archive
# call it using crontab, with your preferred time interval; i use:
# */10 6-18 * * * python3 /home/martin/git/fronius/logger_wrapper.py 192.168.1.60
</t>
<t tx="martin.20171015092109.1">@others
@language python
@tabwidth -4
</t>
<t tx="martin.20171015092109.2">from solarapi import *
</t>
<t tx="martin.20171015092119.1"></t>
<t tx="martin.20171015092239.1"></t>
<t tx="martin.20171015093734.1">@all
</t>
<t tx="martin.20171015093752.1"># we use mongo db because:
# 1) its already installed and running on my system!
# 2) json dict from each call to inverter every X minures to get status
#    fits nicely in mongo vs SQL
</t>
<t tx="martin.20171015093755.1">import json

from pymongo import MongoClient
</t>
<t tx="martin.20180101080101.1">def write( fname, data):
    """write results to file: fname ends with json will write a single 
    data file, else fname refers to mongodb location"""
    if fname.endswith('json'):
        write_to_file( fname, data)
    else: #assume mongodb
        write_to_db( fname, data)

def write_to_file( fname, data):
    """simple writer, just to json file, not to db"""
    with open( fname, 'wt') as f:
        json.dump( data, f, indent=4, sort_keys=True)

def write_to_db( fname, data):
    client = MongoClient()
    db = client.test_database
#    db = client.solar_database
    posts = db.posts
    post_id = posts.insert_one(data).inserted_id
    return post_id</t>
<t tx="martin.20180102050736.1">def inverter_common_data(self):
    """get real time data from inverter"""
    return self.inverter_realtime_data( scope='Device',
            device_id=self.inverter_id, data_collection='CommonInverterData')

def inverter_3Pinverter_data(self):
    """get 3 phase inverter data"""
    return self.inverter_realtime_data( scope='Device',
            device_id=self.inverter_id, data_collection='3PInverterData')

</t>
<t tx="martin.20180102052211.1">def GetSensorRealtimeData(self, scope="Device", device_id=0,
                            data_collection="NowSensorData"):
    """get data from sensors"""
    request_url = "/solar_api/v1/GetSensorRealtimeData.cgi"
    body = self.request( request_url, {
                        "Scope": scope,
                        "DeviceId": device_id,
                        "DataCollection": data_collection,
                        })
    return body and body["Data"] or False
</t>
</tnodes>
</leo_file>
