ect = require('ect')

class GithubTemplate
  env_error: 'environment variable is not configured: "TEMPLATE_GITHUB_REPO"'

  constructor: (@githubot) ->

  options: ->
    repository: process.env.TEMPLATE_GITHUB_REPO
    ext: '.ect'

  render: (path, data, callback) ->
    @template path, (error, content) ->
      return callback(error) if error

      try
        callback null, ect(root: {string: content}).render('string', data)
      catch error
        callback "Failed to render path '#{path}'"

  template: (path, callback) ->
    return callback(@env_error) unless @options().repository

    @githubot.get "repos/#{@options().repository}/contents/#{path}#{@options().ext}", (content) =>
      switch content.encoding
        when 'base64'
          buf = new Buffer(content.content, 'base64')
          callback null, @parseDoc(buf.toString())

  repo_url: (callback) ->
    return callback(@env_error) unless @options().repository

    @githubot.get "repos/#{@options().repository}", (content) ->
      callback null, content.html_url

  list: (path, callback) ->
    return callback(@env_error) unless @options().repository
    ext = @options().ext

    @githubot.get "repos/#{@options().repository}/contents/#{path}", (content) ->
      callback null, content.map (i) ->
        i.path[..-ext.length-1] if i.path[-ext.length..] == ext

  info: (path, callback) ->
    return callback(@env_error) unless @options().repository

    @githubot.get "repos/#{@options().repository}/contents/#{path}#{@options().ext}", (content) =>
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


module.exports = GithubTemplate
