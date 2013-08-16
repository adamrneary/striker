/* jshint undef: false */
describe('Striker', function() {
  var expect = chai.expect;

  it('exists', function() {
    expect(Striker).exists;
    expect(Striker.Collection).exists;
  });

  it('.getKeys', function() {
    expect(Striker.getKeys([1, 2, [1, 2], 4])).eql(['1,2,1,4', '1,2,2,4']);
    expect(Striker.getKeys([[1, 2], 2, [1, 2], [4, 5]])).eql([
      '1,2,1,4', '1,2,1,5', '1,2,2,4', '1,2,2,5', '2,2,1,4', '2,2,1,5', '2,2,2,4', '2,2,2,5']);
  });
});
