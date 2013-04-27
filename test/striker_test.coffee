describe 'Striker', ->
  it 'exists', ->
    expect(Striker).exists
    expect(Striker.Collection).exists

  it '.getKeys', ->
    attrs1 = { attr1: 1, attr2: 2, attr3: [1,2], attr4: 4 }
    expect(Striker.getKeys(attrs1)).eql(['1,2,1,4', '1,2,2,4'])

    attrs2 = { attr1: [1, 2], attr2: 2, attr3: [1,2], attr4: [4,5] }
    expect(Striker.getKeys(attrs2)).eql \
      ['1,2,1,4', '1,2,1,5', '1,2,2,4', '1,2,2,5', '2,2,1,4', '2,2,1,5', '2,2,2,4', '2,2,2,5']
