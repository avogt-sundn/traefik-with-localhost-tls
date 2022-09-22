FROM traefik:2.8
COPY localhost.direct.crt /
COPY localhost.direct.key /
COPY traefik_conf.yml /
