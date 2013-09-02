class @Settings
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

  @initialize: (dropboxCreds) ->
    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'

    dropbox = new Dropbox.Client dropboxCreds
    Settings.client = dropbox
    dropbox.onError.addListener (err) ->
      console.log err.response.error
      chrome.browserAction.setTitle title: 'Dropbox error'
      chrome.browserAction.setBadgeText text: '!'
      chrome.browserAction.setBadgeBackgroundColor color: '#F00'
      alert 'Dropbox error!  See javascript console for details.'

    chrome.browserAction.setTitle title: 'Signing in...'
    chrome.browserAction.setBadgeText text: '...'
    chrome.browserAction.setBadgeBackgroundColor color: '#00F'

    dropbox.authenticate interactive: false, (err, client) ->
      if err
        chrome.browserAction.setTitle title: 'Dropbox error'
        chrome.browserAction.setBadgeText text: '!'
        chrome.browserAction.setBadgeBackgroundColor color: '#F00'
        alert "Error authenticating: #{err}"
        return false

      if client.isAuthenticated()
        console.log 'Cached auth loaded'
        Settings.finishAuth client
      else
        console.log 'Triggering interactive login'
        dropbox.authenticate (err, client) ->
          if err
            chrome.browserAction.setTitle title: 'Dropbox error'
            chrome.browserAction.setBadgeText text: '!'
            chrome.browserAction.setBadgeBackgroundColor color: '#F00'
            alert "Error authenticating: #{err}"
            return false

          if client.isAuthenticated()
            Settings.finishAuth client
          else
            chrome.browserAction.setTitle title: 'Not signed in'
            chrome.browserAction.setBadgeText text: '?'
            chrome.browserAction.setBadgeBackgroundColor color: '#FF0'
            alert "Dropbox is not authed!"
            return false


  @finishAuth: (client) ->
    console.log 'Requesting datastore'
    chrome.browserAction.setTitle title: 'Syncing'
    chrome.browserAction.setBadgeText text: '<=>'

    datastoreManager = client.getDatastoreManager()
    datastoreManager.openDefaultDatastore (error, datastore) ->
      if error
        chrome.browserAction.setTitle title: 'Dropbox error'
        chrome.browserAction.setBadgeText text: '!'
        chrome.browserAction.setBadgeBackgroundColor color: '#F00'
        alert "Error opening default datastore: #{error}"
        return false

      console.log 'Dropbox datastore loaded'
      chrome.browserAction.setTitle title: 'Signed in'
      chrome.browserAction.setBadgeText text: ''
      client.getAccountInfo (err, data) ->
        chrome.browserAction.setTitle
          title: "Signed in as #{data.name} <#{data.email}>"

      Settings.datastore = datastore
      Settings.bookmarks = datastore.getTable 'bookmarks-dev'


  constructor: (@bookmark) ->
    rows = Settings.bookmarks.query
      legacyID: @bookmark.title
    @record = rows[0]

    unless @record
      newData =
        legacyID: @bookmark.title
        url: @bookmark.url
        color: Settings.COLORS[0]
        pinned: false
      @record = Settings.bookmarks.insert newData


  read: (key) ->
    @record.get key


  save: (key, value) ->
    @record.set key, value
