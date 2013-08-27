class Settings
  @_settings = {}
  @find: (id) ->
    @_settings[id]
  @initialize: ->
    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'




  constructor: (@bookmark) ->
    Setting._settings[bookmark.id] = this
