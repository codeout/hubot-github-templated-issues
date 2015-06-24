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

ect = require('ect')
githubot = require('githubot')
yaml = require('js-yaml')

class GithubTemplate
  options:
    repository: process.env.TEMPLATE_GITHUB_REPO
    ext: '.ect'

  env_error: 'environment variable is not configured: "TEMPLATE_GITHUB_REPO"'

  render: (path, data, callback) ->
    @template path, (error, content) ->
      return callback(error) if error

      try
        callback null, ect(root: {string: content}).render('string', data)
      catch error
        callback "Failed to render path '#{path}'"

  template: (path, callback) ->
    return callback(@env_error) unless @options.repository

    githubot.get "repos/#{@options.repository}/contents/#{path}#{@options.ext}", (content) =>
      switch content.encoding
        when 'base64'
          buf = new Buffer(content.content, 'base64')
          callback null, @parseDoc(buf.toString())

  repo_url: (callback) ->
    return callback(@env_error) unless @options.repository

    githubot.get "repos/#{@options.repository}", (content) ->
      callback null, content.html_url

  list: (path, callback) ->
    return callback(@env_error) unless @options.repository
    ext = @options.ext

    githubot.get "repos/#{@options.repository}/contents/#{path}", (content) ->
      callback null, content.map (i) ->
        i.path[..-ext.length-1] if i.path[-ext.length..] == ext

  info: (path, callback) ->
    return callback(@env_error) unless @options.repository

    githubot.get "repos/#{@options.repository}/contents/#{path}#{@options.ext}", (content) =>
      switch content.encoding
        when 'base64'
          buf = new Buffer(content.content, 'base64')
          callback null, @parseHelp(buf.toString())

  parseHelp: (string) ->
    help = ''
    for l in string.split("\n")
      break unless l[0] == '#' || l[0..1] == '//'
      help += l.replace(/^(#|\/\/)\s?/, "") + "\n"
    help

  parseDoc: (string) ->
    help = ''
    for l in string.split("\n")
      break unless l[0] == '#' || l[0..1] == '//'
      help += l + "\n"
    string[help.length..]


class GithubIssue
  options:
    repository: process.env.ISSUE_GITHUB_REPO || process.env.TEMPLATE_GITHUB_REPO

  env_error: 'environment variable is not configured: "ISSUE_GITHUB_REPO"'

  constructor: (@title, @body) ->

  create: (callback) ->
    return callback(@env_error) unless @options.repository

    params =
      title: @title
      body:  @body

    githubot.post "repos/#{@options.repository}/issues", params, (issue) ->
      callback null, issue

  repo_url: (callback) ->
    return callback(@env_error) unless @options.repository

    githubot.get "repos/#{@options.repository}", (content) ->
      callback null, content.html_url


module.exports = (robot) ->
  define_error_handler = (msg) ->
    githubot.logger.error = (error) ->
      msg.send "ERROR: #{error}"
      msg.robot.logger.error(error)

  robot.respond /issue\s+create\s+(\S+)\s+(.*)/i, (msg) ->
    error_handler = define_error_handler(msg)

    try
      data = yaml.safeLoad(msg.match.input.replace(/.*/, ''))
      template = new GithubTemplate

      template.render msg.match[1], data, (error, result) ->
        return error_handler(error) if error
        issue = new GithubIssue(msg.match[2], result)

        issue.create (error, created) ->
          return error_handler(error) if error
          msg.send "issue created\n#{created.html_url}"

    catch error
      error_handler 'Invalid YAML data'

  robot.respond /issue\s+(repo|repository)\s+from/i, (msg) ->
    error_handler = define_error_handler(msg)

    template = new GithubTemplate
    template.repo_url (error, url) ->
      return error_handler(error) if error
      msg.send url

  robot.respond /issue\s+(repo|repository)\s+to/i, (msg) ->
    error_handler = define_error_handler(msg)

    issue = new GithubIssue
    issue.repo_url (error, url) ->
      return error_handler(error) if error
      msg.send url

  robot.respond /issue\s+templates\s+(\S+)/i, (msg) ->
    error_handler = define_error_handler(msg)

    template = new GithubTemplate
    template.list msg.match[1], (error, paths) ->
      return error_handler(error) if error
      msg.send paths.join("\n")

  robot.respond /issue\s+template\s+(\S+)/i, (msg) ->
    error_handler = define_error_handler(msg)

    template = new GithubTemplate
    template.info msg.match[1], (error, info) ->
      return error_handler(error) if error
      msg.send info
