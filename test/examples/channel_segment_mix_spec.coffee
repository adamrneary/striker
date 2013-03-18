Periods           = require('collections/periods')
Channels          = require('collections/channels')
Segments          = require('collections/segments')
Customers         = require('collections/customers')
ChannelSegmentMix = require('collections/channel_segment_mix')

describe 'channel/segment mix', ->
  beforeEach ->
    stubCurrentDate '2012-02-14'
    app.periods  = new Periods [
      {id: 'last-month',    first_day: '2012-01-01'},
      {id: 'this-month',    first_day: '2012-02-01'},
      {id: 'next-month',    first_day: '2012-03-01'},
      {id: 'two-years-ago', first_day: '2010-02-01'}
    ]
    app.segments  = new Segments [
      {id: 'segment1'},
      {id: 'segment2'}
    ]
    app.channels  = new Channels [
      {id: 'channel1'},
      {id: 'channel2'}
    ]
    app.customers = new Customers [
      {id: 'customer1', channel_id: 'channel1', segment_id: 'segment1'},
      {id: 'customer2', channel_id: 'channel1', segment_id: 'segment2'},
      {id: 'customer3', channel_id: 'channel2', segment_id: 'segment1'},
      {id: 'customer4', channel_id: 'channel2', segment_id: 'segment2'}
    ]
    spyOn(app.customers, 'revenue').andCallFake (periodId) ->
      switch periodId
        when 'last-month'
          customer1: {actual: 100}
          customer2: {actual: 200}
          customer3: {actual: 300}
          customer4: {actual: 400}
        when 'this-month'
          customer1: {actual: 500}
          customer2: {actual: 600}
          customer3: {actual: 700}
          customer4: {actual: 800}

    app.channelSegmentMix = new ChannelSegmentMix [
      {period_id: 'last-month', channel_id: 'channel1', segment_id: 'segment1', distribution: 0.60},
      {period_id: 'last-month', channel_id: 'channel1', segment_id: 'segment2', distribution: 0.40},
      {period_id: 'last-month', channel_id: 'channel2', segment_id: 'segment1', distribution: 0.80},
      {period_id: 'last-month', channel_id: 'channel2', segment_id: 'segment2', distribution: 0.20},
      {period_id: 'this-month', channel_id: 'channel1', segment_id: 'segment1', distribution: 0.65},
      {period_id: 'this-month', channel_id: 'channel1', segment_id: 'segment2', distribution: 0.35},
      {period_id: 'this-month', channel_id: 'channel2', segment_id: 'segment1', distribution: 0.90},
      {period_id: 'this-month', channel_id: 'channel2', segment_id: 'segment2', distribution: 0.10},
      {period_id: 'next-month', channel_id: 'channel1', segment_id: 'segment1', distribution: 0.70},
      {period_id: 'next-month', channel_id: 'channel1', segment_id: 'segment2', distribution: 0.30},
      {period_id: 'next-month', channel_id: 'channel2', segment_id: 'segment1', distribution: 1.00},
      {period_id: 'next-month', channel_id: 'channel2', segment_id: 'segment2', distribution: 0.00}
    ]

  # channel segment mix is:
  #   for each channel, an array of segments with:
  #     actual => Float with percentage of:
  #                   revenue for that segment
  #                 / total channel revenue
  #     plan   => User-entered plan value
  #
  # Note: sum of segment mixes across each channel must sum to 100%
  #   (true for both plan and actual)
  describe 'channel segment mix', ->
    beforeEach ->
      @channel = app.channels.get('channel1')

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@channel.segmentMix 'last-month').toEqual
          segment1: {actual: (100/(100+200)), plan: 0.60}
          segment2: {actual: (200/(100+200)), plan: 0.40}
        expect(@channel.segmentMix 'this-month').toEqual
          segment1: {actual: (500/(500+600)), plan: 0.65}
          segment2: {actual: (600/(500+600)), plan: 0.35}
        expect(@channel.segmentMix 'next-month').toEqual
          segment1: {                         plan: 0.70}
          segment2: {                         plan: 0.30}

      it 'returns an array with period ids', ->
        result = @channel.segmentMix ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # segment channel mix is:
  #   for each segment, an array of channels with:
  #     actual =>   Float with percentage of:
  #                   revenue for that channel
  #                 / total segment revenue
  #     plan   =>   User-entered plan value
  #
  # Note: the distribution field in the user-entered values is relative to the
  #   channel, and therefore it should not be expected that the sum of
  #   distributions add to 100% for a segment.
  describe 'segment channel mix', ->
    beforeEach ->
      @segment = app.segments.get('segment1')

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@segment.channelMix 'last-month').toEqual
          channel1: {actual: (100/(100+300)), plan: 0.60}
          channel2: {actual: (300/(100+300)), plan: 0.80}
        expect(@segment.channelMix 'this-month').toEqual
          channel1: {actual: (500/(500+700)), plan: 0.65}
          channel2: {actual: (700/(500+700)), plan: 0.90}
        expect(@segment.channelMix 'next-month').toEqual
          channel1: {                         plan: 0.70}
          channel2: {                         plan: 1.00}

      it 'returns an array with period ids', ->
        result = @segment.channelMix ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3
