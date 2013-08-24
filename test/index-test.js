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

  describe('#get', function() {});
  describe('#update', function() {});
  describe('#flat', function() {});
  describe('#reverse', function() {});
});
