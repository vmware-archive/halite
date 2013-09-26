appFltr = angular.module 'appFltr', []

appFltr.filter 'capitalcase', () ->
    filter = (input) ->
        return input.substring(0,1).toUpperCase()+input.substring(1)
    return filter   

appFltr.filter 'titlecase', () ->
    filter = (input) ->
        chunks = input.split(" ")
        for chunk, i in chunks
            chunks[i] = chunk.substring(0,1).toUpperCase()+chunk.substring(1)
        return chunks.join(" ")
    return filter 

appFltr.filter 'pagerize', () ->
    filter = (input, pager) ->
        if not pager?
            return input
        
        pager.itemCount = input.length
        start = pager.itemOffset()
        end = start + pager.perPage
        output = input.slice(start, end)
        return output
        
    return filter 
