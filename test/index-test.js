describe('Striker', function() {
  var expect  = window.chai.expect;
  var Striker = window.Striker;

  var striker, periods, channels;
  var Collection = Backbone.Collection.extend({});

  var fakeValues = {
    'channel1-last-month' : { actual: 5, plan: 4 },
    'channel1-this-month' : { actual: 3, plan: 8 },
    'channel1-next-month' : { actual: undefined, plan: 7 },
    'channel2-last-month' : { actual: 2, plan: 3 },
    'channel2-this-month' : { actual: 6, plan: 2 },
    'channel2-next-month' : { actual: undefined, plan: 9 }
  };

  var Reach = Striker.extend({
    schema: ['channel_id', 'period_id'],
    calculate: function(channelId, periodId) {
      return fakeValues[channelId + '-' + periodId];
    }
  });

  Striker.schemaMap = function(key) {
    switch (key) {
      case 'period_id': return periods.models;
      case 'channel_id': return channels.models;
    }
  };

  beforeEach(function() {
    periods  = new Collection([{ id: 'last-month' }, { id: 'this-month' }, { id: 'next-month' }]);
    channels = new Collection([{ id: 'channel1' }, { id: 'channel2' }]);
    striker  = new Reach();
  });

  it('exist', function() {
    expect(Striker).exist;
    expect(Striker.namespace).equal(window);
    expect(Striker.extend).a('function');
    expect(Striker.addAnalysis).a('function');
  });

  it('maps `this.collections` with Striker.schemaMap', function() {
    expect(striker.collections).length(2);
    expect(striker.collections[0]).length(2);
    expect(striker.collections[1]).length(3);
  });

  it('defines lazy entries based on schema', function() {
    expect(striker.entries).length(6);
    expect(_.size(striker.values)).equal(2);
    striker.forEach(function(entry, index) {
      if (index === 0) return;
      expect(entry.isLazy).true;
      expect(_.size(entry.attributes)).equal(2);
    });
  });

  it('#get returns entry based on schema and this.values', function() {
    var entry = striker.get('channel2', 'next-month');
    expect(_.size(striker.values)).equal(2);
    expect(_.size(entry.all())).equal(4);
    expect(entry.actual).undefined;
    expect(entry.plan).equal(9);
  });

  it('#reverseValues - returns reversed this.values', function() {
    var values = striker.reverseValues();
    expect(_.size(values)).equal(3);
    expect(values['last-month']).exist;
    expect(values['this-month'].channel1.plan).equal(8);
  });

  it('#update force lazy `change` event', function(done) {
    var counter = 0;
    striker.get('channel2', 'next-month').all();
    striker.on('change', function() {
      expect(++counter).equal(1);
    });

    striker.update('channel1', 'this-month'); // lazy
    striker.update('channel1', 'next-month'); // lazy
    striker.update('channel2', 'next-month'); // real
    if (counter > 0) done();
  });

  it('has underscore\'s methods', function() {
    expect(striker.isEmpty()).false;
    expect(striker.size()).equal(6);

    var totalPlan = striker.reduce(function(memo, entry) {
      return memo += entry.get('plan');
    }, 0);
    expect(totalPlan).equal(4 + 8 + 7 + 3 + 2 + 9);

    var entry = striker.get('channel1', 'this-month');
    expect(striker.include(entry)).true;
    expect(striker.indexOf(entry)).equal(1);
  });

  it('handles `remove` event', function() {
    periods.remove([periods.get('last-month')]);
    expect(striker.size()).equal(4);
    expect(striker.get('channel2', 'last-month')).undefined;
    expect(striker.get('channel2', 'this-month')).exist;

    channels.remove([channels.get('channel1')]);
    expect(striker.size()).equal(2);
    expect(striker.get('channel1', 'this-month')).undefined;
    expect(striker.get('channel2', 'this-month')).exist;
  });

  it('handles `add` event', function() {
    periods.add([{ id: 'two-years-ago' }]);

    expect(striker.size()).equal(8);
    expect(striker.get('channel2', 'this-month')).exist;
    expect(striker.get('channel2', 'two-years-ago')).exist;
  });
});
