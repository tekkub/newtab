class @FirebaseStorage
  @initialize: ->
    console.log "FirebaseStorage.initialize"
    firebase = new Firebase("https://brilliant-torch-2365.firebaseio.com/bookmarks")
    FirebaseStorage.client = firebase


  constructor: (@bookmark) ->
    @record = FirebaseStorage.client.child @title()

    @record.once "value", (dataSnapshot) =>
      unless dataSnapshot.val()
        @record.set
          legacyID: @bookmark.title
          url: @bookmark.url
          color: Settings.COLORS[0]
          pinned: false

  read: (key, callback) ->
    @record.once "value", (dataSnapshot) =>
      if data = dataSnapshot.val()
        console.log "Received data", key, data
        callback data[key]


  save: (key, value) ->
    newdata = {}
    newdata[key] = value
    @record.update(newdata)

  title: ->
    @bookmark.title.replace /[ #\$\[\]\.]/g, "_"
