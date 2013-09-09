# Striker [![Build Status](https://circleci.com/gh/activecell/striker.png?circle-token=e4e94a5aa232fb270ea22a5f32a34e3db5e75b61)](https://circleci.com/gh/activecell/striker)

  Bad-ass, greasy-fast, lazy calculated collections.

## Installation

    $ bower install git@github.com:activecell/striker.git --save

  or copy [striker/index.js](https://github.com/activecell/striker/blob/master/index.js) and [backbone-index/index.js](https://github.com/activecell/backbone-index/blob/master/index.js) to vendors folder.

## Development setup

  * `npm install` - install dependenciese
  * `npm test` - run tests to ensure that all pass
  * `npm start` - run test-watch server on http://localhost:7357

## Example

```js
// namespace for our "application"
var app = {};

var Reach = Striker.extend({
  schema: ['channel_id', 'period_id'],

  // simplest possible calculations
  calculate: function(channelId, periodId) {
    return { actual: channelId, plan: periodId };
  }
});

// setup schema mapping, to transform 'channel_id' to real models
Striker.schemaMap = function(key) {
  switch (key) {
    case 'period_id': return app.periods.models;
    case 'channel_id': return app.channels.models;
  }
}

# setup namespace, it will use in where/query and indexes
Striker.namespace = app;

app.periods  = new Periods([{ id: 1 }, { id: 2 }, { id: 3 }]);
app.channels = new Channels([{ id: 1 }, { id: 2 }]);
app.reach    = new Reach(); // initialize our striker

// all entries are lazy: it means,
// value does not calculated before you call get/all/property
var entry = app.reach.get(1, 3); // => Striker.Entry()
entry.actual; // => 1
entry.get('plan'); // => 3

// It supports search methods from Backbone.Index
app.reach.query(period_id: [1, 2], channel_id: 1); // => Array(4)
app.reach.where(period_id: 3); // => Array(2)

// Striker apply some useful methods from underscore
app.reach.size(); // => 6
app.reach.isEmpty(); // => false
```

For more advanced example check [test/integration-test.js](https://github.com/activecell/striker/blob/master/test/integration-test.js) or one of the activecell's strikers.

## Instance API

### new Striker([options])

  Base class for Strikers, extend it and add custom logic.
  You can pass { careful: true } to skip enabling of observers, and then run Striker.trigger('enable-observers') when you need it. But it does not apply for recursive strikers, they always enable observers immediately.

### striker#schema

  `CRITICAL`: Override this in each subclass.
  Array with collection IDs which map with `Striker.schemaMap`.

```js
schema: ['account_id', 'period_id']
```

### striker#values

  An object with structured values based on schema.

### striker#entries

  An array of values. Has similar meaning as [Backbone.Collection#models](http://documentcloud.github.io/backbone/#Collection-models).

### striker#get(args...)

  Get `@values`. Arguments semantic covered with schema.

```js
// If schema is ['channel_id', 'period_id']
conversionRates.get(2, 1);
// => channel_id=2, period_id=1, returns value, like 70
conversionRates.get(2);
// => channel_id=2, returns object, like {1: 70, 2: 17, ..., 36: 27}
```

### striker#update(args...)

  Update value and trigger `change` event. It actives only when value does not lazy. In other case no one ever ask for this value, so it does not need to know about this update. Update is a trigger to reset entry#isLazy. If you will call it 100 times, it force only one `change` event and will not calculate anything. Trully lazy behaviour.

### striker#reverseValues()

  Same as `@values`, but in reversed order. If schema is ['channel_id', 'period_id'] it will use ['period_id', 'channel_id'].

### striker#calculate(args...)

  `CRITICAL`: Override this in each subclass.
  The core and meaning of your striker. It uses to calculate value for arguments. It gets same amount arguments as defined in schema.
  It has to return **object** with fixed amount of attributes.

### striker#observers
### striker#getters
### striker#where(collectionName, condition)
### striker#query(collectionName, condition)

### Underscore's methods

  Thanks to `@entries` striker has underscore's collections methods, similar to [Backbone.Collection](http://documentcloud.github.io/backbone/#Collection-Underscore-Methods).
  List of methods:

```js
['forEach', 'map', 'reduce', 'reduceRight', 'find', 'filter',
'every', 'some', 'include', 'invoke', 'groupBy', 'countBy', 'sortBy',
'max', 'min', 'size', 'indexOf', 'isEmpty']
```

### Build-in Events

  Striker extends [Backbone.Events](http://documentcloud.github.io/backbone/#Events),
  it means you can trigger and listen different events.

  * **change**(entry, changedAttributes) - force on every update.
  * **updateCompleted**(entry, changedAttributes)

### Striker.schemaMap(key)

  `CRITICAL`: Override this once.

### Striker.namespace

  `CRITICAL`: Override this once.
  Namespace helps to understand observers property,
  `window` by default, change it to `window.app` or another object,
  which contains required collections.

### Striker.addAnalysis(Model, methodName, [options])
### Striker.extend(options)
### Striker.Entry
