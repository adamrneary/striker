module.exports = class ChurnRates extends Striker.Collection
  schema: ['segment_id', 'period_id']
  multiplier: 100
