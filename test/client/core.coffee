# describe "Tablestakes API ", ->
#
#   table = new window.TableStakes
#
#   it 'window.tablestakes is function', (done) ->
#     assert window.TableStakes
#     assert typeof window.TableStakes is 'function'
#     done()
#
#   it 'constructor', (done) ->
#     assert table
#     done()
#
#   it 'table options', (done) ->
#     typeof table.filterCondition is 'object'
#     table.filterCondition is 'd3_Map'
#     typeof table.core is 'object'
#     table.core is 'core'
#     typeof table.events is 'object'
#     table.events is 'events'
#     typeof table.utils is 'object'
#     table.utils is 'utils'
#     done()
#
#   it 'render', (done) ->
#     assert typeof table.render is 'function'
#     assert table.render
#     done()
#
#   it 'update', (done) ->
#     assert typeof table.update is 'function'
#     assert table.update
#     done()
#
#   it 'update with argument', (done) ->
#     d3.select(table.get('el'))
#       .datum(table.gridFilteredData)
#       .call( (selection) => assert table.update selection )
#     done()
#
#   it 'dispatchManualEvent', (done) ->
#     assert typeof table.dispatchManualEvent is 'function'
#     assert table.dispatchManualEvent
#     done()
#
#   it 'setID', (done) ->
#     assert typeof table.setID is 'function'
#     assert table.setID
#     done()
#
#   # it 'attributes options', (done) ->
#   #   assert typeof table.attributes is 'object'
#   #   assert table.attributes.reorder_dragging is false
#   #   assert table.attributes.nested is false
#   #   assert table.attributes.resizable is false
#   #   assert table.attributes.sortable is false
#   #   done()
#   #
#   # it 'attributes reorder_dragging', (done) ->
#   #   table.reorder_dragging(true)
#   #   assert table.attributes.reorder_dragging is true
#   #   done()
#   #
#   # it 'attributes nested', (done) ->
#   #   table.nested(true)
#   #   assert table.attributes.nested is true
#   #   done()
#   #
#   # it 'attributes resizable', (done) ->
#   #   table.resizable(true)
#   #   assert table.attributes.resizable is true
#   #   done()
#   #
#   # it 'table.set(testdata) and table.get(testdata)', (done) ->
#   #   table.attributes = {resizable: false}
#   #   assert table.set('resizable', true)
#   #   assert table.get('resizable') is true
#   #   done()
#   #
#   # it 'table.is(testdata)', (done) ->
#   #   table.attributes = {resizable: true}
#   #   assert table.is('resizable') is true
#   #   done()
#
#   #it 'table.margin(testdata)', (done) ->
#     #testHash =
#       #top: 40
#       #right: 10
#       #bottom: 30
#       #left: 50
#     #assert table.margin(testHash) is table
#     #assert table.margin()['top'] is 40
#     #assert table.margin()['right'] is 10
#     #assert table.margin()['bottom'] is 30
#     #assert table.margin()['left'] is 50
#     #done()
#
#   #it 'table.sortable is true', (done) ->
#     #assert typeof table.sortable is 'function'
#     #assert table.sortable(true)
#     #done()
#
#   #it 'setFilter', (done) ->
#     #assert typeof table.setFilter is 'function'
#     #assert table.setFilter table.gridFilteredData[0], table.filterCondition
#     #done()
#
#   #it 'filter', (done) ->
#     #assert typeof table.filter is 'function'
#     #assert table.filter 'key', 'S'
#     #assert table.filterCondition.get('key') is 'S'
#     #done()
#
# #describe "Table: test function", ->
#   #table = new window.TableStakes
#   #it 'editable', (done)->
#     #assert table.editable(true)
#     #done()
#
#   #it 'isDeletable', (done)->
#     #assert table.isDeletable(true)
#     #done()
#
#   #it 'nested', (done)->
#     #assert table.nested(true)
#     #done()
#
#   #it 'boolean', (done)->
#     #assert table.boolean(true)
#     #done()
#
#   #it 'hierarchy_dragging', (done)->
#     #assert table.hierarchy_dragging(true)
#     #done()
#
#   #it 'resizable', (done)->
#     #assert table.resizable(true)
#     #done()
#
#   #it 'reorder_dragging', (done)->
#     #assert table.reorder_dragging(true)
#     #done()
#
# describe "Events", ->
#   event = window.TableStakesLib.Events
#
#   it 'window.TableStakesLib.Events is function', (done)->
#     assert typeof window.TableStakesLib.Events is 'function'
#     assert window.TableStakesLib.Events
#     done()
#
#   it 'events constructor', (done)->
#     assert event
#     done()
# #console.log 'cofeelint', coffeelint.lint("")
