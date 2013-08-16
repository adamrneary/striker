# Striker

  Bad-ass, greasy-fast, cached, calculated collections.

## Installation

    $ bower install git@github.com:activecell/striker.git#0.7.0 --save

## Development setup

  * `npm install` - install dependenciese;
  * `npm test` - run tests to ensure that all pass;
  * `npm start` - run watch server locally on http://localhost:7357.

## Example

```coffee
Reach = Striker.extend
  schema: ['channel_id', 'period_id']
```

## API

### new Striker()

  Create new Striker instance.

### striker.get([args...])

  Convinient way to get access to `@values`.

```coffee
# If schema is ['channel_id', 'period_id']
conversionRates.get(2, 1)
# => channel_id=2, period_id=1, returns value, like 70
conversionRates.get(2)
# => channel_id=2, returns object, like {1: 70, 2: 17, ..., 36: 27}
```
