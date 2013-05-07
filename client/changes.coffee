@wikis = [
  'vegan.wiki.yt', 'velo.wiki.yt',  'wiki.yt',
  'couchwiki.org', 'trashwiki.org', 'sharewiki.org',
  { wiki: 'hitchwiki.org', apiPath: '/en' },
]


apiCall = '/api.php?format=json&action=query&list=recentchanges&rcprop=user|title|ids|comment|sizes|timestamp'


# global for debugging
@changes = []


fetchChanges = (wiki) ->
  apiPath = '/w'
  if typeof wiki isnt 'string'
    apiPath = wiki.apiPath
    wiki = wiki.wiki

  Meteor.http.get 'http://' + wiki + apiPath + apiCall, (error, result) ->
    console.log error
    json = JSON.parse result.content
    rc = json.query.recentchanges
    console.log rc
    changes.push
      name: wiki
      rc: _.map(rc, (x) ->
        x.link = 'http://' + wiki + '/en/' + x.title
        x
      )

    Session.set 'changed', Meteor.uuid()


Meteor.startup ->
  for w in wikis
    console.log w
    fetchChanges w



Template.changes.changes = ->
  Session.get 'changed'
  _.sortBy changes, (x) -> x.name

