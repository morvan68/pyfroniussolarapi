#!/usr/bin/env python

import sys
import json
import requests
import datetime
class SolarAPI:
    "Fronius Solar API wrapper"

    def __init__(self, host):
        self.host = host
        self.protocol = 'http://'

    def request(self, url, params={}):
        request_url = self.protocol + self.host + url
        try:
            data = requests.get(request_url, params)
            data = data.json()
        except ValueError, e:
            print "Error in JSON response:", e
            print data
            return False
        errorcode = data["Head"]["Status"]["Code"]
        errortext = data["Head"]["Status"]["Reason"]
        if not "Body" in data or errorcode > 0:
            print "%i - %s"%(errorcode,errortext)
            return False
        return data["Body"]

    def api_info(self):
        request_url = self.protocol + self.host + '/solar_api/GetAPIVersion.cgi'
        return requests.get(request_url).json()

    def inverter_realtime_data(self, scope="System", device_id=None, data_collection=''):
        request_url = "/solar_api/v1/GetInverterRealtimeData.cgi"
        data = {'Scope': scope}
        if device_id and data_collection:
            data['DeviceID'] = device_id
            data['DataCollection'] = data_collection
        body = self.request(request_url, data)
        return body and body["Data"] or False

    def GetStringRealtimeData(self, scope="Device", device_id=0,\
            data_collection="NowStringControlData", time_period="Day"):
        request_url = "/solar_api/v1/GetStringRealtimeData.cgi"
        body = self.request(request_url, {
            "Scope": scope,
            "DeviceId": device_id,
            "DataCollection": data_collection,
            "TimePeriod": time_period
        })
        return body and body["Data"] or False

    def logger_info(self):
        request_url = "/solar_api/v1/GetLoggerInfo.cgi"
        body = self.request(request_url,{})
        return body and body["LoggerInfo"] or False

    def inverter_info(self):
        raise NotImplementedError()

    def active_device_info(self):
        raise NotImplementedError()

    def meter_realtime_data(self):
        raise NotImplementedError()

    def archive_data(self, scope="System", series_type="Detail", human_readable="False", start_date=False, end_date=False, channel=False, device_class="Inverter", device_id=0):
        request_url = "/solar_api/v1/GetArchiveData.cgi"
        end_date = end_date or datetime.datetime.now().strftime('%Y-%m-%d')# %H:%M:%S')
        if not start_date:
            start_date = (datetime.datetime.now() + datetime.timedelta(days=-1)).strftime('%Y-%m-%d')# %H:%M:%S')
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
        print body['Data']
        return body['Data']

    def all_archive_data(self):
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
            print 'Fetchin', item
            data = self.archive_data("System", "Detail", "True", False, False, item, "Inverter", 1)
            if data:
                data = data["inverter/1"]["Data"]
            vals = data[data.keys()[0]]["Values"]
            unit = data[data.keys()[0]]["Unit"]
            d[item] = [vals, unit]
        return d

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print "usage: python solarapi.py IP_ADDRESS"
        exit(1)
    host = sys.argv[1]
    api = SolarAPI(host)
    print api.logger_info()
    print api.api_info()
    print api.inverter_realtime_data("System")
    print api.all_archive_data()
