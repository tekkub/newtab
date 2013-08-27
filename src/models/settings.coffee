class Settings
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

  @initialize: ->
    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'


  @fetch: (bookmark) ->
    settings = new Settings bookmark
    settings.fetch()


  constructor: (@bookmark) ->


  default_data: ->
    {
      'id': @bookmark.id
      'link': @bookmark.url
    }


  hash: ->
    @bookmark.title


  fetch: ->
    return @default_data() if @hash() == ''

    raw = localStorage[@hash()]
    if raw
      data = JSON.parse(raw)
      data['id'] = @bookmark.id
      data
    else
      @fetchFromParse()
      @default_data()


  fetchFromParse: ->
    $.parse.get 'bookmarks', where: {objectId: @hash()}, (data) ->
      for entry in data.results
        console.log "Parse data received #{entry.objectId}", entry
        localStorage[entry.objectId] = JSON.stringify entry
        injectBookmark(@bookmark)


  save: (key, value) ->
    data = @fetch()
    data[key] = value

    delete data.id
    delete data.objectId
    delete data.createdAt
    delete data.updatedAt
    console.log "New data", data
    $.parse.post 'bookmarks', data, (json) =>
      console.log("Saved to parse", json)
      chrome.bookmarks.update(@bookmark.id, {title: json.objectId})
      localStorage[json.objectId] = JSON.stringify(data)
