# WARProxy

Use Cloudflare WARP as your socks5 proxy server with one click.

Includes:
- WGCF: generate cf warp accounts and wireguard config automatically.
- WireProxy: create socks5 proxy.
- Warp+: refresh warp+ traffic.
- Health check etc.

## Usage
```yaml
version: "3"
services:
  warproxy:
    build: .
    network_mode: bridge
    restart: always
    environment:
      - WARP_PLUS=true
      - ENDPOINT=162.159.192.12
      - DNS=223.5.5.5
    ports:
      - 1080:1080
```

### To change license key
If you have an existing Warp+ license key, edit `/config/wgcf-account.toml` and,  delete two files :  
`/config/wgcf-profile.conf` and `/config/wireproxy.conf`  
When you restart container, it will update your account info and re-generate conf files automatically.


## Environment variables

| ENV  | Description  | Default  |
|---|---|---|
| ```PUID``` / ```PGID```  | uid and gid for running an app  | ```911``` / ```911```  |
| ```TZ```  | timezone  | ```Asia/Seoul```  |
| ```PROXY_ENABLED```  | set ```false``` to disable proxy | ```true``` |
| ```PROXY_PORT```  | to run proxy in a different port  | ```1080``` |
| ```PROXY_VERBOSE```  | simple access logging  |  |
| ```PROXY_AUTHTIME```  | re-auth time interval for same ip (second in string format)  | ```0``` |
| ```WARP_ENABLED```  | set ```false``` to disable cloudflare WARP  | ```true``` |
| ```WARP_PLUS```  | set ```true``` to enable auto WARP+ quota script  | ```false``` |
| ```WARP_PLUS_VERBOSE```  | set ```true``` to run auto WARP+ quota script in verbose mode   | ```false```  |


## Thanks
* [105PM](https://github.com/105PM/docker-warproxy)
* [by275 (docker-dpitunnel)](https://github.com/by275/docker-dpitunnel)