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
    dropbox.onError.addListener (err) ->
      console.log err.response.error
      alert 'Dropbox error!  See javascript console for details.'

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

      console.log 'dropbox datastore loaded'

      Settings.datastore = datastore
      Settings.bookmarks = datastore.getTable 'bookmarks-dev'

      Settings._initCallback()


  constructor: (@bookmark) ->


  fetchFromDropbox: ->
    rows = Settings.bookmarks.query
      legacyID: @bookmark.title

    if rows[1]
      alert "Duplicate entries found for '#{@bookmark.title}'"
      nil
    else
      rows[0]


  read: (key) ->
    db = @fetchFromDropbox()
    db.get key


  save: (key, value) ->
    db = @fetchFromDropbox()
    db.set key, value
