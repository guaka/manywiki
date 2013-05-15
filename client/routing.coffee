

@Router = new class extends Backbone.Router
  routes:
    ":page": "page"
    "": "home"

  home: ->
    @page 'Main Page'

  page: (page) ->
    console.log page
    @navigate page?.replace ' ', '_'


Meteor.startup ->
  Backbone.history.start pushState: true

