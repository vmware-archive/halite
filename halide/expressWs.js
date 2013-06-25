var express = require("express"),
  app     = express(),
  port    = parseInt(process.env.PORT, 10) || 8080;

app.configure(function(){
  app.use(express.methodOverride());
  app.use(express.bodyParser());
  app.use(express.logger());
  app.all('/robots.txt', function(req,res){
    res.sendfile(__dirname + '/app/robots.txt', 100)
  });
  app.all('/', function(req,res){
    res.sendfile(__dirname + '/app/main.html', 100)
  });
  app.all('/halide', function(req,res){
    res.sendfile(__dirname + '/app/main.html', 100)
  });
  app.all('/halide/', function(req,res){
    res.sendfile(__dirname + '/app/main.html', 100)
  });
  app.all('/halide/app*', function(req,res){
    res.sendfile(__dirname + '/app/main.html', 100)
  });
  app.use("/halide/static/lib", express.static( __dirname + '/lib'));
  app.use("/halide/static/app", express.static( __dirname + '/app'));
  app.use(app.router);
});

app.listen(port);
console.log('Now serving the app at http://localhost:' + port + '/');
