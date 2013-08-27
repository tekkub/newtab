class Settings
  @initialize: ->
    unless localStorage['db-version'] == '2'
      console.log 'Resetting localStorage'
      localStorage.clear()
      localStorage['db-version'] = '2'




  constructor: (@bookmark) ->
