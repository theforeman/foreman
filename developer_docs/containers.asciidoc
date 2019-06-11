[[Containers]]
= Using or Building a Foreman container
:toc: right
:toclevels: 5

The goal of this tutorial is to help developers to use quickly and easily a ready made Foreman container, or in cases where required, build their own version of it. 

Taken from original post at https://community.theforeman.org/t/dockerfile-is-now-included-in-foreman-core/13987/1

[[prerequisites]]
== Prerequisites

In order use or build containers, one would require a container run time tool such as docker, podman etc.

If you already have a running docker environment, feel free to skip the following section.

[source, bash]
....
sudo groupadd docker
sudo yum install docker docker-compose
sudo usermod -aG docker $USER
newgroup docker
sudo service docker start
....

[[docker-compose]]
== Using Docker Compose
=== Initial usage

[source, bash]
....
docker-compose pull
docker-compose run app bundle exec rake db:create db:migrate
docker-compose run app bundle exec rake db:seed permissions:reset password=changeme 
docker-compose up
....

You now may login to http://localhost:3000
username admin, password changeme

=== Shutting down

[source, bash]
....
docker-compose down
....


=== Updating to latest images

[source, bash]
....
docker-compose pull
docker-compose run app bundle exec rake db:migrate db:seed
docker-compose up
....

=== Additional Commands

You may explore docker compose https://docs.docker.com/compose/[official documentation]
[building]
== Building your own Image

[quay]
=== Using quay.io
I’ve found its easiest simply to configure https://quay.io to build the images for me, the workflow is simple enough (e.g. on every git push to my repository an image will be built) and it doesn’t slow down my machine while building it (it takes about 7-8 minutes or so).

=== Building locally

Please note that the version of docker that is used in Fedora is too old (multi stage builds feature requiring Docker 17.05), one might consider using podman, moby or official docker repository to build locally.

Simply run
[source, bash]
....
docker-compose build app
....
or
[source, bash]
....
docker build . -t mytag
....
if you have any plugins configured in your `bundler.d/Gemfile.local.rb` it will pick them up and include them in your generated container, you would then might need to change the line pointing to the container image to point to the image you just created.

If you happen to have gem in a local checkout - e.g.

[source, ruby]
....
gem 'foreman_memcache', path: '../foreman_memcache'
....

and don’t want to mess up with paths (on your system and within the container), I would suggest to create directory called `dev` or something under your foreman directory, so in your bundle file you have something like

[source, ruby]
....
gem 'foreman_memcache', path: 'dev/foreman_memcache'
....
I personally just did

[source, bash]
....
mkdir dev
cd dev
ln -s ../../foreman_memcache .
cd ..
....

and then, use tar to combine all needed directories and follow symlinks, e.g.

[source, bash]
....
tar -chf - --exclude-from=.dockerignore . | docker build -
....

*Buildah note*: In case you wanted to build the container image with Buildah, be aware of https://github.com/containers/buildah/issues/1578[the following issue] that currently prevents using it.

==== Building base images

In the build process, there are base images used to:

* have a faster image build time (to avoid installing ruby/node/python all the time)
* have a image that can be used for development
* speed up plugin image build time by reusing a foreman published build image

Here are the layers used in the process:

quay.io/theforeman/foreman-base::
    the base OS with minimal runtime (ruby, node, python) dependencies.
quay.io/theforeman/foreman-builder-base::
    the base image for the builder image, with pre-installed devel/build dependencies
builder::
    https://docs.docker.com/develop/develop-images/multistage-build/[a staged image]
    to build the assets and other built-time artifacts to be copied over to the final image


....
Dockerfile.builder-base[quay.io/theforeman/foreman-base]
│
├─ Dockerfile.builder-base[quay.io/theforeman/foreman-builder-base]
│  │
│  └─ Dockerfile[builder]
│     ¦
│     ¦ # artifacts copied over
│     v
└─ Dockerfile
....

[source, bash]
....
docker build --target base -t quay.io/foreman/foreman-base -f containers/Dockerfile.builder-base .
docker build -t quay.io/foreman/foreman-builder-base -f containers/Dockerfile.builder-base .
....