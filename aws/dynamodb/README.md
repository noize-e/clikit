DynamoDB JSON Schemas Converter
===============================

### Conver: JSON to DynamoDB-JSON

In `dump_db_json.py` set:

```python
# input file
json_name = "basic.json"

# output file
json_seed_name = "parsed.json"

# dynamodb table name
table_name = "TableName"
```

#### Example

The first item form the input file always must be a list:

```json
[
  {
    "uid": 1,
    "salt": "$2B$12$......",
    "media": {
      "content": "/media1...m3u8",
    }
  }
]
```

Once you run it into your terminal __`python schema_gen.py`__, it creates a output json file:

```json
{
  "TableName": [
    {
      "PutRequest": {
        "Item": {
          "pid": {
            "N": "2"
          },
          "sid": {
            "N": "1"
          },
          "salt": {
            "S": "$2B$12$Pfsv3Tw6Rakclh/Ustdc3U"
          },
          "media": {
            "M": {
              "content": {
                "S": "/media1/live-radio-session-1.m3u8"
              }
            }
          },
          "hour": {
            "S": "17"
          },
          "created_at": {
            "S": "2019-09-12T22:21:39.828436"
          }
        }
      }
    }
  ]
}
```

Now just run __`aws dynamodb batch-write-item --request-items file://parsed.json`__ and there you go, you have your items recorded into the dynamodb table.
