/* jshint undef: false */
describe('Striker', function() {
  var expect = chai.expect;

  it('exist', function() {
    expect(Striker).exist;
    expect(Striker.extend).a('function');
  });

  it('Striker.schemaMap has to be overrided', function() {
    expect(function() { Striker.schemaMap() }).throw(/Override this/);
  });

  describe('#get', function() {});
  describe('#update', function() {});
  describe('#flat', function() {});
  describe('#reverse', function() {});
});
