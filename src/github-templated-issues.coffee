# Description
#   A way to create a github issue from template via hubot
#
# Configuration:
#   HUBOT_GITHUB_TOKEN - GitHub personal access token which hubot uses
#   TEMPLATE_GITHUB_REPO - GitHub repository for templates (eg: user/repo)
#   ISSUE_GITHUB_REPO - (Optional) GitHub repository where hubot creates an issue (eg: user/repo)
#
# Commands:
#   hubot issue create <path> <title>\n<yaml data> - Create a github issue with template and data
#   hubot issue repo from - Show github repository for template
#   hubot issue repo to - Show github repository where issues to be opened
#   hubot issue templates - Show templates of issues
#   hubot issue template <path> - Show details of issue templates
#
# Author:
#   Shintaro Kojima <goodies@codeout.net>

yaml = require('js-yaml')
GithubTemplate = require('./github-templated-issues/github_template')
GithubIssue = require('./github-templated-issues/github_issue')


module.exports = (robot) ->
  define_error_handler = (msg) ->
    (error) ->
      msg.send "ERROR: #{error}"
      msg.robot.logger.error(error)

  robot.respond /issue\s+create\s+(\S+)\s+(.*)/i, (msg) ->
    error_handler = define_error_handler(msg)

    try
      data = yaml.safeLoad(msg.match.input.replace(/.*/, ''))
      template = new GithubTemplate(error_handler)

      template.render msg.match[1], data, (error, result) ->
        return error_handler(error) if error
        issue = new GithubIssue(error_handler, msg.match[2], result)

        issue.create (error, created) ->
          return error_handler(error) if error
          msg.send "issue created\n#{created.html_url}"

    catch error
      error_handler 'Invalid YAML data'

  robot.respond /issue\s+(repo|repository)\s+from/i, (msg) ->
    error_handler = define_error_handler(msg)

    template = new GithubTemplate(error_handler)
    template.repo_url (error, url) ->
      return error_handler(error) if error
      msg.send url

  robot.respond /issue\s+(repo|repository)\s+to/i, (msg) ->
    error_handler = define_error_handler(msg)

    issue = new GithubIssue(error_handler)
    issue.repo_url (error, url) ->
      return error_handler(error) if error
      msg.send url

  robot.respond /issue\s+templates\s+(\S+)/i, (msg) ->
    error_handler = define_error_handler(msg)

    template = new GithubTemplate(error_handler)
    template.list msg.match[1], (error, paths) ->
      return error_handler(error) if error
      msg.send paths.join("\n")

  robot.respond /issue\s+template\s+(\S+)/i, (msg) ->
    error_handler = define_error_handler(msg)

    template = new GithubTemplate(error_handler)
    template.info msg.match[1], (error, info) ->
      return error_handler(error) if error
      msg.send info
