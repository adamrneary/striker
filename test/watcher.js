require('coffee-script')
global.glob = {}
glob.config = require('../server/config')
compile = require('../server/compiler').compile

spawn = require('child_process').spawn
exec = require('child_process').exec

cover = function (cb) {
  //cmd = __dirname+'/../node_modules/jscoverage/bin/visionmedia-jscoverage '+__dirname+'/../dist/'+glob.config.name+'.js '+__dirname+'/cov/'+glob.config.name+'.js'
  cmd = __dirname+'/../node_modules/jscoverage/bin/jscoverage '+__dirname+'/../dist/'+glob.config.name+'.js '+__dirname+'/cov/'+glob.config.name+'.js'
  exec(cmd,function(err,stdout,stderr) {
    if (cb) cb()
  });
};

try {
    require('fs').mkdirSync(__dirname+'/reports')
} catch (e) {

}

start = function () {
  compile(function() {
    server()
    cover(function() {
      report()
      spec()
    });
  });
};

server_instance = {}
server = function () {
  process.env.NODE_ENV = 'development'
  if (server_instance.kill) {server_instance.kill()}
  server_instance = spawn('node',['server/run'], {env: process.env})
  server_instance.stdout.on('data',function(data) {
    process.stdout.write(data.toString())
  });
  server_instance.stderr.on('data',function(data) {
    process.stdout.write(data.toString())
  });
};

globals = 'd3,window,_$jscoverage,_$jscoverage_cond,_$jscoverage_done,_$jscoverage_init,_,browser,Backbone'
report = function (cb) {
  cmd = 'REPORT=1 '+__dirname+'/../node_modules/mocha/bin/mocha '+__dirname+"/run.js -R html-cov -s 20 --timeout 6000 --globals "+globals
  exec(cmd,function(err,stdout,stderr) {
    require('fs').writeFile(__dirname+'/reports/coverage.html',stdout)
    if (cb) cb()
  });
};

spec = function (cb) {
  //proc = spawn(__dirname+'/../node_modules/mocha/bin/mocha',[__dirname+'/run.js', '-Gw','-R','spec','-s','20','--timeout','6000','--globals','d3,window,_$jscoverage,_$jscoverage_cond,_$jscoverage_done,_$jscoverage_init,_,browser'], {customFds: [0,1,2]})
  proc = spawn(__dirname+'/../node_modules/mocha/bin/mocha',[__dirname+'/run.js', '-Gw','-R','spec','-s','20','--timeout','6000','--globals',globals], {stdio: 'inherit'})
  //proc.stdout.pipe(process.stdout, {end: false})
  proc.on('exit',function() {
    start()
  });
};

start()
