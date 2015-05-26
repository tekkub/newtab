class @LocalstorageStorage
  @initialize: ->
    console.log "LocalstorageStorage.initialize"

    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'


  constructor: (@bookmark) ->


  read: (key, callback) ->
    callback @raw_data()[key]


  save: (key, value) ->
    @update key, value

  set: (data) ->
    localStorage[@ls_key()] = JSON.stringify data

  update: (key, value) ->
    data = @raw_data()
    data[key] = value
    @set data

  ls_key: ->
    "bookmark-#{@bookmark.title}"

  raw_data: ->
    if stored_data = localStorage[@ls_key()]
      JSON.parse stored_data
    else
      {}
