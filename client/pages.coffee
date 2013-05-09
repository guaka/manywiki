

apiCall = '/index.php?action=render&title='

# Global for debugging
@changes = []
changesObj = {}


hostname = (w) ->
  if typeof w is 'string'
    w
  else
    w.name

@fixLinks = (s) ->
  s = s.replace(new RegExp('<img.*>', 'gi'), '#')
  for w in wikis
    s = s.replace(new RegExp('http://' + hostname(w) + '/en/', 'gi'), '#')
  s

@fetchPages = (wiki) ->
  apiPath = '/w'
  if typeof wiki is 'string'
    name = wiki
  else
    apiPath = wiki.apiPath
    name = wiki.name

  url = 'http://' + name + apiPath + apiCall + Session.get 'currentTitle'
  Meteor.http.get url, (error, result) ->
    console.log error if error
    changesObj[name] = result.content
    Session.set 'changed', Meteor.uuid()


@updateChanges = ->
  for w in wikis
    fetchPages w

Meteor.startup ->
  changePage 'Main Page'
  Session.set 'activeTab', 'hitchwiki.org'
  updateChanges()


changePage = (p) ->
  Session.set 'currentTitle', p
  updateChanges()

Template.dashboard.currentTitle = ->
  Session.get 'currentTitle'


Template.dashboard.changes = ->
  Session.get 'changed'
  changes = _.map (_.pairs changesObj), (p) ->
    active: false
    name: p[0]
    content: new Handlebars.SafeString fixLinks p[1]
  _.sortBy changes, (x) -> x.name


Template.dashboard.isActive = (page) ->
  Session.equals 'activeTab', this.name



eventHref = (e) ->
  if e.srcElement? then e.srcElement.href else e.currentTarget.href

Template.dashboard.events
  'click #search': ->
    # updateChanges()

  'click .nav-tabs a': (e) ->
    tab = eventHref(e).split('#tab-')[1]
    Session.set 'activeTab', tab


  'click .content a': (e) ->
    title = eventHref(e).split('#')[1]
    changePage title
    window.scrollTo 0, 0

  'click h1 a': (e) ->
    title = eventHref(e).split('#')[1]
    changePage title
    window.scrollTo 0, 0

  'keydown #page': (evt) ->
    if evt.keyCode is 13
      changePage $('#page').val()
      $('#page').val ''

  'click #page': (evt) ->
    $('#page').val ''
