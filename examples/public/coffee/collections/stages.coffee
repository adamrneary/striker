BackboneCollection = require('./shared/backbone_collection')

module.exports = class Stages extends BackboneCollection
  name: 'stages'
  printAttributes: ['id', 'name', 'lag', 'is_topline', 'is_customer']

