# Traefik Reverse Proxy with TLS running locally

Let's setup a local reverse proxy that does name-based virtual hosting, routing to docker containers and provides valid TLS out-of-the-box.

> Many thanks go to <https://get.localhost.direct/> for having registered the DNS wildcard and providing the matching TLS certificate on `*.localhost.direct`.
>
> Read their story over here <https://get.localhost.direct/> ..

## Usage

1. Build the image and start the traefik and the pgadmin containers from the example [docker-compose.yml](docker-compose.yaml)

    ```bash
    docker compose up -d --build

    # Mac-only: open browser from the shell
    open http://localhost:8080
    open https://pgadmin.localhost.direct
    ```

1. Open <http://localhost:8080>
    * the [Traefik dashboard](https://doc.traefik.io/traefik/operations/dashboard/) will open
    * all routes that were discovered show up --> <http://localhost:8080/dashboard/#/http/routers>

2. Open one of the container`s routes
    * <http://pgadmin.localhost.direct>
        * the browser will be redirected to <https://pgadmin.localhost.direct>
        * the tls certificate shows up left to the browser address bar as being valid (with a non-red/non-broken lock symbol</i> lock symbol

and also then:

3. Open one of the container`s routes
    * <https://pgadmin.localhost.direct>
      * the tls certificate shows up left to the browser address bar as being valid (with a non-red/non-broken <i class='fas fa-lock'> </i> lock symbol

## What is happening

The Docker Compose file will create a reverse proxy with routing capabilities!

* the [docker-compose file](docker-compose.yaml) is included in this project

Results:

* all containers get a dedicated hostname in a shared DNS domain
* that domain can be resolved on the host system
* port 80 redirects to port 443
* port 443 servers TLS with a valid certificate from <https://localhost.direct>

## Setting up your own project

For your own setup, include the traefik configuration from  [docker-compose file](docker-compose.yaml):

Choose to use the image you build yourself:

```yaml
traefik:
    image: traefik-with-localhost-tls:2.10
```

or use my image from dockerhub:

```yaml
traefik:
    image: avogt/traefik-with-localhost-tls:2.10
```

and continue with the configuration like so:

```yaml
traefik:
    image: traefik-with-localhost-tls:2.8
    ports:
      - '80:80'
      - '443:443'
      - '8080:8080'
    command:
      - --providers.file.filename=/traefik_conf.yml
      - --entrypoints.web.address=:80
      - --entrypoints.web.http.redirections.entryPoint.to=websecure
      - --entrypoints.web.http.redirections.entryPoint.scheme=https
      - --entrypoints.websecure.address=:443
      - --entrypoints.websecure.http.tls=true
      - --providers.docker=true
      - --providers.docker.watch=true
      - --providers.docker.exposedbydefault=false
      - --api
      - --api.insecure=true
      - --api.dashboard=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

```

* there is no `build:` tag, which assumes the image has been build already and is available in the local docker registry

## Further optimization

You may want to remove the port 80 altogether to force use of the tls endpoint at all time during development:

1. remove the `ports: -'80:80'`
1. remove `- --entrypoints.web.address=:80`
1. remove redirecting:

    ```yaml
     --entrypoints.web.http.redirections.entryPoint.to=websecure
     --entrypoints.web.http.redirections.entryPoint.scheme=https
    ```

## Building the image for Dockerhub

Playing nicely for all the upcoming Apple Silicon users, I created the image as a [multi-arch](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/) image.

First, create a buildx builder with your local docker desktop, then run a multi-platform build and push to the existing repository on dockerhub registry:

- create a buildx builder

    ```bash
    docker buildx create --use
    ```

- then build and push the image

    ```bash
    docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag avogt/traefik-with-localhost-tls:2.10 .
    ```
