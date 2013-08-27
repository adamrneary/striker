describe('Striker', function() {
  var expect  = window.chai.expect;
  var Striker = window.Striker;

  it('exist', function() {
    expect(Striker).exist;
    expect(Striker.namespace).equal(window);
    expect(Striker.extend).a('function');
    expect(Striker.addAnalysis).a('function');
  });

  it('Striker.schemaMap has to be overrided', function() {
    expect(function() { Striker.schemaMap() }).throw(/Override this/);
  });

  describe('instance methods', function() {
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

    beforeEach(function() {
      periods  = new Collection([{ id: 'last-month' }, { id: 'this-month' }, { id: 'next-month' }]);
      channels = new Collection([{ id: 'channel1' }, { id: 'channel2' }]);

      Striker.schemaMap = function(key) {
        switch (key) {
          case 'period_id': return periods.models;
          case 'channel_id': return channels.models;
        }
      };

      striker  = new Reach();
    });

    it('maps `this.collections` with Striker.schemaMap', function() {
      expect(striker.collections).length(2);
      expect(striker.collections[0]).length(2);
      expect(striker.collections[1]).length(3);
    });

    it('defines lazy entries based on schema', function() {
      expect(striker.entries).length(6);
      striker.forEach(function(entry) {
        expect(entry.isLazy).true;
        expect(_.keys(entry.attributes)).length(2);
      });
    });

    it('#get returns entry based on schema', function() {
      var entry = striker.get('channel2', 'next-month');
      expect(entry instanceof Striker.Entry).true;
      expect(_.keys(entry.all())).length(4);
      expect(entry.get('actual')).undefined;
      expect(entry.get('plan')).equal(9);
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
  });
});
