[![pipeline status](https://gitlab.com/f.chertiev/deepath/badges/main/pipeline.svg)](https://gitlab.com/f.chertiev/deepath/-/commits/main)

# deepath

## Annotattion

Requests dispatcher from HTTP JSON requests to Zabbix proxy / Zabbix server trapper TCP socket.

## Build

LDC compiler v2 and DUB dependencies management system must be installed on your system.

For making debug build in project directory need to run:
```
dub build -b debug
```

For making static release build need to run:
```
dub build -b release
```

If build was success, use **deepath** binary.

Configure file example: **config.yml**.
