FROM library/traefik:v2.10
COPY localhost.direct.crt /
COPY localhost.direct.key /
COPY traefik_conf.yml /
