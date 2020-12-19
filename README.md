![Foreman](https://raw.githubusercontent.com/theforeman/foreman-graphics/master/logo/foreman_medium.png)

[![Build Status](https://ci.theforeman.org/buildStatus/icon?job=foreman-develop-source-release)](https://ci.theforeman.org/job/test_foreman-develop-source-release/)
[![Code Climate](https://codeclimate.com/github/theforeman/foreman/badges/gpa.svg)](https://codeclimate.com/github/theforeman/foreman)
[![Coverage Status](https://coveralls.io/repos/github/theforeman/foreman/badge.svg?branch=develop)](https://coveralls.io/github/theforeman/foreman?branch=develop)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Support IRC channel](https://kiwiirc.com/buttons/irc.freenode.net/theforeman.png)](https://kiwiirc.com/client/irc.freenode.net/?#theforeman)
[![Storybook](https://raw.githubusercontent.com/storybooks/brand/master/badge/badge-storybook.svg)](https://foreman-storybook.surge.sh)

[Foreman](https://theforeman.org) is a free open source project that gives you the power to easily **automate repetitive tasks**, quickly **deploy applications**, and proactively **manage your servers life cycle**, on-premises or in the cloud.

From **provisioning** and **configuration** to **orchestration** and **monitoring**, Foreman integrates with your existing infrastructure to make operations easier.

* Website: [theforeman.org](https://theforeman.org)
* ServerFault tag: [Foreman](https://serverfault.com/questions/tagged/foreman)
* Issues: [Redmine](https://projects.theforeman.org/issues)
* Wiki: [Foreman wiki](https://projects.theforeman.org/projects/foreman/wiki/About)
* Community and support: We use [Freenode](https://freenode.net) IRC channels
    * #theforeman for general support
    * #theforeman-dev for development chat
* Mailing lists:
    * [foreman-users](https://groups.google.com/forum/?fromgroups#!forum/foreman-users)
    * [foreman-dev](https://groups.google.com/forum/?fromgroups#!forum/foreman-dev)

Using [Puppet](https://www.theforeman.org/manuals/latest/#4.2ManagingPuppet), [Ansible](https://theforeman.org/plugins/foreman_ansible/), [Chef](https://theforeman.org/plugins/foreman_chef/), [Salt](https://theforeman.org/plugins/foreman_salt/) and Foreman's [smart proxy](https://www.theforeman.org/manuals/latest/#4.3SmartProxies) architecture, you can easily automate repetitive tasks, quickly deploy applications, and proactively manage change, both on-premise with VMs and bare-metal or in the cloud.

Foreman provides comprehensive, interaction facilities including a **web frontend**, [**CLI**](https://theforeman.org/manuals/latest/index.html#4.5CommandLineInterface) and [**RESTful API**](https://theforeman.org/documentation.html) which enables you to build higher level business logic on top of a solid foundation.

Foreman is a mature project, deployed in [many organizations](https://projects.theforeman.org/projects/foreman/wiki/Who_Uses_Foreman), managing from 10s to 10000s of servers. It is used in distributions such as RDO and RHOS (Red Hat OpenStack distribution) and has [an extensive library of plugins](https://projects.theforeman.org/projects/foreman/wiki/List_of_Plugins).

# Features
* Automate your mixed infrastructure to make operations enjoyable
* Discover, provision and upgrade your entire bare-metal infrastructure
* Create and manage instances across private and public clouds
* Group your hosts and manage them in bulk, regardless of location
* Review historical changes for auditing or troubleshooting
* Extend as needed via a robust plugin architecture
* Automatically build images (on each platform) per system definition to optimize deployment
* LDAP authentication and RBAC authorization to your infrastructure
* and so [much more](https://theforeman.org/documentation.html)

# Screenshots
![Hosts list](http://i.imgur.com/VMMLRd3.png)
![New host](http://i.imgur.com/wl9MCyz.png)
![EC2](http://imgur.com/x6gCogZ.png)
![Provisioning templates](http://imgur.com/J3szFIu.png)
![Subnets](http://imgur.com/isBcyGb.png)
![Compute Resource](http://imgur.com/BetWNzW.png)
![Edit Puppet class](http://imgur.com/0KDClmy.png)
![Reports](http://imgur.com/NxlP7yo.png)
![Statistics](http://imgur.com/DKGjtFQ.png)
![Partition tables](http://imgur.com/Gg80lzg.png)
![Installation media](http://imgur.com/BsYcvoM.png)

# Installation
Read the [quickstart section](https://theforeman.org/manuals/latest/quickstart_guide.html#QuickstartGuide) of the manual. If you know your setup has some specific needs, read the [installation scenarios section](https://theforeman.org/manuals/latest/#3.2.3InstallationScenarios).

# Documentation
Our main documentation reference is the [Foreman manual](https://theforeman.org/manuals/latest/). If you find some gaps you would like to fill in the manual, please contribute in [this repo](https://github.com/theforeman/theforeman.org).

## API
We document our API using [apipie](https://github.com/Apipie/apipie-rails).The [API chapter](https://theforeman.org/manuals/latest/index.html#5.1API) has more information about accessing the API and the layout of requests and responses. Also see the [reference documentation](https://theforeman.org/api/) available on our website, or via your own Foreman installation by appending `/apidoc` to the URL to see the API routes available.

# Plugins
Plugins are tools to extend and modify the functionality of Foreman. They are implemented as Rails engines that are packaged as gems and thus easily installed into Foreman.

The [plugins page](https://theforeman.org/plugins/) lists all available plugins and has more information about how to install and develop them.

# How to contribute?
Generally, follow the [Foreman guidelines](https://theforeman.org/contribute.html). For code-related contributions, fork this project and send a pull request with all changes. Some things to keep in mind:
* [Follow the rules](https://theforeman.org/contribute.html#SubmitPatches) about commit message style and create a Redmine issue. Doing this right will help reviewers to get your contribution merged faster.
* We have a [development handbook](https://theforeman.org/handbook.html) to help developers understand how Foreman developers code.
* [Rubocop](https://github.com/bbatsov/rubocop) will analyze your code, you can run it locally with `rake rubocop`.
* All of our pull requests run the full test suite in our [Jenkins CI system](https://ci.theforeman.org/). Please include tests in your pull requests for any additions or changes in functionality

# Media
We keep a repository of talks, tutorials, articles about everything in the Foreman ecosystem in the [media section](https://theforeman.org/media.html) of our web. If you want to get yours published, just submit a pull request to [theforeman.org repository](https://github.com/theforeman/theforeman.org)

# Special thanks

The original authors of this project are [Ohad Levy](https://github.com/ohadlevy) and [Paul Kelly](https://github.com/pikelly).
You can find a more thorough list of people who have contributed to this project at some point in [Contributors](Contributors).

# Licensing

See [LICENSE](LICENSE) file.

The Foreman repository/package is licensed under the GNU GPL v3 or newer, with some exceptions.

Copyright (c) 2009-2020 to Ohad Levy, Paul Kelly and their respective owners.

All copyright holders for the Foreman project are in the separate file called Contributors.

Except where specified below, this program and entire repository is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see [GNU licenses](http://www.gnu.org/licenses/).

The following files and directories are exceptions:

* app/views/unattended/ztp/provision.erb is (c) 2013, Juniper Networks under 2-clause BSD license.
* lib/tasks/convert.rake is (c) 2008, Matson Systems, Inc. under Revised BSD license.
* extras/noVNC/websockify is (c) 2011, Joel Martin under LGPL v3 license.
* vendor/assets/fonts/ is (c) 2011-2016, Red Hat Inc. under SIL Open Font License v1.1 or LGPL v2.1 licenses.
* vendor/assets/javascripts/jquery.flot.axislabels.js is (c) 2010 Xuan Luo under MIT license.
* app/assets/images/RancherOS.png is (c) 2018 Rancher Labs, Inc.

All rights reserved.

The [LICENSE](LICENSE) file contains the full text of the GNU GPL v3 license, along with the text for all additional licenses referenced above.

