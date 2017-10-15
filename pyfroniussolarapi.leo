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
<v t="martin.20171015093734.1" a="E"><vh>@clean ./db_interface.py</vh>
<v t="martin.20171015093752.1"><vh>docs</vh></v>
<v t="martin.20171015093755.1"><vh>imports</vh></v>
</v>
<v t="martin.20171015090721.1" a="E"><vh>@clean ./logger_wrapper.py</vh>
<v t="martin.20171015090946.1"><vh>docs</vh></v>
<v t="martin.20171015090825.1"><vh>imports</vh></v>
<v t="martin.20171015090909.1"><vh>functions</vh></v>
<v t="martin.20171015090921.1"><vh>main</vh></v>
</v>
<v t="martin.20171015085508.1" a="E"><vh>@clean ./solarapi.py</vh>
<v t="martin.20171015085508.2"><vh>Declarations</vh></v>
<v t="martin.20171015085508.3"><vh>class SolarAPI</vh>
<v t="martin.20171015085508.4"><vh>__init__</vh></v>
<v t="martin.20171015085508.5"><vh>request</vh></v>
<v t="martin.20171015085508.6"><vh>api_info</vh></v>
<v t="martin.20171015085508.7"><vh>inverter_realtime_data</vh></v>
<v t="martin.20171015085508.8"><vh>GetStringRealtimeData</vh></v>
<v t="martin.20171015085508.9"><vh>logger_info</vh></v>
<v t="martin.20171015085508.10"><vh>inverter_info</vh></v>
<v t="martin.20171015085508.11"><vh>active_device_info</vh></v>
<v t="martin.20171015085508.12"><vh>meter_realtime_data</vh></v>
<v t="martin.20171015085508.13"><vh>archive_data</vh></v>
<v t="martin.20171015085508.14"><vh>all_archive_data</vh></v>
</v>
<v t="martin.20171015085625.1"><vh>main</vh></v>
</v>
<v t="martin.20171015092109.1" a="E"><vh>@clean /home/martin/git/pyfroniussolarapi/__init__.py</vh>
<v t="martin.20171015092109.2"><vh>Declarations</vh></v>
</v>
</v>
<v t="martin.20171015092239.1" a="E"><vh>docs</vh>
<v t="martin.20171015092055.1" a="E"><vh>@auto-md /home/martin/git/pyfroniussolarapi/README.md</vh></v>
</v>
</vnodes>
<tnodes>
<t tx="martin.20171015085508.1">#!/usr/bin/env python

@others
@language python
@tabwidth -4
</t>
<t tx="martin.20171015085508.10">def inverter_info(self):
    raise NotImplementedError()

</t>
<t tx="martin.20171015085508.11">def active_device_info(self):
    raise NotImplementedError()

</t>
<t tx="martin.20171015085508.12">def meter_realtime_data(self):
    raise NotImplementedError()

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
    request_url = self.protocol + self.host + '/solar_api/GetAPIVersion.cgi'
    return requests.get(request_url).json()

</t>
<t tx="martin.20171015085508.7">def inverter_realtime_data(self, scope="System",
                            device_id=None, data_collection=''):

    request_url = "/solar_api/v1/GetInverterRealtimeData.cgi"
    data = {'Scope': scope}
    if device_id and data_collection:
        data['DeviceID'] = device_id
        data['DataCollection'] = data_collection
    body = self.request(request_url, data)
    return body and body["Data"] or False

</t>
<t tx="martin.20171015085508.8">def GetStringRealtimeData(self, scope="Device", device_id=0,
                            data_collection="NowStringControlData",
                            time_period="Day"):
    request_url = "/solar_api/v1/GetStringRealtimeData.cgi"
    body = self.request(request_url, {
        "Scope": scope,
        "DeviceId": device_id,
        "DataCollection": data_collection,
        "TimePeriod": time_period
    })
    return body and body["Data"] or False

</t>
<t tx="martin.20171015085508.9">def logger_info(self):
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
    print( api.inverter_realtime_data("System") )
    #print( api.all_archive_data() )
</t>
<t tx="martin.20171015090721.1">@all</t>
<t tx="martin.20171015090825.1">import os
import sys
import json

import pyfroniussolar as pfs
</t>
<t tx="martin.20171015090909.1"></t>
<t tx="martin.20171015090921.1">if __name__ == '__main__':
    ip = sys.argv[1]
    data_store = ''
    
    #check inverter is powered
    
    if True:
        ap = pfs.SolarAPI( ip)
    
        #get relevant data
    
    #store results to file
    
    </t>
<t tx="martin.20171015090946.1"># wrapper for fronius, to collect data, and write to archive
# call it using cronjob, with your preferred time interval
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
<t tx="martin.20171015093752.1"># we use mongo db because
# 1) its already installed and running!
# 2) json docs from each call to get status fit nicely in mongo vs sQL
</t>
<t tx="martin.20171015093755.1"></t>
</tnodes>
</leo_file>
