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

    var Reach = Striker.extend({
      schema: ['channel_id', 'period_id']
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

    it('has default options', function() {
      expect(striker.lazy).true;
    });

    it('maps `this.collections` with Striker.schemaMap', function() {
      expect(striker.collections).length(2);
      expect(striker.collections[0]).length(2);
      expect(striker.collections[1]).length(3);
    });

    it('defines lazy entries based on schema', function() {
      expect(striker.entries).length(6);
      var entry = _.find(striker.entries, function(entry) {
        return entry.channel_id === 'channel2' && entry.period_id === 'this-month';
      });
      expect(entry).exist;
      expect(_.keys(entry)).length(2, 'it does not define addition attributes');
    });
  });
});
