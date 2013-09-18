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
  app.all('/halite', function(req,res){
    res.sendfile(__dirname + '/app/main.html', 100)
  });
  app.all('/halite/', function(req,res){
    res.sendfile(__dirname + '/app/main.html', 100)
  });
  app.all('/halite/app*', function(req,res){
    res.sendfile(__dirname + '/app/main.html', 100)
  });
  app.use("/halite/static/lib", express.static( __dirname + '/lib'));
  app.use("/halite/static/app", express.static( __dirname + '/app'));
  app.use(app.router);
});

app.listen(port);
console.log('Now serving the app at http://localhost:' + port + '/');
