

rcPath = '/w/api.php?format=json&action=query&list=recentchanges&rcprop=user|title|comment|sizes'
url = "http://vegan.wiki.yt" + rcPath

@wikis = [
  'vegan.wiki.yt', 'velo.wiki.yt',  'wiki.yt',
  'couchwiki.org', 'trashwiki.org', 'sharewiki.org',
  'hitchwiki.org'
]

@changes = []

fetchChanges = (wiki) ->
  Meteor.http.get url, (error, result) ->
    console.log error
    json = JSON.parse result.content
    rc = json.query.recentchanges
    console.log rc
    changes.push
      name: wiki
      rc: rc
    Session.set 'changed', Meteor.uuid()


Meteor.startup ->
  for w in wikis
    console.log w
    fetchChanges w



Template.changes.changes = ->
  Session.get 'changed'
  changes

