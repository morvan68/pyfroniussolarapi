# we use mongo db because
# 1) its already installed and running on my system!
# 2) json docs from each call to get status fit nicely in mongo vs SQL
import json
import mongodb
def write( fname, data):
    if fname.endswith('json'):
        write_to_file( fname, data)
    else:
        ...

def write_to_file( fname, data):
    """simple writer, just to json file, not to db"""
    with open( fname, 'wt') as f:
        json.dump(data, f, indent=4, sort_keys=True)