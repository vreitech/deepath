# deepath

## Annotation

Dispatcher of HTTP JSON requests to Zabbix proxy / Zabbix server trapper TCP socket.

## Build with LDC

LDC compiler and DUB dependencies management system need to be installed on your system.

For making debug build you need to run in project directory:
```
dub build -b debug
```

For making static release build you need to run in project directory:
```
dub build -b release
```

## Build with Podman (or Docker) LDC container

Podman (or Docker) need to be installed on your system.

For making debug build you need to run in project directory:
```
podman --rm -it -v .:/src docker.io/vreitech/docker-ldc:v1.37.0 dub build -b debug
```

For making static release build you need to run in project directory:
```
podman --rm -it -v .:/src docker.io/vreitech/docker-ldc:v1.37.0 dub build -b release
```

## Getting application executable file

If build was success, use **deepath** binary.

Configuration file example: **config.yml**.

## Making systemd service for application

You may use example **deepath-endpoint.service** file from the project:
```
mkdir -p ~/.config/systemd/user \
&& cp deepath-endpoint.service ~/.config/systemd/user/ \
&& systemctl --user enable ~/.config/systemd/user/deepath-endpoint.service \
&& systemctl --user start deepath-endpoint.service
```
