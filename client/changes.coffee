

rcPath = '/w/api.php?format=json&action=query&list=recentchanges&rcprop=user|title|comment|sizes'
url = "http://vegan.wiki.yt" + rcPath

wikis =
  'vegan.wiki.yt': null
#  name: 'velo.wiki.yt', changes: null
#  name: 'wiki.yt', changes: null



fetchChanges = (wiki) ->
  Meteor.http.get url, (error, result) ->
    console.log error
    json = JSON.parse result.content
    rc = json.query.recentchanges
    console.log rc
    wikis[wiki] = rc
    Session.set 'changed', Meteor.uuid()


Meteor.startup ->
  for w of wikis
    console.log w
    fetchChanges w


Template.changes.changes = ->
  Session.get 'changed'
  wikis['vegan.wiki.yt']


