

apiCall = '/index.php?action=render&title='

# Global for debugging
@pages = []
@pagesObj = {}


hostname = (w) ->
  if typeof w is 'string'
    w
  else
    w.name

@fixLinks = (s, host) ->
  s = s.replace(new RegExp('<img(.*)src="(/.*)>', 'gi'), '<img$1src="http://' + host + '$2>')
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

  url = 'http://' + name + apiPath + '/api.php?callback=?'
  console.log url

  $.getJSON(url,
    format: 'json'
    action: 'parse'
    prop: 'text'
    page: Session.get 'currentTitle'
    redirects: true
  ).done (data) ->
    console.log data.parse.text
    pagesObj[name] = data.parse.text['*']
    Session.set 'changed', Meteor.uuid()


@updatePages = ->
  for w in wikis
    fetchPages w

Meteor.startup ->
  changePage location.hash.split('#')[1] or 'Main Page'
  Session.set 'activeTab', 'trashwiki.org'
  updatePages()


changePage = (p) ->
  Session.set 'currentTitle', p
  updatePages()

Template.dashboard.currentTitle = ->
  Session.get 'currentTitle'


Template.dashboard.pages = ->
  Session.get 'changed'
  pages = _.map (_.pairs pagesObj), (p) ->
    active: false
    emptyPage: false  # -1 isnt p[1].indexOf "There is currently no text in this page."
    name: p[0]
    content: new Handlebars.SafeString fixLinks p[1], p[0]
  _.sortBy pages, (x) -> x.name


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
