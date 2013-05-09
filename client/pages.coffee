

apiCall = '/index.php?action=render&title='

# Global for debugging
@changes = []
changesObj = {}


hostname = (w) ->
  if typeof w is 'string'
    w
  else
    w.name

@fixLinks = (s, host) ->
  s = s.replace(new RegExp('<img(.*)src="(/(files|en/images).*)">', 'gi'), '<img$1src="http://' + host + '$2">')
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
  changePage location.hash.split('#')[1] or 'Main Page'
  Session.set 'activeTab', 'trashwiki.org'
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
    emptyPage: -1 isnt p[1].indexOf "There is currently no text in this page."
    name: p[0]
    content: new Handlebars.SafeString fixLinks p[1], p[0]
  _.sortBy changes, (x) -> x.name


Template.dashboard.isActive = (page) ->
  Session.equals 'activeTab', this.name



eventHref = (e) ->
  if e.srcElement? then e.srcElement.href else e.currentTarget.href


Template.dashboard.events
  'click .nav-tabs a.enabled': (e) ->
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
