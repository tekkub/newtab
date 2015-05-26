class @FirebaseStorage
  @initialize: ->
    # @firebase = new Firebase("https://brilliant-torch-2365.firebaseio.com/bookmarks")
    console.log "FirebaseStorage.initialize"


  constructor: (@bookmark) ->
    firebase = new Firebase("https://brilliant-torch-2365.firebaseio.com/bookmarks")
    @record = firebase.child @title()

    @record.once "value", (dataSnapshot) =>
      unless dataSnapshot.val()
        @record.set
          legacyID: @bookmark.title
          url: @bookmark.url
          color: Settings.COLORS[0]
          pinned: false

  read: (key) ->
    @record.get key


  save: (key, value) ->
    # @record.update('User ' + key + ' says ' + value)

  title: ->
    @bookmark.title.replace /[ #\$\[\]\.]/g, "_"
