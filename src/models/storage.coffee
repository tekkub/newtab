class @Storage
  @initialize: (dropboxCreds) ->
    console.log "Storage.initialize"
    LocalstorageStorage.initialize()
    FirebaseStorage.initialize()
    DropboxStorage.initialize dropboxCreds


  constructor: (@bookmark) ->
    @ls_record = new LocalstorageStorage @bookmark
    @db_record = new DropboxStorage @bookmark
    @fb_record = new FirebaseStorage @bookmark


  read: (key, callback) ->
    @ls_record.read key, (value) =>
      callback value

    @fb_record.read key, (value) =>
      @ls_record.save key, value
      callback value


  save: (key, value) ->
    @db_record.save key, value
    @ls_record.save key, value
    @fb_record.save key, value
