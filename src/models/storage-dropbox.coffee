class @DropboxStorage
  @initialize: (dropboxCreds) ->
    dropbox = new Dropbox.Client dropboxCreds
    DropboxStorage.client = dropbox
    dropbox.onError.addListener (err) ->
      console.log "Dropbox error", err
      BrowserAction.setError 'Dropbox error'
      # alert 'Dropbox error!  See javascript console for details.'

    BrowserAction.setSignin

    dropbox.authenticate interactive: false, (err, client) ->
      if err
        BrowserAction.setError 'Dropbox error'
        alert "Error authenticating: #{err}"
        return false

      if client.isAuthenticated()
        console.log 'Cached auth loaded'
        DropboxStorage.finishAuth client
      else
        console.log 'Triggering interactive login'
        dropbox.authenticate (err, client) ->
          if err
            BrowserAction.setError 'Dropbox error'
            alert "Error authenticating: #{err}"
            return false

          if client.isAuthenticated()
            DropboxStorage.finishAuth client
          else
            BrowserAction.setNotSignedIn
            alert "Dropbox is not authed!"
            return false


  @finishAuth: (client) ->
    console.log 'Requesting datastore'
    BrowserAction.setSyncing

    datastoreManager = client.getDatastoreManager()
    datastoreManager.openDefaultDatastore (error, datastore) ->
      if error
        BrowserAction.setError 'Dropbox error'
        alert "Error opening default datastore: #{error}"
        return false

      console.log 'Dropbox datastore loaded'
      DropboxStorage.setDatastore datastore

      DropboxStorage.onSyncStatusChanged()
      datastore.recordsChanged.addListener DropboxStorage.onSyncStatusChanged
      datastore.syncStatusChanged.addListener DropboxStorage.onSyncStatusChanged


  @setDatastore: (datastore) ->
    DropboxStorage.datastore = datastore
    DropboxStorage.bookmarks = datastore.getTable 'bookmarks-dev'


  @onSyncStatusChanged: ->
    if DropboxStorage.datastore.getSyncStatus().uploading
      BrowserAction.setSyncing
    else
      BrowserAction.clear
      DropboxStorage.client.getAccountInfo (err, data) ->
        chrome.browserAction.setTitle
          title: "Signed in as #{data.name} <#{data.email}>"


  constructor: (@bookmark) ->
    rows = DropboxStorage.bookmarks.query
      legacyID: @bookmark.title
    @record = rows[0]

    # unless @record
    #   newData =
    #     legacyID: @bookmark.title
    #     url: @bookmark.url
    #     color: Settings.COLORS[0]
    #     pinned: false
    #   @record = DropboxStorage.bookmarks.insert newData


  read: (key) ->
    @record.get key


  save: (key, value) ->
    # @record.set key, value
