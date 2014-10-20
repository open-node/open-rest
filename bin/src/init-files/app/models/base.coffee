module.exports =
  # 分页设定
  pagination:
    # 默认每页最多返回结果条目数
    maxResults: 10
    # 结果条目数允许的最大值范围
    maxResultsLimit: 5000
    # 翻页的最大偏移值
    maxStartIndex: 1000000

  # sort 设定
  sort:
    default: 'id'
    allow: ['id', 'createdAt', 'updatedAt']
