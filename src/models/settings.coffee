class Settings
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
