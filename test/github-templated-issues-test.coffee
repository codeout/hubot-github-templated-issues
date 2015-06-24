chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'
path = require 'path'

expect = chai.expect

Robot = require('hubot/src/robot')
TextMessage = require('hubot/src/message').TextMessage

template_github_repo = 'codeout/sandbox'
src = '../src/github-templated-issues'


describe 'github-templated-issues', ->

  #
  # TEMPLATE_GITHUB_REPO: good
  # ISSUE_GITHUB_REPO:    N/A
  #
  describe 'when TEMPLATE_GITHUB_REPO is configured', ->
    beforeEach ->
      @robot = new Robot(null, 'mock-adapter', false)

      @robot.adapter.on 'connected', =>
        delete require.cache[require.resolve(src)]
        process.env.TEMPLATE_GITHUB_REPO = template_github_repo
        delete process.env.ISSUE_GITHUB_REPO
        require(src)(@robot)
        @user = @robot.brain.userForId('1', name: 'codeout', room: '#myroom')
        @adapter = @robot.adapter
      @robot.run()

    afterEach ->
      @robot.shutdown()

    describe 'create', ->
      it 'opens issue', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /issue created.*\n.*http.*/m
          console.log strings[0], "\nverify manually"
          done()
        @adapter.receive new TextMessage(@user, "hubot issue create templated-issues/sample no title\nvars: [1, 2]")
      describe 'when template has no description', ->
        it 'opens issue', (done) ->
          @adapter.on 'send', (envelope, strings) ->
            expect(strings[0]).match /issue created.*\n.*http.*/m
            console.log strings[0], "\nverify manually"
            done()
          @adapter.receive new TextMessage(@user, "hubot issue create templated-issues/no_description no title\nvars: [1, 2]")

      describe 'when template repository is not found', ->
        it 'reports error', (done) ->
          @adapter.on 'send', (envelope, strings) ->
            expect(strings[0]).match /ERROR: .*Not Found/
            done()
          @adapter.receive new TextMessage(@user, "hubot issue create templated-issues/nothing no title\nvars: [1, 2]")

      describe 'when broken YAML is given', ->
        it 'reports error', (done) ->
          @adapter.on 'send', (envelope, strings) ->
            expect(strings[0]).match /ERROR: .*Invalid YAML/
            done()
          @adapter.receive new TextMessage(@user, "hubot issue create templated-issues/sample no title\nvars: [1, 2")

      describe 'when a variable is not given', ->
        it 'reports error', (done) ->
          @adapter.on 'send', (envelope, strings) ->
            expect(strings[0]).match /ERROR: .*Failed to render/
            done()
          @adapter.receive new TextMessage(@user, "hubot issue create templated-issues/sample no title")


    describe 'repo from', ->
      it 'shows the URL', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /http.*github/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue repo from")

    describe 'repo to', ->
      it 'shows the URL', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /http.*github/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue repo to")

    describe 'repo templates', ->
      it 'shows templates', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          for l in strings[0].split("\n")
            expect(l).match /^templated-issues\//
          done()
        @adapter.receive new TextMessage(@user, "hubot issue templates templated-issues")

      describe 'when template repository is not found', ->
        it 'reports error', (done) ->
          @adapter.on 'send', (envelope, strings) ->
            expect(strings[0]).match /ERROR: .*Not Found/
            done()
          @adapter.receive new TextMessage(@user, "hubot issue templates nothing")

    describe 'repo template', ->
      it 'shows template', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /This is a description line/m
          done()
        @adapter.receive new TextMessage(@user, "hubot issue template templated-issues/sample")

      describe 'when template repository is not found', ->
        it 'reports error', (done) ->
          @adapter.on 'send', (envelope, strings) ->
            expect(strings[0]).match /ERROR: .*Not Found/
            done()
          @adapter.receive new TextMessage(@user, "hubot issue template nothing")

  #
  # TEMPLATE_GITHUB_REPO: N/A
  # ISSUE_GITHUB_REPO:    N/A
  #
  describe 'when TEMPLATE_GITHUB_REPO is not configured', ->
    beforeEach ->
      @robot = new Robot(null, 'mock-adapter', false)

      @robot.adapter.on 'connected', =>
        delete require.cache[require.resolve(src)]
        delete process.env.TEMPLATE_GITHUB_REPO
        require(src)(@robot)
        @user = @robot.brain.userForId('1', name: 'codeout', room: '#myroom')
        @adapter = @robot.adapter
      @robot.run()

    afterEach ->
      @robot.shutdown()

    describe 'create', ->
      it 'reports error', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /ERROR: .*TEMPLATE_GITHUB_REPO/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue create templated-issues/sample no title\nvars: [1, 2]")

    describe 'repo from', ->
      it 'opens issue', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /ERROR: .*TEMPLATE_GITHUB_REPO/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue repo from")

    describe 'repo to', ->
      it 'opens issue', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /ERROR: .*ISSUE_GITHUB_REPO/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue repo to")

    describe 'repo templates', ->
      it 'reports error', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /ERROR: .*TEMPLATE_GITHUB_REPO/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue templates templated-issues")

    describe 'repo template', ->
      it 'reports error', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /ERROR: .*TEMPLATE_GITHUB_REPO/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue template templated-issues/sample")


  #
  # TEMPLATE_GITHUB_REPO: good
  # ISSUE_GITHUB_REPO:    bad
  #
  describe 'when ISSUE_GITHUB_REPO is wrong', ->
    beforeEach ->
      @robot = new Robot(null, 'mock-adapter', false)

      @robot.adapter.on 'connected', =>
        delete require.cache[require.resolve(src)]
        process.env.TEMPLATE_GITHUB_REPO = template_github_repo
        process.env.ISSUE_GITHUB_REPO = 'codeout/nothing'
        require(src)(@robot)
        @user = @robot.brain.userForId('1', name: 'codeout', room: '#myroom')
        @adapter = @robot.adapter
      @robot.run()

    afterEach ->
      delete process.env.ISSUE_GITHUB_REPO
      @robot.shutdown()

    describe 'create', ->
      it 'reports error', (done) ->
        @adapter.on 'send', (envelope, strings) ->
          expect(strings[0]).match /ERROR: .*Not Found/
          done()
        @adapter.receive new TextMessage(@user, "hubot issue create templated-issues/sample no title\nvars: [1, 2]")
