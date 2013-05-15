

# Global for debugging
@pages = []
@pagesObj = {}


changePage = (p) ->
  Router.page p
  Session.set 'currentTitle', p
  updatePages()


hostname = (w) ->
  if typeof w is 'string'
    w
  else
    w.name

@fixLinks = (s, host) ->
  s.replace(new RegExp('<img(.+?)src="(/.*?)>', 'gi'), '<img$1src="http://' + host + '$2>')


@fetchPages = (wiki) ->
  apiPath = '/w'
  if typeof wiki is 'string'
    name = wiki
  else
    apiPath = wiki.apiPath
    name = wiki.name

  url = 'http://' + name + apiPath + '/api.php?callback=?'

  $.getJSON(url,
    format: 'json'
    action: 'parse'
    prop: 'text'
    page: Session.get 'currentTitle'
    redirects: true
  ).done (data) ->
    pagesObj[name] = data.parse.text['*']
    Session.set 'changed', Meteor.uuid()


@updatePages = ->
  for w in wikis
    fetchPages w

Meteor.startup ->
  console.log 'starting...'
  changePage location.hash.split('#')[1] or 'Main Page'
  Session.set 'activeTab', Session.get('activeTab') or 'couchwiki.org'
  updatePages()



Template.dashboard.currentTitle = ->
  Session.get 'currentTitle'


Template.dashboard.pages = ->
  Session.get 'changed'
  pages = _.map (_.pairs pagesObj), (p) ->
    active: false
    emptyPage: false
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
    newPage = e.toElement.href.split('/').slice(-1)[0]
    e.preventDefault()
    changePage newPage
    window.scrollTo 0, 0

  'click h1 a': (e) ->
    title = eventHref(e).split('#')[1]
    changePage title
    window.scrollTo 0, 0
    false

  'keydown #page': (evt) ->
    if evt.keyCode is 13
      changePage $('#page').val()
      $('#page').val ''

  'click #page': (evt) ->
    $('#page').val ''
