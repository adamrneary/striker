# Striker [![Build Status](https://circleci.com/gh/activecell/striker.png?circle-token=e4e94a5aa232fb270ea22a5f32a34e3db5e75b61)](https://circleci.com/gh/activecell/striker)

  Bad-ass, greasy-fast, lazy calculated collections.

## Installation

    $ bower install git@github.com:activecell/striker.git --save

  or copy [striker/index.js] to vendors folder.

## Example

```coffee
Reach = Striker.extend
  schema: ['channel_id', 'period_id']

  # simplest possible calculations
  calculate: (channelId, periodId) ->
    actual: channelId
    plan:   periodId

# setup schema mapping, to transform 'channel_id' to real models
Striker.schemaMap = (key) ->
  switch key
    when 'period_id'  then app.periods.models
    when 'channel_id' then app.channels.models

# setup namespace, it will use in where/query and indexes
Striker.namespace = app

app.periods  = new Periods([{ id: 1 }, { id: 2 }, { id: 3 }]);
app.channels = new Channels([{ id: 1 }, { id: 2 }]);
app.reach    = new Reach() # initialize our striker

# it has some useful methods
app.reach.size() # => 6
app.reach.isEmpty() # => false

# all entries are lazy: it means, value does not calculated before you call get/all
entry = app.reach.get(1, 3) # => Striker.Entry()
entry.get('channel_id') # => 1
entry.get('plan') # => 3

# search methods from Backbone.Index
app.reach.query(period_id: [1, 2], channel_id: 1) # => Array(4)
app.reach.where(period_id: 3) # => Array(2)
```

## API

### new Striker([options])

  Create new Striker instance.
  options.careful

### striker#get(args...)

  Convinient way to get access to `@values`.

```coffee
# If schema is ['channel_id', 'period_id']
conversionRates.get(2, 1)
# => channel_id=2, period_id=1, returns value, like 70
conversionRates.get(2)
# => channel_id=2, returns object, like {1: 70, 2: 17, ..., 36: 27}
```

### striker#update(args...)
### striker#calculate(args...)

  `CRITICAL`: Override this in each subclass.

### striker#schema

  `CRITICAL`: Override this in each subclass.
  Array with collection IDs that setups with Striker.setSchemaMap

### striker#getters
### striker#observers
### striker#where(collectionName, condition)
### striker#query(collectionName, condition)

### Underscore's methods

### Build-in Events

  Striker extends [Backbone.Events](http://documentcloud.github.io/backbone/#Events),
  it means you can trigger and listen different events.

  * **change**(entry) - force on every update.
  * **add**
  * **remove**
  * **updateCompleted**

### Striker.schemaMap(key)

  `CRITICAL`: Override this once

### Striker.namespace
### Striker.addAnalysis(Model, methodName, [options])
### Striker.extend(methods)

## Development setup

  * `npm install` - install dependenciese;
  * `npm test` - run tests to ensure that all pass;
  * `npm start` - run watch server locally on http://localhost:7357
