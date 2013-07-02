// Generated by CoffeeScript 1.6.3
(function() {
  var ssFilter;

  ssFilter = angular.module('ssFilter', []);

  ssFilter.filter('capitalize', function() {
    var filter;
    filter = function(input) {
      var chunk, chunks, i, _i, _len;
      chunks = input.split(" ");
      for (i = _i = 0, _len = chunks.length; _i < _len; i = ++_i) {
        chunk = chunks[i];
        chunks[i] = chunk.substring(0, 1).toUpperCase() + chunk.substring(1);
      }
      return chunks.join(" ");
    };
    return filter;
  });

}).call(this);
