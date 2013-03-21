beforeEach ->
  window.app = {}

window.stubCurrentDate = (date) ->
  spyOn(moment.fn, 'startOf').andReturn moment(date)
