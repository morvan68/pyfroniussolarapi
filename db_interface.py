# we use mongo db because:
# 1) its already installed and running on my system!
# 2) json dict from each call to inverter every X minures to get status
#    fits nicely in mongo vs SQL
import json

from pymongo import MongoClient
def write( fname, data):
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
    return post_id