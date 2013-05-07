

apiCall = '/api.php?format=json&action=query&list=recentchanges&rcprop=user|title|ids|comment|sizes|timestamp'


# global for debugging
@changes = []
changesObj = {}

@fetchChanges = (wiki) ->
  apiPath = '/w'
  if typeof wiki is 'string'
    name = wiki
  else
    apiPath = wiki.apiPath
    name = wiki.name


  Meteor.http.get 'http://' + name + apiPath + apiCall, (error, result) ->
    console.log error if error
    json = JSON.parse result.content
    rc = json.query.recentchanges

    changesObj[name] = _.map(rc, (x) ->
      x.link = 'http://' + wiki + '/en/' + x.title
      x
    )
    Session.set 'changed', Meteor.uuid()



updateChanges = ->
  for w in wikis
    fetchChanges w


Meteor.startup ->
  updateChanges()

Meteor.setInterval updateChanges, 90 * 1000 #ms


Template.changes.changes = ->
  Session.get 'changed'
  changes = _.map (_.pairs changesObj), (p) ->
    name: p[0]
    rc: p[1]
  _.sortBy changes, (x) -> x.name

