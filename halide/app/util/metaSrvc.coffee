# Service to provide global meta data for application 
#   Also can used to avoid circular dependencies

metaservice = angular.module( "metaService",[])

base = '/halide'
views =
    otherwise: 
        label: "home"
        route: "#{base}/app/home"
        template: "#{base}/static/app/view/home.html"
        controller: "HomeCtlr"
    watch:
        label: "watch"
        route: "#{base}/app/watch/:mid"
        template: "#{base}/static/app/view/watch.html"
        controller: "WatchCtlr"
    test:
        label: "test"
        route: "#{base}/app/test"
        template: "#{base}/static/app/view/test.html"
        controller: "testCtlr"

buildRegex = (url) ->
    return

metaservice.constant( 'MetaConstants', 
    baseUrl: "#{base}"
    date: '20120625'
    views: views
)

