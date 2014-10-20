module.exports =
  # web service 的一些信息
  service:
    name: 'Your rest api name'
    version: '0.0.1'
    port: 9988

  # 数据库配置
  db:
    host: 'dbhost'
    name: 'dbname'
    encode:
      set: 'utf8'
      collation: 'utf8_general_ci'
    user: 'root'
    pass: ''
    dialect: 'mysql'
    define:
      underscored: no
      freezeTableName: yes
      syncOnAssociation: no
      charset: 'utf8'
      collate: 'utf8_general_ci'
      engine: 'MYISAM'
    syncOnAssociation: true
    pool:
      maxConnections: 500
      maxIdleTime: 30
