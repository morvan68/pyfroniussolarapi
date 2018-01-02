# pyfroniussolarapi
**solarapi.py:**
Fronius Solar API v1 (JSON) wrapper for Python 3.x. Will speak to the Fronius
over an IP and get most useful data/settings from it, and return the data as
dicts.

**logger_wrapper.py:**
A tool that uses solarapi.py for logging all the useful Fronius system data
when run. Use crontab to run it repeatedly to log data continually (or import
into your own program!).
The data is stored in a mongodb, or optionally can be stored in a folder of
json files. (a simple code tweak to change the data file extension will change
operation)

**db_interface.py**
provides the file I/O for logger_wrapper.py. Currently mongodb support is a
work in progress, not tested yet.

**pyfroniussolarapi.leo**
leo editor project file for the whole repo. see leoeditor.com for use.

