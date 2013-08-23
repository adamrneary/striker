# Striker

  Bad-ass, greasy-fast, cached, calculated collections.

## Installation

    $ bower install git@github.com:activecell/striker.git#0.7.0 --save

  or copy [striker/index.js] to vendors folder.

## Development setup

  * `npm install` - install dependenciese;
  * `npm test` - run tests to ensure that all pass;
  * `npm start` - run watch server locally on http://localhost:7357.

## Example

```coffee
Reach = Striker.extend
  schema: ['channel_id', 'period_id']
  calculate: (channelId, periodId) ->

Striker.schemaMap = (key) ->
  switch key
    when 'period_id'  then app.periods.models
    when 'channel_id' then app.channels.models

reach = new Reach()
```

## Instance API

### new Striker()

  Create new Striker instance.

### striker.calculate

  `CRITICAL`: Override this in each subclass.

### striker.schema

  `CRITICAL`: Override this in each subclass.
  Array with collection IDs that setups with Striker.setSchemaMap

### striker.indexes

### striker.observers

### striker.get([args...])

  Convinient way to get access to `@values`.

```coffee
# If schema is ['channel_id', 'period_id']
conversionRates.get(2, 1)
# => channel_id=2, period_id=1, returns value, like 70
conversionRates.get(2)
# => channel_id=2, returns object, like {1: 70, 2: 17, ..., 36: 27}
```

### striker.update([args...])

  Recalculate value and trigger `change` event, if value changed.
  Make sure that `args.length is @schema.length`.

```coffee
conversionRates.get(2, 1) # => 10
conversionRates.calculate(2, 1) # => 12
conversionRates.update(2, 1)
reach.get(2, 1) # => 12
```

### striker.flat()

### striker.reverse()

### Build-in Events

  Striker extends [Backbone.Events](http://documentcloud.github.io/backbone/#Events),
  it means you can trigger and listen different events.

  * **change**(striker, arguments, value) - force on every update.

## Static API

  Striker provides a few useful methods, which helps make calculations faster

### Striker.sum(collection, field)

### Striker.where(collectionName, condition)

### Striker.query(collectionName, condition)

### Striker.addAnalysis(Model, methodName, [options])

### Striker.get(key)

### Striker.set(key, collection, method)
