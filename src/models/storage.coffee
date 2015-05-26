class @Storage
  @initialize: (dropboxCreds) ->
    console.log "Storage.initialize"
    FirebaseStorage.initialize()
    DropboxStorage.initialize dropboxCreds

    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'


  constructor: (@bookmark) ->
    @db_record = new DropboxStorage @bookmark
    @fb_record = new FirebaseStorage @bookmark


  read: (key, callback) ->
    console.log "Requesting FB data", key
    @fb_record.read key, callback


  save: (key, value) ->
    @db_record.save key, value
