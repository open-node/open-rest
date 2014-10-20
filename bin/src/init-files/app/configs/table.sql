DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `role` enum('member','admin') NOT NULL DEFAULT 'member',
  `email` varchar(255) NOT NULL COMMENT '用户email地址',
  `status` enum('enabled','disabled') NOT NULL DEFAULT 'enabled',
  `language` varchar(255) NOT NULL DEFAULT 'zh' COMMENT '当前用户的语言设置',
  `isDelete` enum('yes','no') NOT NULL DEFAULT 'no' COMMENT '是否被删除',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='系统用户表';
