class @Storage
  @initialize: (dropboxCreds) ->
    DropboxStorage.initialize dropboxCreds
    FirebaseStorage.initialize

    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'


  constructor: (@bookmark) ->
    @db_record = new DropboxStorage @bookmark
    @fb_record = new FirebaseStorage @bookmark


  read: (key) ->
    @db_record.read key


  save: (key, value) ->
    @db_record.save key, value
