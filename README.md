# tor2web

![Docker Image Size](https://img.shields.io/docker/image-size/abikome/tor2web)

An HTTP proxy that enables access to Tor Hidden Services

## Features

* Blazing fast streaming HTML parser
* Accurate link replacement
* Compression support
* Low footprint — less than 16 MiB Docker image
* Simple and maintainable

## Setup

```bash
docker run -d --name=tor2web \
              --cap-add=NET_ADMIN \
              -p 80:80 \
              -e TOR2WEB_HOST=abiko.me \
              -v $PWD:/etc/tor2web:ro \
              abikome/tor2web
```

## License

[Apache 2.0] © [Danila Poyarkov]

[Apache 2.0]: LICENSE
[Danila Poyarkov]: http://dannote.net
