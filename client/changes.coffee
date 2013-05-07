


# global for debugging
@changes = []

fetchChanges = (wiki) ->
  Meteor.http.get 'http://' + wiki + rcPath, (error, result) ->
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
  changes

