class Settings
  @_settings = {}
  @find: (id) ->
    @_settings[id]


  constructor: (@bookmark) ->
    Setting._settings[bookmark.id] = this
