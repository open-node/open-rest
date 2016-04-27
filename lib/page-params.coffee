module.exports = (pagination, params) ->
  startIndex = Math.max((+params.startIndex or 0), 0)
  maxResults = Math.max((+params.maxResults or +pagination.maxResults), 0)
  offset: Math.min(startIndex, pagination.maxStartIndex)
  limit: Math.min(maxResults, pagination.maxResultsLimit)
