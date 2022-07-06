### Setup

#### Push docker image

```sh
docker build -t stlk/fly-machines-demo:latest .
docker push stlk/fly-machines-demo:latest
```

#### Follow the docs

Follow the docs https://fly.io/docs/reference/machines/ to make sure following steps are up to date.

```sh
flyctl machines api-proxy
```

```
POST http://{{FLY_API_HOSTNAME}}/v1/apps

{
  "app_name": "fly-machines-demo",
  "org_slug": "personal"
}
```

```sh
flyctl ips allocate-v4 -a fly-machines-demo
```

```
POST http://{{FLY_API_HOSTNAME}}/v1/apps/fly-machines-demo/machines

{
  "name": "fly-machines-demo-machine",
  "config": {
    "image": "stlk/fly-machines-demo:latest",
		"guest": {
			"cpu_kind": "shared",
			"cpus": 1,
			"memory_mb": 512
		},
    "env": {
      "APP_ENV": "production",
			"FORWARDED_ALLOW_IPS": "*"
    },
    "services": [
      {
        "ports": [
          {
            "port": 443,
            "handlers": [
              "tls",
              "http"
            ]
          },
          {
            "port": 80,
            "handlers": [
              "http"
            ]
          }
        ],
        "protocol": "tcp",
        "internal_port": 8000
      }
    ]
  }
}
```
