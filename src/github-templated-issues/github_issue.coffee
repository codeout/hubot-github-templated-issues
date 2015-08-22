class GithubIssue
  options: ->
    repository: process.env.ISSUE_GITHUB_REPO || process.env.TEMPLATE_GITHUB_REPO

  env_error: 'environment variable is not configured: "ISSUE_GITHUB_REPO"'

  constructor: (@githubot, @title, @body) ->

  create: (callback) ->
    return callback(@env_error) unless @options().repository

    params =
      title: @title
      body:  @body

    @githubot.post "repos/#{@options().repository}/issues", params, (issue) ->
      callback null, issue

  repo_url: (callback) ->
    return callback(@env_error) unless @options().repository

    @githubot.get "repos/#{@options().repository}", (content) ->
      callback null, content.html_url


module.exports = GithubIssue
