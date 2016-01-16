# Dugout

Dugout is a companion app for "dockerized" applications, specifically targetted to micro-services applications.

It helps to maintain a coherent containerized development platform across a team.

The app is built for **Mac OS X (64 bits)** and **Linux (64 bits)**.

Windows (64 bits) support will be added later.

## Features

- Run/monitor/stop the containers of your projects with ease
- Automatic image pull
- Flexible configuration through variables
- Support following container features:

    - links
    - volumes
    - ports
    - environment variables
    - command

- Private registries ready, even with basic-http authentication

## Run

- Download the [latest release](https://github.com/mobapi/dugout/releases/latest) for your platform, and unzip it.
- Build your own project configuration file. See `project.sample.json`.
- Launch the app and load your configuration file
- Configure your containers if needed, and start them up !
- You're done !

### The "project sample" configuration file (project.sample.json)

This file is a sample of a common micro-service application: a three-tier web app.
The 3 containers (aka tiers) are:

- a nginx frontend
- a nodejs backend, linked to the database container
- a mongo database

### The project configuration file structure

The projects configuration file is a JSON file, which must contain an object describing the project and each container:

	{
		"name": "<project name>",
		"version": "<project version>",
		"containers": {
			...
		}
	}

#### Project configuration

|Field|Mandatory|Type|Description|
|---|---|---|---|
|name||string|Name (label) of the project|
|version||string|Version of the project|

#### Containers configuration

**The key of the container object is the container identifier.**

Each container has several fields to describe it, some are mandatories, some are optional:

|Field|Mandatory|Type|Description|
|---|---|---|---|
|name|x|string|Name (label) of the container|
|image|x|string|Image name|
|ports| |object|Ports redirection mappings|
|mounts| |object|Volumes mounts mappings|
|links| |object|Container links mappings|
|environment| |object|Environment variables|
|cmd| |string|Command line to run in the container (defaults to "CMD" of the dockerfile)|
|variables| |object|Variables|

    {
        "<container identifier>": {
            "name": "<container name>",
            "image": "<image name>",
            "ports": {
            },
            "mounts": {
            },
            "links": {
            },
            "environment": {
            },
            "cmd": "<command line to run when the container starts>",
            "variables": {
            }
        }
    }

#### container identifier

This information is not contained in a field, but is the key of the object.

#### name

Field of type string containing the name of the project.

#### image

Field of type string containing the name of the image.

#### ports

Field of type object containing the ports redirections mappings.

    {
        "<container port/range>": "<host port/range>"
    }

*Example:*

    {
        "80/tcp": "81",
        "443/tcp": "444"
    }

#### mounts

Field of type object containing the volumes mounts mappings.

    {
        "<container mount point>:<options>": "<host directory>"
    }

*Example:*

    {
        "/usr/share/nginx/html:ro": "/home/myproject"
    }

#### links

Field of type object containing the container links mappings.
*Important:* the linked containers are seen as dependencies, Dugout will take care of starting the projects in the right order.

    {
        "<alias>": "<container name>"
    }

*Example:*

    {
        "mydatabase": "my-database"
    }
In this example, the container named "my-database" is linked in the current container via a "/etc/hosts" alias ("mydatabase").

#### environment

Field of type object containing the environment variables.


    {
        "<environment variable name>": "<value>"
    }

*Example:*

    {
        "MYSQL_ROOT_PASSWORD": "aGr34tPa55w0rD"
    }
In this example, the environment variable named "MYSQL_ROOT_PASSWORD" will have the value "aGr34tPa55w0rD".

#### cmd

Field of type string containing the command line to run when the container starts.
If no value is provided, the default will be the "CMD" field of the container image dockerfile.

#### variables

Field of type object containing the variables that will be used in the project configuration.
Each variable will have a corresponding input field in the configuration tab of the project.
*Note: the scope of a variable is the containing project.*

##### Variable description

|Field|Mandatory|Type|Description|
|---|---|---|---|
|name|x|string|Name (label) of the variable input field|
|type|x|string|Variable type, possible values are: "string", "number", "directory", "file"|
|value| | |Variable default value|
|mandatory| |boolean|Will the varialbe value be mandatory ?|

    {
        "<variable identifier (machine name)>": {
            "name": "<name of the variable>",
            "type": "<type of the variable>",
            "value": "<default value>",
            "mandatory": "<is the variable value mandatory ?>"
        }
    }

##### Variable reference

A variable could be reference in the project configuration, as the following examples:

|Variable|Reference|
|---|---|
|a|${a}|
|i|${i}|
|repo|${repo}|

*Example:*

    "frontend": {
        "name": "My website frontend",
        "image": "nginx",
        "ports": {
            "80/tcp": "8080"
        },
        "mounts": {
            "/usr/share/nginx/html:ro": "${repositoryDirectory}/dist"
        },
        "variables": {
            "repositoryDirectory": {
                "name": "Repository directory",
                "type": "directory",
                "value": null,
                "mandatory": true
            }
        }
    }

Note the the *repositoryDirectory* is referenced in `mounts as *${repositoryDirectory}.*
In this example, if the user choose "/home/me/myproject" for the *repositoryDirectory* value, the `mounts` will be calculated from:

        "mounts": {
            "/usr/share/nginx/html:ro": "${repositoryDirectory}/dist"
        },

to:

        "mounts": {
            "/usr/share/nginx/html:ro": "/home/me/myproject/dist"
        },


## Compilation

### Requirements

- npm
- bower
- wine, if not building on a windows platform (for the win ico)

### Steps

    npm up
    bower up
    npm run-script build

The binaries will be in the `build` directory.

To build the mac icon:

    chmod 755 buildMacIconset.sh
    ./buildMacIconset.sh src/images/logo.png

To build the win icon:

    chmod 755 buildWinIco.sh
    ./buildWinIco.sh src/images/logo.png
