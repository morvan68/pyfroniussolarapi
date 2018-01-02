#!/usr/bin/env python

import sys
import json
import requests
import datetime

class SolarAPI:
    "Fronius Solar API wrapper"

    def __init__(self, host='localhost'):
        self.host = host
        self.protocol = 'http://'
        self.version = '1.0'
        self.inverter_id = 1 #TODO we should dynamically get this using inverter info
    def request(self, url, params={}):
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
        if not "Body" in data or errorcode > 0:
            print( "%i - %s" % (errorcode,errortext) )
            return False
        return data["Body"]

    def api_info(self):
        """get the api version/info:
        {'APIVersion': 1, 'BaseURL': '/solar_api/v1/', 'CompatibilityRange': '1.5-4'}
        will return false if error or system offline"""
        request_url = self.protocol + self.host + '/solar_api/GetAPIVersion.cgi'
        try:
            body = requests.get(request_url).json()
        except ValueError as e:
            return False
        return body
    def inverter_info(self):
        request_url = "/solar_api/v1/GetInverterInfo.cgi"
        body = self.request(request_url,{})
        return body and body["Data"] or False

    def logger_info(self):
        """get the logger info"""
        request_url = "/solar_api/v1/GetLoggerInfo.cgi"
        body = self.request(request_url,{})
        return body and body["LoggerInfo"] or False

    def active_device_info(self):
        """list of active devices on the system"""
        request_url = "/solar_api/v1/GetActiveDeviceInfo.cgi?DeviceClass=System"
        body = self.request(request_url,{})
        return body and body["Data"] or False

    def meter_realtime_data(self):
        """gets info on the meter"""
        
        raise NotImplementedError()

    def inverter_realtime_data(self, scope="System",
                                device_id=None, data_collection=''):
        """get real time data, defaults return real time cumulativedata"""
        request_url = "/solar_api/v1/GetInverterRealtimeData.cgi"
        data = {'Scope': scope}
        if (device_id is not None) and (data_collection is not ''):
            data['DeviceID'] = device_id
            data['DataCollection'] = data_collection
        body = self.request(request_url, data)
        return body and body["Data"] or False

    def inverter_common_data(self):
        """get real time data from inverter"""
        return self.inverter_realtime_data( scope='Device',
                device_id=self.inverter_id, data_collection='CommonInverterData')

    def inverter_3Pinverter_data(self):
        """get 3 phase inverter data"""
        return self.inverter_realtime_data( scope='Device',
                device_id=self.inverter_id, data_collection='3PInverterData')

    def GetStringRealtimeData(self, scope="Device", device_id=0,
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
    def GetSensorRealtimeData(self, scope="Device", device_id=0,
                                data_collection="NowSensorData"):
        """get data from sensors"""
        request_url = "/solar_api/v1/GetSensorRealtimeData.cgi"
        body = self.request( request_url, {
                            "Scope": scope,
                            "DeviceId": device_id,
                            "DataCollection": data_collection,
                            })
        return body and body["Data"] or False
    def archive_data(self, scope="System", series_type="Detail",
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
            data = self.archive_data("System", "Detail", "True", False, False, item, "Inverter", 1)
            if data:
                data = data["inverter/1"]["Data"]
            vals = data[data.keys()[0]]["Values"]
            unit = data[data.keys()[0]]["Unit"]
            d[item] = [vals, unit]
        return d

if __name__ == '__main__':
    if len(sys.argv) < 2:
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
