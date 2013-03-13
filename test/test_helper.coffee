process.env.NODE_ENV ||= 'test'
process.env.PORT     ||= 5001

exports.expect  = require('chai').expect
exports._       = require('underscore')
exports.request = require('supertest')
exports.app     = require('../lib/server')
