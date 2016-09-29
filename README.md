![Foreman](https://raw.githubusercontent.com/theforeman/foreman-graphics/master/logo/foreman_medium.png)

[![Build Status](http://ci.theforeman.org/buildStatus/icon?job=test_develop)](http://ci.theforeman.org/job/test_develop/)
[![Code Climate](https://codeclimate.com/github/theforeman/foreman/badges/gpa.svg)](https://codeclimate.com/github/theforeman/foreman)
[![Issue Stats](http://issuestats.com/github/theforeman/foreman/badge/pr)](http://issuestats.com/github/theforeman/foreman)
[![Support IRC channel](https://kiwiirc.com/buttons/irc.freenode.net/theforeman.png)](https://kiwiirc.com/client/irc.freenode.net/?#theforeman)

[Foreman](http://theforeman.org) is a free open source project that gives you the power to easily **automate repetitive tasks**, quickly **deploy applications**, and proactively **manage your servers lifecyle**, on-premises or in the cloud.

From **provisioning** and **configuration** to **orchestration** and **monitoring**, Foreman integrates with your existing infrastructure to make operations easier.

* Website: [theforeman.org](http://theforeman.org)
* ServerFault tag: [Foreman](http://serverfault.com/questions/tagged/foreman)
* Issues: [Redmine](http://projects.theforeman.org/issues)
* Wiki: [Foreman wiki](http://projects.theforeman.org/projects/foreman/wiki/About)
* Community and support: We use [Freenode](irc.freenode.net) IRC channels
    * #theforeman for general support
    * #theforeman-dev for development chat
* Mailing lists:
    * [foreman-users](https://groups.google.com/forum/?fromgroups#!forum/foreman-users)
    * [foreman-dev](https://groups.google.com/forum/?fromgroups#!forum/foreman-dev)

Using Puppet, [Chef](http://github.com/theforeman/foreman_chef), [Salt](http://github.com/theforeman/foreman_salt) and Foreman's [smart proxy](http://github.com/theforeman/smart-proxy) architecture, you can easily automate repetitive tasks, quickly deploy applications, and proactively manage change, both on-premise with VMs and bare-metal or in the cloud.

Foreman provides comprehensive, interaction facilities including a **web frontend**, [**CLI**](http://theforeman.org/manuals/1.6/index.html#4.5CommandLineInterface) and [**RESTful API**](http://theforeman.org/api_v2.html) which enables you to build higher level business logic on top of a solid foundation.

Foreman is a mature project, deployed in [many organizations](http://projects.theforeman.org/projects/foreman/wiki/Who_Uses_Foreman), managing from 10s to 10000s of servers. It is used in distributions such as RDO and RHOS (Red Hat OpenStack distribution) and has [an extensive library of plugins](http://projects.theforeman.org/projects/foreman/wiki/List_of_Plugins).

# Features
* Automate your mixed infrastructure to make operations enjoyable
* Discover, provision and upgrade your entire bare-metal infrastructure
* Create and manage instances across private and public clouds
* Group your hosts and manage them in bulk, regardless of location
* Review historical changes for auditing or troubleshooting
* Extend as needed via a robust plugin architecture
* Automatically build images (on each platform) per system definition to optimize deployment
* LDAP authentication and RBAC authorization to your infrastructure
* and so [much more](http://theforeman.org/manuals/latest/index.html)

# Screenshots
![Hosts list](http://i.imgur.com/XXCtFFH.png)
![New host](http://i.imgur.com/e4XrLo2.png =100x20)
![EC2](http://i.imgur.com/IUQ0ciM.png)
![Provisioning templates](http://i.imgur.com/sn9CzN1.png)
![Subnets](http://i.imgur.com/QNO8tdh.png)
![Openstack](http://i.imgur.com/vCwOjdv.png)
![Edit Puppet class](http://i.imgur.com/8nIJip9.png)
![Reports](http://i.imgur.com/ns7Vg1e.png)
![Statistics](http://i.imgur.com/0Hlt7wO.png)
![Partition tables](http://i.imgur.com/Pgdhlsl.png)
![Installation media](http://i.imgur.com/5Uz9LFa.png)

# Installation
Read the [quickstart section](http://theforeman.org/manuals/latest/#2.Quickstart) of the manual. If you know your setup has some specific needs, read the [installation scenarios section](http://theforeman.org/manuals/latest/#3.2.3InstallationScenarios).

# Documentation
Our main documentation reference is the [Foreman manual](http://theforeman.org/manuals/latest/). If you find some gaps you would like to fill in the manual, please contribute in [this repo](https://github.com/theforeman/theforeman.org).

## API
We document our API using [apipie](https://github.com/Apipie/apipie-rails).The [API chapter](http://theforeman.org/manuals/latest/index.html#5.1API) has more information about accessing the API and the layout of requests and responses. Also see the [reference documentation](http://theforeman.org/api_v2.html) available on our website, or via your own Foreman installation by appending `/apidoc` to the URL to see the API routes available.

# Plugins
Plugins are tools to extend and modify the functionality of Foreman. They are implemented as Rails engines that are packaged as gems and thus easily installed into Foreman. Read the [plugins section](http://theforeman.org/manuals/latest/index.html#6.Plugins) of the manual for more information.

An up-to-date plugin list is kept in the [wiki](http://projects.theforeman.org/projects/foreman/wiki/List_of_Plugins)

# How to contribute?
Generally, follow the [Foreman guidelines](http://theforeman.org/contribute.html). For code-related contributions, fork this project and send a pull request with all changes. Some things to keep in mind:
* [Follow the rules](http://theforeman.org/contribute.html#SubmitPatches) about commit message style and create a Redmine issue. Doing this right will help reviewers to get your contribution merged faster.
* [Rubocop](https://github.com/bbatsov/rubocop) will analyze your code, you can run it locally with `rake rubocop`.
* All of our pull requests run the full test suite in our [Jenkins CI system](http://ci.theforeman.org/). Please include tests in your pull requests for any additions or changes in functionality

# Media
We keep a repository of talks, tutorials, articles about everything in the Foreman ecosystem in the [media section](http://theforeman.org/media.html) of our web. If you want to get yours published, just submit a pull request to [theforeman.org repository](https://github.com/theforeman/theforeman.org)

# Special thanks

The original authors of this project are [Ohad Levy](http://github.com/ohadlevy) and [Paul Kelly](http://github.com/pikelly).
You can find a more thorough list of people who have contributed to this project at some point in [Contributors](Contributors).

# License

See [LICENSE](LICENSE) file.
