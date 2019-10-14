var express = require('express');
var fs = require('fs');
var https = require('https')
var proxy = require('express-http-proxy');
var app = require('express')(); 

var authUsername = process.env.USERNAME;
var authPassword = process.env.PASSWORD;
var userpw = authUsername + ":" + authPassword;
// console.log("User (base64): " + userpw);  

var backendOptions = {
  key: fs.readFileSync("/usr/share/elasticproxy/backend/elasticproxy-backend-key.pem"),
  cert: fs.readFileSync("/usr/share/elasticproxy/backend/elasticproxy-backend-crt.pem"),
  ca: fs.readFileSync("/usr/share/elasticproxy/backend/server.pem")
};

var frontendOptions = {
    key: fs.readFileSync('/usr/share/elasticproxy/frontend/elasticproxy-frontend-key.pem'),
    cert: fs.readFileSync('/usr/share/elasticproxy/frontend/elasticproxy-frontend-crt.pem')
};


app.use('/', proxy('https://elasticsearch:9200', {
    proxyReqOptDecorator: function(proxyReqOpts, originalReq) {
      proxyReqOpts.rejectUnauthorized = false
      proxyReqOpts.key = backendOptions.key
      proxyReqOpts.cert = backendOptions.cert
      proxyReqOpts.ca = backendOptions.ca
  
      return proxyReqOpts;
    },
    filter: function(req, res) {
      // check authorization
      var sentstr = req.headers.authorization;
      var parts  = sentstr.split(' ');
      sentstr = Buffer.from(parts[1], 'base64').toString('utf-8');
      parts = sentstr.split('\n');
      sentstr = parts[0];
      if (sentstr != userpw) {
        console.log("authorization: FAILED");
        console.log("request to " + req.method + " " + req.url)
        console.log("HEADERS: \n" + JSON.stringify(req.headers));
      return false;
      } else {
        return req.method == 'GET';
      }
    }
/*  Only needed, when the url contains a route, e.g. /elasticproxy
   ,    proxyReqPathResolver: function (req) {
      var parts = req.url.split('?');
      var queryString = parts[1];
      var updatedPath = parts[0].replace(/elasticproxy\//, '');
      updatedPath = updatedPath + (queryString ? '?' + queryString : '')
      console.log("request to " + updatedPath)
      return updatedPath;
    } */
}));


var listener = https.createServer(frontendOptions, app).listen(4433, function () {
    console.log('Express HTTPS server listening on port ' + listener.address().port);
});