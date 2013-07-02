ssFilter = angular.module 'ssFilter', []

ssFilter.filter 'capitalize', () ->
    filter = (input) ->
        chunks = input.split(" ")
        for chunk, i in chunks
            chunks[i] = chunk.substring(0,1).toUpperCase()+chunk.substring(1)
        return chunks.join(" ")
    return filter   

