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

  constructor: (@bookmark) ->
    @storage = new Storage @bookmark

    # rows = Settings.bookmarks.query
    #   legacyID: @bookmark.title
    # @record = rows[0]
    #
    # unless @record
    #   newData =
    #     legacyID: @bookmark.title
    #     url: @bookmark.url
    #     color: Settings.COLORS[0]
    #     pinned: false
    #   @record = Settings.bookmarks.insert newData


  read: (key, callback) ->
    @storage.read key, callback


  save: (key, value) ->
    @storage.set key, value
