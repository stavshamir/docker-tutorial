# Docker Compose Integration to GitLab CI

This is a guide for the integration into GitLab CI of the code for the
[Dockerizing a Flask-MySQL app with
docker-compose](https://medium.com/@shamir.stav_83310/dockerizing-a-flask-mysql-app-with-docker-compose-c4f51d20b40d)
article.

## Introduction

GitLab, just like GitHub, is a web-based versioning control system powered by
Git. In addition, GitLab aims to support the whole development lifecycle. One of
its features is Continuous Integration (CI).

The CI feature triggers a pipeline for building and testing upon every code
submission. This ensures automatically that the latest code works and allows
that multiple contributors can continuously integrate (merge) their code into
the main repository with confidence.

Nevertheless, every CI system requires some extra effort from the developers:
They have to provide instructions on how the code builds and how the application
is tested.

The rest of this guide describes the [.gitlab-ci.yml](.gitlab-ci.yml) file that
contains the commands for the Docker Compose, Flask, and MySQL combination,
based on the aforementioned article and a Stack Overflow related
[answer](https://stackoverflow.com/a/52734017).

## Base Docker Image

Every time a commit is submitted, one or more Docker containers are spawned in
GitLab CI. These Docker containers serve as an isolated volatile environment to
check the whole codebase, with the latest changes included of course.

GitLab CI is enabled if a `.gitlab-ci.yml` file exists in the root directory of
a GitLab project. All the code snippets that follow are taken from this
project's [.gitlab-ci.yml](.gitlab-ci.yml). This file starts with the
declaration of a Docker image. In our case, we will use the official
`docker/compose` image. Besides, we need to execute several `docker-compose`
commands in it.

```yaml
image:
  name: docker/compose:1.24.1
```

We stick to a specific `docker/compose` image version, e.g. `1.24.1`. This is
done because, as we can see in the related
[versions](https://hub.docker.com/r/docker/compose/tags) page, no default
`latest` tag exists.

```yaml
  entrypoint: ["sh", "-c"]
```

The above statement is needed in order to execute shell commands. If we omit it,
only plain `docker-compose` commands can be executed.

## Docker in Docker

We are going to execute `docker` commands inside a `docker/compose` container.
This isn't as straightforward as it seems, because `docker` is designed to run
directly in the host machine and not inside a Docker container. This limitation
can be eliminated using the Docker in Docker `dind` service.

```yaml
services:
  - docker:dind

variables:
  DOCKER_HOST: tcp://docker:2375
  DOCKER_DRIVER: overlay2
```

The above two variables are set according to GitLab
[instructions](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html), to
facilitate the communication between the Docker container and the host machine.

## Execution

In GitLab CI, a job is created by simply writing its name followed by a colon.
Below, we define the `Build and Test` job.

```yaml
Build and Test:
  before_script:
    - apk add --update curl
    - docker version
    - docker-compose version
```

The commands of a job are divided into three sections: `before_script`,
`script`, and `after_script`. In the first section above, we install `curl`, and
we print the versions of the Docker commands.

```yaml
  script:
    - docker-compose build
    - docker-compose up --detach
```

The main commands are under the `script` section. The containers are being run
in detached mode. This allows the execution of more commands after
`docker-compose up`. With the following commands we ensure that the application
and database are up and running.

```yaml
    - until [ $(docker-compose logs app | grep -c "Running on ") -eq 1 ];
      do
        sleep 2;
      done
    - until [ $(docker-compose logs db | grep -c "ready for connections") -eq 2 ];
      do
        sleep 2;
      done
```

`docker-compose logs` command gives the output of the corresponding service. The
database should output twice the `ready for connections` message: one at the
beginning and another after the database is fed with the database schema.

## Testing

Last but not least, after all services are initialized, we should check that
everything works as expected. We store the expected output into the `expected`
file. The `- >` symbols below are used to overcome the need of escaping a bunch
of quotes that follow.

```yaml
    - >
      echo -n '{"favorite_colors": [{"Lancelot": "blue"}, {"Galahad":
      "yellow"}]}' > expected
```

Then, we get the real server response via `curl`. Instead of hitting the
`localhost` domain, we use the `docker` keyword, due to the Docker in Docker
limitations.

```yaml
    - curl -f http://docker:5000 > output
```

Finally, we compare the expected to the real output. If the comparison or any of
the commands fail, the `success` file will never be created.

```yaml
    - diff expected output
    - touch success
```

If the `success` file doesn't exist, all the logs are printed for debugging
purposes.

```yaml
  after_script:
    - if [ ! -e success ]; then
        docker-compose logs;
      fi
```

See the output of the CI job
[here](https://gitlab.com/TrendDotFarm/docker-tutorial/-/jobs/274492170).
