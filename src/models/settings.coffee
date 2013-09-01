class Settings
  @COLORS = [
    'silver'
    'black'
    'purple'
    'blue'
    'green'
    'yellow'
    'orange'
    'red'
    'pink'
  ]

  @initialize: (dropboxCreds, callback) ->
    Settings._initCallback = callback
    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'

    dropbox = new Dropbox.Client dropboxCreds
    dropbox.authenticate @finishAuth


  @finishAuth: (error, client) ->
    if error
      alert "Error authenticating: #{error}"
      return false

    datastoreManager = client.getDatastoreManager()
    datastoreManager.openDefaultDatastore (error, datastore) ->
      if error
        alert "Error opening default datastore: #{error}"
        return false

      console.log 'dropbox datastore loaded', datastore

      Settings.datastore = datastore
      Settings.bookmarks = datastore.getTable 'bookmarks-dev'

      Settings._initCallback()


  @fetch: (bookmark) ->
    settings = new Settings bookmark
    settings.fetch()


  constructor: (@bookmark) ->


  default_data: ->
    {
      'id': @bookmark.id
      'link': @bookmark.url
    }


  hash: ->
    @bookmark.title


  fetch: ->
    return @default_data() if @hash() == ''

    raw = localStorage[@hash()]
    if raw
      data = JSON.parse(raw)
      data['id'] = @bookmark.id
      data
    else
      @fetchFromParse()
      @default_data()


  fetchFromDropbox: ->
    rows = Settings.bookmarks.query
      legacyID: @hash()

    if rows[1]
      alert "Duplicate entries found for '#{@hash()}'"
      nil
    else
      rows[0]


  fetchFromParse: ->
    $.parse.get 'bookmarks', where: {objectId: @hash()}, (data) ->
      for entry in data.results
        console.log "Parse data received #{entry.objectId}", entry
        localStorage[entry.objectId] = JSON.stringify entry
        injectBookmark(@bookmark)


  read: (key) ->
    db = @fetchFromDropbox()
    db.get key


  save: (key, value) ->
    db = @fetchFromDropbox()
    db.set key, value
