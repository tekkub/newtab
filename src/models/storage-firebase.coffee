class @FirebaseStorage
  @initialize: ->
    # @firebase = new Firebase("https://brilliant-torch-2365.firebaseio.com/bookmarks")


  constructor: (@bookmark) ->
    firebase = new Firebase("https://brilliant-torch-2365.firebaseio.com/bookmarks")
    @record = firebase.child @title()

    @record.on "value", (dataSnapshot) =>
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
