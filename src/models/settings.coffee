class @Settings
  @COLORS = [
    "silver"
    "black"
    "purple"
    "blue"
    "green"
    "yellow"
    "orange"
    "red"
    "pink"
  ]

  constructor: (@bookmark) ->
    @storage = new Storage @bookmark


  read: (key, callback) ->
    @storage.read key, callback


  save: (key, value) ->
    @storage.set key, value
