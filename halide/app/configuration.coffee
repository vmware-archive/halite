# Service to provide global configuration meta data for application 
#  Can also used to avoid circular dependencies

# inject these from config.json
base = "/halide"

configuration =
    baseUrl: "#{base}"
    date: "20130709"
    views:
        otherwise: 
            label: "home"
            route: "#{base}/app/home"
            url: "#{base}/app/home"
            template: "#{base}/static/app/view/home.html"
            controller: "HomeCtlr"
        tabs:
            [
                label: "watch"
                route: "#{base}/app/watch/:id"
                url: "#{base}/app/watch/"
                template: "#{base}/static/app/view/watch.html"
                controller: "WatchCtlr"
            ,
                label: "test"
                route: "#{base}/app/test"
                url: "#{base}/app/test"
                template: "#{base}/static/app/view/test.html"
                controller: "testCtlr"
            ]



buildMatcher = (route) ->
    chunks = route.split("/")
    for chunk, i in chunks
        if chunk.match("^:\\w+$")?
            chunks[i] = "\\w*"
    matcher = "^" + chunks.join("/") + "$"
    return matcher

matcherify = (views) ->
    for name, item of views
        if item.label? # item is a view
            item.matcher = buildMatcher(item.route)
        else # item is a list of views
            for view in item
                view.matcher = buildMatcher(view.route)
    return views

configuration.views = matcherify(configuration.views)

configService = angular.module( "configService",[])

configService.constant 'Configuration', configuration



