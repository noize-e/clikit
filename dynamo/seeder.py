import json
import pprint
from datetime import datetime


json_name = "second-record-stations.json"
json_seed_name = "items-second.json"
table_name = "Stations"

jsonfile = open(json_name, "r")
items = list(json.load(jsonfile))

table = {table_name: []}
types = {
    "<class 'str'>": "S",
    "<class 'bool'>": "B",
    "<class 'int'>": "N",
    "<class 'list'>": "L",
    "<class 'dict'>": "M"
}


def iter_list(listem, key=None):
    items = []
    for item in listem:
        if type(item) is dict:
            item = iter_dicto(item)
        if type(item) is list:
            item = {key: iter_list(item)}
        else:
            vtype = types[str(type(item))]
            item = {
                vtype: item
            }
        items.append(item)
    return {"L": items}


def iter_dicto(dictem, first=False):
    items = {}
    for key, val in dictem.items():
        if type(val) is dict:
            val = iter_dicto(val)
        if type(val) is list:
            val = {key: iter_list(val, key)}
        else:
            vtype = types[str(type(val))]
            val = {
                key: {
                    vtype: (lambda x: str(x) if type(x) is int else x)(val)
                }
            }

        items.update(val)
    return items


for item in items:
    hour = datetime.strftime(datetime.now(), "%H")
    created_at = datetime.utcnow().isoformat()
    item.update({
        "hour": hour,
        "created_at": created_at
    })

    put_item = {
        "PutRequest": {
            "Item": iter_dicto(item)
        }
    }
    pprint.pprint(put_item)
    table[table_name].append(put_item)


itemsjson = open(json_seed_name, "w")
itemsjson.write(json.dumps(table))
itemsjson.close()


print("Run")
print("aws dynamodb batch-write-item --request-items file://%s" % json_seed_name)
