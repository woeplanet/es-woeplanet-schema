# es-woeplanet-schema

Elasticsearch schemas for Woeplanet indices to stop Elasticsearch being clever with data mappings.

## Indices and Aliases

### Listing Current Indices and their Aliases

```
$ curl -s http://localhost:9200/_aliases | python -mjson.tool
{
    "placetypes_20200621": {
        "aliases": {
            "placetypes": {}
        }
    },
    "woeplanet_20200619": {
        "aliases": {
            "woeplanet": {}
        }
    }
}
```

Each index is date-stamped in YYYYMMDD format with a date-less alias pointing to it.

### Creating a New Index

```
$ cat ./schema/7.x/mappings.woeplanet.json | curl -s -XPUT http://localhost:9200/woeplanet_20200601 -H "Content-Type: application/json" -d @- | python -mjson.tool
{
    "acknowledged": true,
    "index": "woeplanet_20200601",
    "shards_acknowledged": true
}
```

### Creating a New Alias

```
$ curl -s -XPOST http://localhost:9200/_aliases -H "Content-Type: application/json" -d '{"actions":[{"add":{"alias": "woeplanet", "index": "woeplanet_20200601"}}]}' | python -mjson.tool
{
    "acknowledged": true
}
```

### Helper Script

The `./bin/reload-schema.sh` script will do the following:

1. Delete a current index and automagically delete its aliases
2. Re-create the index from its schema mapping file with the current date-stamp
3. Create a new alias to point to the just created index

The script takes two optional arguments; the _index name_ without date-stamp and the _old_ date-stamp for the previous index version.

```
$ ./bin/reload-schema.sh placetypes 20200621
Deleting index 'placetypes_20200621'
{
    "acknowledged": true
}
Creating index 'placetypes_20200621'
{
    "acknowledged": true,
    "index": "placetypes_20200621",
    "shards_acknowledged": true
}
Aliasing 'placetypes_20200621' as 'placetypes'
{
    "acknowledged": true
}
```

```
$ cat schema/7.x/mappings.woeplanet.json | curl -X PUT http://localhost:9200/woeplanet_20200619 -H 'Content-Type: application/json' -d @-
$ curl -X POST http://localhost:9200/_aliases -H 'Content-Type: application/json' -d '{"actions":[{"add":{"alias": "woeplanet", "index": "woeplanet_20200619"}}]}'
```
