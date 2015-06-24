# hubot-github-templated-issues

## Description

This is a [Hubot](https://hubot.github.com/) script that allows you to create a GitHub issue from pre-defined templates.

## Getting Started

### Create your hubot

```zsh
npm install -g yo generator-hubot
mkdir -p /path/to/hubot
cd /path/to/hubot
yo hubot
npm install hubot-github-templated-issues --save
```

Then add ```"hubot-github-templated-issues"``` to ```./external-scripts.json```.

See [Hubot documentation](https://hubot.github.com/docs/) for further details about Hubot.


## Configuration

This script uses environment variables below:

* ```HUBOT_GITHUB_TOKEN``` - GitHub personal access token which hubot uses
* ```TEMPLATE_GITHUB_REPO``` - GitHub repository for templates
* ```ISSUE_GITHUB_REPO``` - (Optional) GitHub repository where hubot creates an issue

### ```HUBOT_GITHUB_TOKEN``` (Mandatory)

This is used to get issue templates and create issues.

See [githubot document](https://github.com/iangreenleaf/githubot) on which this script depends for more details.

### ```TEMPLATE_GITHUB_REPO``` (Mandatory)

Specify GitHub repository having issue templates. (eg: user/repo)

### ```ISSUE_GITHUB_REPO``` (Optinal)

Specify GitHub repository where you want to create an issue. When this variable is omitted, ```TEMPLATE_GITHUB_REPO``` will be used instead.


## Usage

### Template Hint

Push issue templates to GitHub repository(```TEMPLATE_GITHUB_REPO```) wherever you want.
Template engine is [ECT](http://ectjs.com/).

:warning: Template file needs to have a suffix ```.ect```.

You can put a description on the top of template file like:

```
#
# This is a description line
#
# Parameters: 
#   vars: [ var, ... ]
#
```

This is useful to describe required variables by the template.

:warning: Leading header lines starting with ```#``` or ```//``` will be recognized as description. If you don't need a description, just put a blank line to the top.

### Hubot Commands

To create issue:

```
hubot issue create <path/to/template without suffix> <title of issue opening>\n
<YAML data to put into the template>
```

for example,

```
hubot issue create templated-issues/sample Issue Title
vars: [ foo, bar ]
```

To show template repository:

```
hubot issue repo from
```

To show issue repository:

```
hubot issue repo to
```

To show template list:

```
hubot issue templates <path/to/template/dir>
```

for example,

```
hubot issue templates templated-issues
```

To show template description (which is on the top of the template):

```
hubot issue template <path/to/template>
```

for example,

```
hubot issue template templated-issues/sample
```

Enjoy! :tada:
