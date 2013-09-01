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

    dropbox.authenticate interactive: false, (err, client) ->
      if err
        alert "Error authenticating: #{err}"
        return false

      if client.isAuthenticated()
        console.log 'Cached auth loaded'
        Settings.finishAuth client
      else
        console.log 'Triggering interactive login'
        dropbox.authenticate (err, client) ->
          if err
            alert "Error authenticating: #{err}"
            return false

          if client.isAuthenticated()
            Settings.finishAuth client
          else
            alert "Dropbox is not authed!"
            return false


  @finishAuth: (client) ->
    datastoreManager = client.getDatastoreManager()
    console.log 'Requesting datastore'
    datastoreManager.openDefaultDatastore (error, datastore) ->
      if error
        alert "Error opening default datastore: #{error}"
        return false

      console.log 'dropbox datastore loaded'

      Settings.datastore = datastore
      Settings.bookmarks = datastore.getTable 'bookmarks-dev'

      Settings._initCallback()


  constructor: (@bookmark) ->
    rows = Settings.bookmarks.query
      legacyID: @bookmark.title
    @record = rows[0]


  read: (key) ->
    @record.get key


  save: (key, value) ->
    @record.set key, value
