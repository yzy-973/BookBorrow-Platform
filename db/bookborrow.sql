/*
 Navicat Premium Dump SQL

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 80040 (8.0.40)
 Source Host           : localhost:3306
 Source Schema         : bookborrow

 Target Server Type    : MySQL
 Target Server Version : 80040 (8.0.40)
 File Encoding         : 65001

 Date: 15/08/2026 15:22:27
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人姓名',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '省/市/区',
  `info` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '详细地址',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '联系电话',
  `user_id` int NOT NULL COMMENT '所属用户ID（关联sys_user表）',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否默认地址：0-否，1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '收货地址管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, '张三', '浙江省/杭州市/滨江区', '滨江区长河街道江汉路1649号', '13800000001', 1, 1);
INSERT INTO `address` VALUES (2, '李四', '北京市/市辖区/海淀区', '海淀区中关村大街66号', '13800000002', 2, 1);
INSERT INTO `address` VALUES (3, '王五', '上海市/市辖区/浦东新区', '浦东新区世纪大道88号', '13800000003', 3, 1);
INSERT INTO `address` VALUES (4, '赵六', '广东省/广州市/天河区', '天河区天河路385号', '13800000004', 4, 1);

-- ----------------------------
-- Table structure for banner
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '轮播图名称/说明',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '图片URL',
  `link_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '跳转链接',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序序号（越小越靠前）',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '轮播图管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of banner
-- ----------------------------
INSERT INTO `banner` VALUES (1, '新书上架，热门图书限时借阅', 'http://127.0.0.1:9090/web/download/51855a85a1ee4c09b833b8931e865170.png', '/front/bookList', 1, 1);
INSERT INTO `banner` VALUES (2, '经典文学，重温大师之作', 'http://127.0.0.1:9090/web/download/38e510de52ed46229c693977170de89b.webp', '/front/bookList?type=1', 2, 1);
INSERT INTO `banner` VALUES (3, '科技前沿，探索未来世界', 'http://127.0.0.1:9090/web/download/2075bb68d4bf45d89c8e0bf2fe6145ca.png', '/front/bookList?type=4', 3, 1);

-- ----------------------------
-- Table structure for book
-- ----------------------------
DROP TABLE IF EXISTS `book`;
CREATE TABLE `book`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '图书ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '书名',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图书封面图（主图）',
  `img_list` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图书详情图列表（多张用逗号分隔）',
  `type_id` int NULL DEFAULT NULL COMMENT '图书分类ID（关联book_type表）',
  `author` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图书作者',
  `publisher` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出版社名称',
  `isbn` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国际标准书号ISBN',
  `publish_year` int NULL DEFAULT NULL COMMENT '出版年份',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '图书简介/详情描述',
  `place` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图书所在地（省/市/区）',
  `user_id` int NULL DEFAULT NULL COMMENT '图书所有者ID（关联sys_user表）',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览次数（浏览量）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '可借阅' COMMENT '图书状态：可借阅/已借出/维护中/已下架',
  `quality` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '全新' COMMENT '图书品相：全新/9成新/8成新/7成新/有破损',
  `publish_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '上架发布日期',
  `borrow_count` int NULL DEFAULT 0 COMMENT '累计借阅次数（统计字段）',
  `favorite_count` int NULL DEFAULT 0 COMMENT '收藏次数（统计字段）',
  `recommend_count` int NULL DEFAULT 0 COMMENT '推荐次数',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '借阅价/30天',
  `re_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价',
  `avg_rating` decimal(3, 2) NULL DEFAULT 0.00 COMMENT '平均评分（1-5分）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type_id`(`type_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_author`(`author` ASC) USING BTREE,
  INDEX `idx_isbn`(`isbn` ASC) USING BTREE,
  INDEX `idx_borrow_count`(`borrow_count` ASC) USING BTREE,
  INDEX `idx_favorite_count`(`favorite_count` ASC) USING BTREE,
  INDEX `idx_avg_rating`(`avg_rating` ASC) USING BTREE,
  INDEX `idx_recommend_count`(`recommend_count` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图书主表（替代闲置商品表）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of book
-- ----------------------------
INSERT INTO `book` VALUES (1, '活着', 'http://127.0.0.1:9090/web/download/huozhe.jpg', 'http://127.0.0.1:9090/web/download/huozhe1.jpg,http://127.0.0.1:9090/web/download/huozhe2.jpg', 12, '余华', '作家出版社', '9787506365437', 2012, '讲述了在大时代背景下，徐福贵的人生和家庭不断经受着苦难，最后所有亲人都先后离他而去，仅剩下年老的他和一头老牛相依为命。', '北京市/市辖区/朝阳区', 1, 2345, '可借阅', '全新', '2026-07-01', 129, 243, 498, 5.60, 9.30, 4.80, '2026-07-01 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (2, '三体', 'http://127.0.0.1:9090/web/download/santi.jpg', 'http://127.0.0.1:9090/web/download/santi1.jpg,http://127.0.0.1:9090/web/download/santi2.jpg', 10, '刘慈欣', '重庆出版社', '9787229093016', 2008, '文化大革命时期，军方探寻外星文明的绝秘计划\"红岸工程\"取得了突破性进展。', '北京市/市辖区/海淀区', 2, 8903, '可借阅', '全新', '2026-07-02', 342, 154, 435, 4.10, 8.60, 4.90, '2026-07-02 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (3, '百年孤独', 'http://127.0.0.1:9090/web/download/bainian.jpg', 'http://127.0.0.1:9090/web/download/bainian1.jpg', 13, '加西亚·马尔克斯', '南海出版公司', '9787544253994', 2011, '魔幻现实主义文学的代表作，描写了布恩迪亚家族七代人的传奇故事。', '上海市/市辖区/浦东新区', 3, 3106, '已借出', '9成新', '2026-07-03', 158, 89, 130, 3.30, 6.30, 4.70, '2026-07-03 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (4, '平凡的世界', 'http://127.0.0.1:9090/web/download/pingfan.jpg', 'http://127.0.0.1:9090/web/download/pingfan1.jpg', 12, '路遥', '北京十月文艺出版社', '9787530212113', 2017, '这是一部全景式地表现中国当代城乡社会生活的长篇小说。', '陕西省/西安市/碑林区', 3, 1895, '可借阅', '9成新', '2026-07-04', 90, 173, 105, 6.60, 9.90, 4.60, '2026-07-04 10:00:00', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (5, '解忧杂货店', 'http://127.0.0.1:9090/web/download/jieyou.jpg', 'http://127.0.0.1:9090/web/download/jieyou1.jpg', 11, '东野圭吾', '南海出版公司', '9787544270878', 2014, '现代人内心流失的东西，这家杂货店能帮你找回。', '广东省/广州市/天河区', 2, 5400, '已借出', '全新', '2026-07-05', 234, 284, 70, 4.30, 6.50, 4.80, '2026-07-05 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (6, '白夜行', 'http://127.0.0.1:9090/web/download/baiyexing.jpg', 'http://127.0.0.1:9090/web/download/baiyexing1.jpg', 11, '东野圭吾', '南海出版公司', '9787544258609', 2013, '一宗离奇命案牵出跨度近20年的步步惊心的故事。', '广东省/深圳市/南山区', 3, 4809, '可借阅', '8成新', '2026-07-06', 190, 65, 212, 3.30, 5.40, 5.00, '2026-07-06 10:00:00', '2026-08-08 17:57:52');
INSERT INTO `book` VALUES (7, '明朝那些事儿', 'http://127.0.0.1:9090/web/download/mingchao.jpg', 'http://127.0.0.1:9090/web/download/mingchao1.jpg', 3, '当年明月', '中国友谊出版公司', '9787505730865', 2009, '以史料为基础，讲述了从1344年到1644年这三百年间关于明朝的故事。', '浙江省/杭州市/西湖区', 4, 12007, '可借阅', '全新', '2026-07-07', 457, 114, 308, 5.80, 9.20, 4.90, '2026-07-07 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (8, '人类简史', 'http://127.0.0.1:9090/web/download/renlei.jpg', 'http://127.0.0.1:9090/web/download/renlei1.jpg', 3, '尤瓦尔·赫拉利', '中信出版社', '9787508647357', 2014, '从十万年前有生命迹象开始到21世纪资本、科技交织的人类发展史。', '上海市/市辖区/黄浦区', 4, 3906, '可借阅', '全新', '2026-07-08', 134, 400, 288, 1.50, 5.40, 4.40, '2026-07-08 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (9, '算法导论', 'http://127.0.0.1:9090/web/download/suanfa.jpg', 'http://127.0.0.1:9090/web/download/suanfa1.jpg', 4, 'Thomas H.Cormen', '机械工业出版社', '9787111407010', 2012, '深入浅出地介绍了计算机算法的基础知识。', '北京市/市辖区/海淀区', 5, 1501, '可借阅', '全新', '2026-07-09', 56, 207, 205, 7.00, 9.10, 4.30, '2026-07-09 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (10, '人工智能：一种现代方法', 'http://127.0.0.1:9090/web/download/ai.jpg', 'http://127.0.0.1:9090/web/download/ai1.jpg', 4, 'Stuart Russell', '清华大学出版社', '9787302406273', 2016, '全球公认的人工智能经典教材。', '北京市/市辖区/海淀区', 5, 1200, '维护中', '7成新', '2026-07-10', 45, 205, 539, 5.90, 9.60, 3.00, '2026-07-10 10:00:00', '2026-08-02 17:14:32');
INSERT INTO `book` VALUES (11, '沉思录', 'http://127.0.0.1:9090/web/download/chensilu.jpg', 'http://127.0.0.1:9090/web/download/chensilu1.jpg,http://127.0.0.1:9090/web/download/chensilu2.jpg', 5, '马可·奥勒留', '天津人民出版社', '9787201061771', 2009, '古罗马皇帝马可·奥勒留的私人自省手记，斯多葛学派经典著作。书中记录了作者在征战间隙与自我内心对话，探讨理性、克制、接纳无常，引导人们摆脱精神内耗，坚守内心的平和。', '北京市/市辖区/朝阳区', 1, 1320, '已借出', '9成新', '2026-07-11', 76, 336, 103, 3.30, 8.70, 4.60, '2026-07-11 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (12, '美的历程', 'http://127.0.0.1:9090/web/download/meidelicheng.jpg', 'http://127.0.0.1:9090/web/download/meidelicheng1.jpg,http://127.0.0.1:9090/web/download/meidelicheng2.jpg', 6, '李泽厚', '岳麓书社', '9787553800028', 2014, '中国美学经典读物，从上古图腾、青铜艺术，到诗词书画、明清文艺，梳理数千年华夏审美演变脉络，帮助读者理解中国人独有的艺术精神与审美追求。', '湖南省/长沙市/岳麓区', 4, 1650, '已借出', '全新', '2026-07-12', 83, 258, 405, 6.60, 11.00, 4.70, '2026-07-12 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (13, '小王子', 'http://127.0.0.1:9090/web/download/xiaowangzi.jpg', 'http://127.0.0.1:9090/web/download/xiaowangzi1.jpg,http://127.0.0.1:9090/web/download/xiaowangzi2.jpg', 13, '圣埃克苏佩里', '译林出版社', '9787544733128', 2018, '写给成年人的童话。小王子离开自己的星球开启星际旅行，遇见形形色色的人，最终懂得爱与责任；告诉人们：真正重要的东西，要用心才能看见。', '江苏省/南京市/鼓楼区', 2, 6210, '已借出', '全新', '2026-07-13', 266, 178, 220, 6.20, 7.90, 4.80, '2026-07-13 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (14, '刻意练习：如何从新手到大师', 'http://127.0.0.1:9090/web/download/6a25d7b04a044ee7849b8139cd709cc3.jpg', 'http://127.0.0.1:9090/web/download/b74a983c03784450bfd57e8036cf4624.png', 8, '安德斯·艾利克森', '机械工业出版社', '9787111534317', 2017, '打破“天赋决定上限”的固有认知，提出高效学习方法论：目标明确的练习、及时反馈、持续走出舒适区，适用于各行各业想要精进技能的读者。', '广东省/广州市/天河区', 5, 2122, '已借出', '9成新', '2026-07-14', 97, 404, 331, 5.60, 9.20, 4.50, '2026-07-14 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (15, '食物：味道的历史', 'http://127.0.0.1:9090/web/download/foodhistory.jpg', 'http://127.0.0.1:9090/web/download/foodhistory1.jpg,http://127.0.0.1:9090/web/download/foodhistory2.jpg', 9, '保罗·弗里曼', '浙江大学出版社', '9787308192930', 2019, '横跨千年的饮食文化史，梳理不同时代、不同地域人类口味的变迁，解析食物如何塑造文明、阶层、贸易与社会风俗，读懂味道背后的人类历史。', '浙江省/杭州市/西湖区', 4, 960, '已借出', '8成新', '2026-07-15', 41, 221, 94, 3.90, 7.90, 4.30, '2026-07-15 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (16, '沙丘', 'http://127.0.0.1:9090/web/download/3de4bcbde66147bb83e3bbd3586b20b2.jpg', 'http://127.0.0.1:9090/web/download/dune1.jpg,http://127.0.0.1:9090/web/download/dune2.jpg', 10, '弗兰克·赫伯特', '江苏凤凰文艺出版社', '9787559434913', 2019, '科幻史诗经典。围绕沙漠星球阿拉基斯的珍贵香料，展开家族斗争、宗教预言与星际博弈，融合生态、政治、宗教与人性思考，是世界科幻文学里程碑作品。', '上海市/市辖区/浦东新区', 3, 4701, '已借出', '9成新', '2026-07-16', 214, 427, 365, 5.70, 11.10, 4.80, '2026-07-16 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (17, '嫌疑人X的献身', 'http://127.0.0.1:9090/web/download/xianyirenX.jpg', 'http://127.0.0.1:9090/web/download/xianyirenX1.jpg,http://127.0.0.1:9090/web/download/xianyirenX2.jpg', 11, '东野圭吾', '南海出版公司', '9787544241342', 2008, '东野圭吾巅峰推理小说。天才数学家石神为守护邻居母女，设计一场近乎完美的骗局，逻辑与情感交织，极致的奉献与宿命令人唏嘘。', '广东省/深圳市/南山区', 2, 5100, '已借出', '9成新', '2026-07-17', 247, 277, 122, 4.50, 9.20, 4.70, '2026-07-17 10:00:00', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (18, '月亮与六便士', 'http://127.0.0.1:9090/web/download/moonand6pence.jpg', 'http://127.0.0.1:9090/web/download/moonand6pence1.jpg,http://127.0.0.1:9090/web/download/moonand6pence2.jpg', 13, '毛姆', '上海译文出版社', '9787532774645', 2018, '讲述中年银行家抛弃安稳生活，奔赴荒岛追逐绘画理想。探讨理想与现实、世俗安稳和精神追求，月亮代表理想，六便士代表现实生计。', '上海市/市辖区/黄浦区', 3, 3600, '已借出', '全新', '2026-07-18', 163, 247, 595, 3.70, 7.50, 4.60, '2026-07-18 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (19, '围城', 'http://127.0.0.1:9090/web/download/weicheng.jpg', 'http://127.0.0.1:9090/web/download/weicheng1.jpg,http://127.0.0.1:9090/web/download/weicheng2.jpg', 12, '钱钟书', '人民文学出版社', '9787020002481', 1991, '中国现代文学经典。以方鸿渐的人生轨迹为主线，描绘抗战时期知识分子的众生相，“城里的人想逃出来，城外的人想冲进去”道尽人生困境。', '上海市/市辖区/静安区', 3, 3200, '已借出', '8成新', '2026-07-19', 142, 506, 169, 5.40, 10.20, 4.70, '2026-07-19 10:00:00', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (20, '深度学习', 'http://127.0.0.1:9090/web/download/deeplearning.jpg', 'http://127.0.0.1:9090/web/download/deeplearning1.jpg,http://127.0.0.1:9090/web/download/deeplearning2.jpg', 4, 'Ian Goodfellow', '人民邮电出版社', '9787115461476', 2017, '业内俗称“花书”，深度学习领域权威教材。系统讲解神经网络、卷积网络、循环网络、生成模型等核心理论，AI从业者必读经典参考书。', '北京市/市辖区/海淀区', 5, 1750, '已借出', '全新', '2026-07-20', 63, 509, 575, 1.50, 5.10, 4.40, '2026-07-20 10:00:00', '2026-08-01 16:24:58');
INSERT INTO `book` VALUES (21, '夏洛的网', 'http://127.0.0.1:9090/web/download/charlotte.png', 'http://127.0.0.1:9090/web/download/charlotte1.png,http://127.0.0.1:9090/web/download/charlotte2.png', 7, 'E·B·怀特', '上海译文出版社', '9787532742706', NULL, '小猪威尔伯和蜘蛛夏洛之间温暖动人的友谊故事，教会孩子真诚与守护。', '江苏省/南京市/鼓楼区', 2, 226, '可借阅', '全新', '2026-07-30', 0, 83, 72, 5.00, 8.80, 0.00, '2026-07-30 23:07:16', '2026-08-08 18:04:55');
INSERT INTO `book` VALUES (22, '长袜子皮皮', 'http://127.0.0.1:9090/web/download/2ca45502e55547e1a6d55503a0450cdf.jpg', 'http://127.0.0.1:9090/web/download/ee4aa09584794a4fa6889df9707721a5.jpg,http://127.0.0.1:9090/web/download/1942a36793694963bb43739fafdf04ef.jpg', 7, '阿斯特丽德·林格伦', '中国少年儿童出版社', '9787500794217', NULL, '<p>独立勇敢、古灵精怪的皮皮，一个自由快乐的小女孩形象。</p>', '上海市/黄浦区', 3, 143, '可借阅', '9成新', '2026-07-30', 0, 140, 265, 6.70, 8.30, 0.00, '2026-07-30 23:07:16', '2026-07-31 22:03:03');
INSERT INTO `book` VALUES (23, '绿野仙踪', 'http://127.0.0.1:9090/web/download/8664a219ced9489ea3cb3dc6f19c4b58.jpg', 'http://127.0.0.1:9090/web/download/97448a63fc664349a223b7fa817dced9.jpg,http://127.0.0.1:9090/web/download/69d07dbee2724e0b8a3e70d9c41f3b61.jpg', 7, '弗兰克·鲍姆', '译林出版社', '9787544710837', NULL, '多萝西踏上奇幻冒险，寻找智慧、爱心与勇气。', '浙江省/杭州市/西湖区', 2, 117, '可借阅', '8成新', '2026-07-30', 0, 46, 199, 3.40, 6.70, 0.00, '2026-07-30 23:07:16', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (24, '瓦尔登湖', 'http://127.0.0.1:9090/web/download/waerdenghu.jpg', '', 1, '梭罗', '上海译文出版社', '9787532742515', 2010, '梭罗远离城市，在瓦尔登湖畔自建木屋独居两年，记录自然观察、生活思考，探讨简朴生活的意义。', '上海市/市辖区/浦东新区', 1, 92, '已借出', '全新', '2026-08-01', 1, 3, 1, 4.80, 8.50, 5.00, '2026-08-02 01:25:52', '2026-08-02 15:01:29');
INSERT INTO `book` VALUES (25, '沙之书', 'http://127.0.0.1:9090/web/download/shazhishu.jpg', '', 1, '博尔赫斯', '上海译文出版社', '9787532762826', 2015, '博尔赫斯经典短篇小说集，充满迷宫、梦境、无限与隐喻，魔幻文学经典。', '上海市/市辖区/浦东新区', 8, 201, '可借阅', '全新', '2026-08-01', 0, 5, 3, 4.20, 7.90, 3.75, '2026-08-02 01:25:52', '2026-08-02 17:13:23');
INSERT INTO `book` VALUES (26, '湘行散记', 'http://127.0.0.1:9090/web/download/xiangxingsanji.jpg', '', 1, '沈从文', '人民文学出版社', '9787020009304', 2013, '沈从文回乡旅途随笔，书写湘西风土人情，朴素又充满诗意。', '湖南省/长沙市/岳麓区', 1, 95, '可借阅', '全新', '2026-08-01', 0, 2, 2, 4.50, 8.20, 5.00, '2026-08-02 01:25:52', '2026-08-02 15:01:29');
INSERT INTO `book` VALUES (27, '局外人', 'http://127.0.0.1:9090/web/download/juwairen.jpg', '', 2, '加缪', '上海译文出版社', '9787532751837', 2013, '存在主义经典小说，讲述主人公默尔索疏离世俗、拒绝伪装的人生选择。', '上海市/市辖区/浦东新区', 1, 189, '已借出', '全新', '2026-08-01', 1, 1, 4, 4.60, 8.80, 3.00, '2026-08-02 01:25:52', '2026-08-02 15:01:29');
INSERT INTO `book` VALUES (28, '呼啸山庄', 'http://127.0.0.1:9090/web/download/huxiaoshanzhuang.jpg', '', 2, '艾米莉·勃朗特', '译林出版社', '9787544724324', 2016, '爱恨交织的复仇故事，英国文学极具冲击力的经典长篇小说。', '江苏省/南京市/鼓楼区', 8, 88, '可借阅', '全新', '2026-08-01', 0, 2, 1, 4.30, 8.10, 3.50, '2026-08-02 01:25:52', '2026-08-15 15:14:16');
INSERT INTO `book` VALUES (29, '苔丝', 'http://127.0.0.1:9090/web/download/taisi.jpg', '', 2, '托马斯·哈代', '人民文学出版社', '9787020009526', 2014, '维多利亚时代乡村少女苔丝的悲剧命运，探讨时代偏见与人性。', '北京市/市辖区/朝阳区', 5, 169, '可借阅', '全新', '2026-08-01', 0, 4, 3, 4.10, 7.60, 3.75, '2026-08-02 01:25:52', '2026-08-02 17:13:08');
INSERT INTO `book` VALUES (30, '史记选', 'http://127.0.0.1:9090/web/download/shiji.jpg', 'http://127.0.0.1:9090/web/download/dc05a3954a164a84ae798f8a320091b0.jpg', 3, '司马迁', '中华书局', '9787101065134', 2010, '<p>《史记》精选读本，选取本纪、世家、列传名篇，通俗易读。</p>', '北京市/市辖区/东城区', 1, 138, '可借阅', '全新', '2026-08-01', 0, 4, 2, 5.10, 9.00, 4.33, '2026-08-02 01:25:52', '2026-08-02 15:40:17');
INSERT INTO `book` VALUES (31, '理想国', 'http://127.0.0.1:9090/web/download/lixiangguo.jpg', '', 5, '柏拉图', '商务印书馆', '9787100017444', 2011, '西方政治哲学源头，探讨正义、城邦、教育与理想社会。', '北京市/市辖区/东城区', 2, 54, '可借阅', '全新', '2026-08-01', 0, 3, 1, 5.30, 9.50, 4.00, '2026-08-02 01:25:52', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (32, '存在与时间（节选读本）', 'http://127.0.0.1:9090/web/download/cunzai.jpg', 'http://127.0.0.1:9090/web/download/3fd37a1a9900473ca675fdd27c2d2190.jpg', 5, '海德格尔', '生活·读书·新知三联书店', '9787108057969', 2017, '现代存在主义哲学核心著作，围绕“此在”与时间展开思考。', '北京市/市辖区/朝阳区', 1, 116, '可借阅', '9成新', '2026-08-01', 0, 4, 3, 4.90, 9.20, 3.00, '2026-08-02 01:25:52', '2026-08-02 15:40:17');
INSERT INTO `book` VALUES (33, '艺术的故事', 'http://127.0.0.1:9090/web/download/yishu.jpg', '', 6, '贡布里希', '广西美术出版社', '9787549412363', 2015, '全球经典艺术通史，通俗讲解从古埃及到现代艺术演变。', '广西/南宁市', 2, 112, '可借阅', '全新', '2026-08-01', 0, 3, 1, 6.00, 10.50, 3.00, '2026-08-02 01:25:52', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (34, '谈美', 'http://127.0.0.1:9090/web/download/tanmei.jpg', '', 6, '朱光潜', '中华书局', '9787101087303', 2012, '朱光潜写给大众的美学入门书，通俗易懂，普及审美思想。', '北京市/市辖区/东城区', 1, 186, '可借阅', '8成新', '2026-08-01', 0, 3, 1, 4.40, 7.80, 5.00, '2026-08-02 01:25:52', '2026-08-02 15:40:17');
INSERT INTO `book` VALUES (35, '爱弥儿', 'http://127.0.0.1:9090/web/download/ainier.jpg', '', 8, '卢梭', '商务印书馆', '9787100066625', 2011, '自然主义教育经典，论述儿童应当顺应天性成长。', '北京市/市辖区/东城区', 5, 173, '可借阅', '全新', '2026-08-01', 0, 2, 1, 4.70, 8.60, 3.00, '2026-08-02 01:25:52', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (36, '学习之道', 'http://127.0.0.1:9090/web/download/xuexizhidao.jpg', '', 8, '芭芭拉·奥克利', '机械工业出版社', '9787111550300', 2016, '大脑科学视角讲解高效学习方法，适合学生与终身学习者。', '北京市/市辖区/海淀区', 1, 146, '已借出', '全新', '2026-08-01', 0, 3, 1, 4.50, 8.30, 4.00, '2026-08-02 01:25:52', '2026-08-02 15:01:29');
INSERT INTO `book` VALUES (37, '谷物大脑', 'http://127.0.0.1:9090/web/download/guwudanao.jpg', '', 9, '戴维·珀尔马特', '机械工业出版社', '9787111500350', 2015, '饮食科普读物，讲解碳水、谷物对大脑健康的影响。', '北京市/市辖区/海淀区', 3, 155, '可借阅', '全新', '2026-08-01', 0, 4, 3, 4.20, 7.70, 4.00, '2026-08-02 01:25:52', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (38, '断舍离', 'http://127.0.0.1:9090/web/download/duansheli.jpg', '', 9, '山下英子', '广西科学技术出版社', '9787555103617', 2014, '通过整理物品来整理生活空间与内心状态，保留真正让自己心动的事物，释放多余负担。', '上海市/市辖区/浦东新区', 4, 196, '可借阅', '全新', '2026-08-01', 0, 3, 2, 4.00, 7.30, 3.50, '2026-08-02 01:25:52', '2026-08-02 16:54:28');
INSERT INTO `book` VALUES (39, '流浪地球', 'http://127.0.0.1:9090/web/download/liulang.jpg', '', 10, '刘慈欣', '江苏凤凰文艺出版社', '9787539983233', 2015, '太阳即将氦闪，人类启动流浪地球计划，带着地球逃离太阳系，开启宏大的宇宙迁徙史诗。', '江苏省/南京市/鼓楼区', 4, 143, '可借阅', '全新', '2026-08-01', 1, 0, 1, 5.00, 9.10, 5.00, '2026-08-02 01:25:52', '2026-08-02 17:00:38');
INSERT INTO `book` VALUES (40, '动物立体书', 'http://127.0.0.1:9090/web/download/da16e3e1e55d400dbadcfc075d5b5a79.png', 'http://127.0.0.1:9090/web/download/cca2e0d41d724d5ab11eea837b8798cb.png', 7, NULL, NULL, NULL, NULL, '<p>这本书讲了很多动物，很适合儿童学习</p>', '天津市/市辖区/河西区', 1, 3, '可借阅', '全新', '2020-07-03', 0, 0, 0, 3.88, 6.70, 0.00, '2026-08-08 18:02:10', '2026-08-08 18:02:10');

-- ----------------------------
-- Table structure for book_comment
-- ----------------------------
DROP TABLE IF EXISTS `book_comment`;
CREATE TABLE `book_comment`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `like_count` int NULL DEFAULT 0,
  `reply_count` int NULL DEFAULT 0,
  `parent_id` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_book_id`(`book_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of book_comment
-- ----------------------------
INSERT INTO `book_comment` VALUES (1, 1, 2, '余华老师的作品真的太震撼了！', 23, 0, 0, 0, '2026-05-28 14:47:46');
INSERT INTO `book_comment` VALUES (2, 4, 1, '中国科幻的巅峰之作！', 45, 0, 0, 0, '2026-05-26 14:47:46');
INSERT INTO `book_comment` VALUES (3, 9, 3, '历史写得太有意思了。', 18, 0, 0, 0, '2026-06-01 14:47:46');
INSERT INTO `book_comment` VALUES (4, 15, 4, '朋友推荐的，果然没让我失望。', 9, 0, 0, 0, '2026-07-30 18:00:00');
INSERT INTO `book_comment` VALUES (5, 25, 1, '观点很清晰，笔记做了不少。', 23, 0, 0, 0, '2026-07-26 20:00:00');
INSERT INTO `book_comment` VALUES (6, 26, 5, '适合周末安静读完。', 24, 0, 0, 0, '2026-07-29 17:00:00');
INSERT INTO `book_comment` VALUES (11, 29, 4, '看完想马上再借下一本同类书。', 20, 0, 0, 0, '2026-08-02 19:00:00');
INSERT INTO `book_comment` VALUES (13, 10, 4, '封面好看，内容更精彩。', 24, 0, 0, 0, '2026-07-28 13:00:00');

-- ----------------------------
-- Table structure for book_rating
-- ----------------------------
DROP TABLE IF EXISTS `book_rating`;
CREATE TABLE `book_rating`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '评分ID',
  `book_id` int NOT NULL COMMENT '被评分图书ID（关联book表）',
  `user_id` int NOT NULL COMMENT '评分用户ID（关联sys_user表）',
  `score` int NOT NULL COMMENT '评分分数（1-5分）',
  `comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '评价内容',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评分时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_book_user`(`book_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_book_id`(`book_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_score`(`score` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图书评分表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of book_rating
-- ----------------------------
INSERT INTO `book_rating` VALUES (1, 1, 2, 5, '非常震撼，值得一读再读', '2026-07-15 10:00:00');
INSERT INTO `book_rating` VALUES (2, 1, 3, 5, '满分好评，余华老师的经典之作', '2026-07-16 10:00:00');
INSERT INTO `book_rating` VALUES (3, 1, 4, 4, '很好，就是太悲伤了', '2026-07-17 10:00:00');
INSERT INTO `book_rating` VALUES (4, 2, 1, 5, '中国科幻的巅峰之作', '2026-07-18 10:00:00');
INSERT INTO `book_rating` VALUES (5, 2, 3, 5, '强烈推荐，脑洞大开', '2026-07-19 10:00:00');
INSERT INTO `book_rating` VALUES (6, 2, 5, 5, '神作，无法超越', '2026-07-20 10:00:00');
INSERT INTO `book_rating` VALUES (7, 3, 1, 5, '魔幻现实主义巅峰之作', '2026-07-21 10:00:00');
INSERT INTO `book_rating` VALUES (8, 3, 5, 4, '很棒，但比较难啃', '2026-07-22 10:00:00');
INSERT INTO `book_rating` VALUES (9, 7, 2, 5, '非常有趣，一口气读完', '2026-07-23 10:00:00');
INSERT INTO `book_rating` VALUES (10, 7, 3, 5, '历史也可以这么生动', '2026-07-24 10:00:00');
INSERT INTO `book_rating` VALUES (15, 24, 1, 5, '装帧也好，阅读体验佳', '2026-07-31 16:00:00');
INSERT INTO `book_rating` VALUES (16, 25, 5, 4, '读完很有收获，推荐给大家', '2026-07-27 13:00:00');
INSERT INTO `book_rating` VALUES (17, 25, 4, 3, '经典之作，值得反复读', '2026-08-01 18:00:00');
INSERT INTO `book_rating` VALUES (18, 25, 2, 4, '文笔不错，节奏也舒服', '2026-08-01 18:00:00');
INSERT INTO `book_rating` VALUES (19, 26, 5, 5, '装帧也好，阅读体验佳', '2026-08-01 14:00:00');
INSERT INTO `book_rating` VALUES (20, 27, 5, 3, '读完很有收获，推荐给大家', '2026-07-29 10:00:00');
INSERT INTO `book_rating` VALUES (21, 27, 4, 3, '经典之作，值得反复读', '2026-07-30 14:00:00');
INSERT INTO `book_rating` VALUES (22, 28, 4, 3, '装帧也好，阅读体验佳', '2026-07-28 11:00:00');
INSERT INTO `book_rating` VALUES (23, 28, 3, 4, '很有启发，打开了新思路', '2026-07-27 16:00:00');
INSERT INTO `book_rating` VALUES (24, 29, 3, 3, '强烈推荐，已加入常读书单', '2026-07-28 12:00:00');
INSERT INTO `book_rating` VALUES (25, 29, 2, 5, '总体不错，个别章节稍慢', '2026-07-29 20:00:00');
INSERT INTO `book_rating` VALUES (26, 29, 1, 3, '读完很有收获，推荐给大家', '2026-08-01 11:00:00');
INSERT INTO `book_rating` VALUES (27, 30, 3, 4, '强烈推荐，已加入常读书单', '2026-07-28 10:00:00');
INSERT INTO `book_rating` VALUES (28, 30, 2, 4, '强烈推荐，已加入常读书单', '2026-08-03 18:00:00');
INSERT INTO `book_rating` VALUES (29, 30, 1, 5, '总体不错，个别章节稍慢', '2026-08-01 16:00:00');
INSERT INTO `book_rating` VALUES (30, 31, 5, 3, '读完很有收获，推荐给大家', '2026-07-30 15:00:00');
INSERT INTO `book_rating` VALUES (31, 31, 4, 4, '经典之作，值得反复读', '2026-07-26 19:00:00');
INSERT INTO `book_rating` VALUES (32, 31, 1, 5, '装帧也好，阅读体验佳', '2026-08-03 11:00:00');
INSERT INTO `book_rating` VALUES (33, 32, 5, 3, '读完很有收获，推荐给大家', '2026-07-28 18:00:00');
INSERT INTO `book_rating` VALUES (34, 32, 3, 3, '装帧也好，阅读体验佳', '2026-07-25 15:00:00');
INSERT INTO `book_rating` VALUES (35, 32, 1, 3, '总体不错，个别章节稍慢', '2026-08-01 15:00:00');
INSERT INTO `book_rating` VALUES (36, 33, 1, 3, '很有启发，打开了新思路', '2026-07-26 09:00:00');
INSERT INTO `book_rating` VALUES (37, 34, 4, 5, '总体不错，个别章节稍慢', '2026-08-03 20:00:00');
INSERT INTO `book_rating` VALUES (38, 35, 5, 3, '经典之作，值得反复读', '2026-07-30 19:00:00');
INSERT INTO `book_rating` VALUES (39, 36, 2, 4, '很有启发，打开了新思路', '2026-08-03 19:00:00');
INSERT INTO `book_rating` VALUES (40, 37, 4, 5, '经典之作，值得反复读', '2026-07-26 15:00:00');
INSERT INTO `book_rating` VALUES (41, 37, 3, 3, '内容扎实，适合慢慢品', '2026-07-27 18:00:00');
INSERT INTO `book_rating` VALUES (42, 37, 2, 4, '读完很有收获，推荐给大家', '2026-08-03 12:00:00');
INSERT INTO `book_rating` VALUES (43, 38, 5, 3, '装帧也好，阅读体验佳', '2026-07-28 11:00:00');
INSERT INTO `book_rating` VALUES (44, 38, 4, 4, '读完很有收获，推荐给大家', '2026-07-28 15:00:00');
INSERT INTO `book_rating` VALUES (45, 39, 5, 5, '很有启发，打开了新思路', '2026-07-27 17:00:00');
INSERT INTO `book_rating` VALUES (46, 39, 2, 5, '总体不错，个别章节稍慢', '2026-08-01 20:00:00');
INSERT INTO `book_rating` VALUES (78, 29, 4, 4, '看完想马上再借下一本同类书。', '2026-08-02 17:13:08');
INSERT INTO `book_rating` VALUES (79, 25, 1, 4, '观点很清晰，笔记做了不少。', '2026-08-02 17:13:23');
INSERT INTO `book_rating` VALUES (80, 10, 4, 3, '书有点旧了，但是不影响看', '2026-08-02 17:14:32');
INSERT INTO `book_rating` VALUES (81, 6, 1, 5, '这本书的内容很不错！！！', '2026-08-08 17:57:52');

-- ----------------------------
-- Table structure for book_recommend
-- ----------------------------
DROP TABLE IF EXISTS `book_recommend`;
CREATE TABLE `book_recommend`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `book_id` int NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_book`(`user_id` ASC, `book_id` ASC) USING BTREE,
  INDEX `idx_book_id`(`book_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户图书推荐' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of book_recommend
-- ----------------------------
INSERT INTO `book_recommend` VALUES (2, 1, 13, '2026-08-01 15:13:00');
INSERT INTO `book_recommend` VALUES (3, 1, 6, '2026-08-01 15:13:00');
INSERT INTO `book_recommend` VALUES (4, 1, 9, '2026-08-01 18:00:53');
INSERT INTO `book_recommend` VALUES (5, 1, 24, '2026-07-27 18:00:00');
INSERT INTO `book_recommend` VALUES (6, 4, 25, '2026-08-01 13:00:00');
INSERT INTO `book_recommend` VALUES (7, 2, 25, '2026-07-22 20:00:00');
INSERT INTO `book_recommend` VALUES (8, 1, 25, '2026-07-25 03:00:00');
INSERT INTO `book_recommend` VALUES (9, 5, 26, '2026-08-02 20:00:00');
INSERT INTO `book_recommend` VALUES (10, 4, 26, '2026-07-27 10:00:00');
INSERT INTO `book_recommend` VALUES (11, 4, 27, '2026-08-02 17:00:00');
INSERT INTO `book_recommend` VALUES (12, 3, 27, '2026-07-28 02:00:00');
INSERT INTO `book_recommend` VALUES (13, 2, 27, '2026-07-23 12:00:00');
INSERT INTO `book_recommend` VALUES (14, 1, 27, '2026-08-02 10:00:00');
INSERT INTO `book_recommend` VALUES (15, 5, 28, '2026-08-02 15:00:00');
INSERT INTO `book_recommend` VALUES (17, 4, 29, '2026-07-25 14:00:00');
INSERT INTO `book_recommend` VALUES (18, 3, 29, '2026-07-23 16:00:00');
INSERT INTO `book_recommend` VALUES (19, 1, 29, '2026-08-01 22:00:00');
INSERT INTO `book_recommend` VALUES (20, 4, 30, '2026-08-01 22:00:00');
INSERT INTO `book_recommend` VALUES (21, 2, 30, '2026-07-27 12:00:00');
INSERT INTO `book_recommend` VALUES (22, 4, 31, '2026-07-26 20:00:00');
INSERT INTO `book_recommend` VALUES (23, 5, 32, '2026-07-29 03:00:00');
INSERT INTO `book_recommend` VALUES (24, 4, 32, '2026-07-26 11:00:00');
INSERT INTO `book_recommend` VALUES (25, 3, 32, '2026-07-24 12:00:00');
INSERT INTO `book_recommend` VALUES (26, 2, 33, '2026-08-01 02:00:00');
INSERT INTO `book_recommend` VALUES (28, 2, 34, '2026-07-24 01:00:00');
INSERT INTO `book_recommend` VALUES (29, 1, 35, '2026-08-02 14:00:00');
INSERT INTO `book_recommend` VALUES (30, 1, 36, '2026-08-02 19:00:00');
INSERT INTO `book_recommend` VALUES (31, 3, 37, '2026-08-03 03:00:00');
INSERT INTO `book_recommend` VALUES (32, 2, 37, '2026-07-25 18:00:00');
INSERT INTO `book_recommend` VALUES (33, 1, 37, '2026-07-23 23:00:00');
INSERT INTO `book_recommend` VALUES (34, 2, 38, '2026-07-23 01:00:00');
INSERT INTO `book_recommend` VALUES (35, 1, 38, '2026-07-26 14:00:00');
INSERT INTO `book_recommend` VALUES (36, 5, 39, '2026-07-31 21:00:00');
INSERT INTO `book_recommend` VALUES (37, 1, 3, '2026-08-08 17:56:50');

-- ----------------------------
-- Table structure for book_stock
-- ----------------------------
DROP TABLE IF EXISTS `book_stock`;
CREATE TABLE `book_stock`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '库存记录ID',
  `book_id` int NOT NULL COMMENT '所属图书ID（关联book表）',
  `stock_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '库存编号/条码（唯一标识每一册图书）',
  `status` int NOT NULL DEFAULT 0 COMMENT '单册状态：0-可借，1-已借出，2-维护中，3-已损坏，4-已下架',
  `borrow_record_id` int NULL DEFAULT NULL COMMENT '当前借阅记录ID（status=1时有值）',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '存放位置（书架/仓库位置）',
  `purchase_date` date NULL DEFAULT NULL COMMENT '采购日期',
  `purchase_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '采购价格',
  `condition` int NULL DEFAULT 0 COMMENT '品相等级：0-全新，1-良好，2-一般，3-陈旧，4-损坏',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注（如：封面有轻微磨损）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_stock_code`(`stock_code` ASC) USING BTREE,
  INDEX `idx_book_id`(`book_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_borrow_record_id`(`borrow_record_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图书库存明细表（每一册独立记录）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of book_stock
-- ----------------------------
INSERT INTO `book_stock` VALUES (1, 1, 'BK20260001', 0, NULL, 'A区-3排-5列', '2026-01-15', 25.00, 0, '全新', '2026-01-15 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (2, 1, 'BK20260002', 0, NULL, 'A区-3排-5列', '2026-01-15', 25.00, 0, '已借出', '2026-01-15 10:00:00', '2026-08-02 17:00:38');
INSERT INTO `book_stock` VALUES (3, 1, 'BK20260003', 0, NULL, 'A区-3排-6列', '2026-02-01', 25.00, 0, '全新', '2026-02-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (4, 2, 'BK20260004', 0, NULL, 'B区-1排-2列', '2026-01-20', 29.00, 0, '全新', '2026-01-20 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (5, 2, 'BK20260005', 0, NULL, 'B区-1排-2列', '2026-01-20', 29.00, 0, '已借出', '2026-01-20 10:00:00', '2026-08-02 16:49:08');
INSERT INTO `book_stock` VALUES (6, 2, 'BK20260006', 0, NULL, 'B区-1排-3列', '2026-02-15', 29.00, 1, '良好', '2026-02-15 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (7, 3, 'BK20260007', 1, 22, 'C区-2排-1列', '2026-03-01', 35.00, 0, '全新', '2026-03-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (8, 3, 'BK20260008', 1, 3, 'C区-2排-1列', '2026-03-01', 35.00, 0, '已借出', '2026-03-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (9, 4, 'BK20260009', 0, 9, 'A区-5排-3列', '2026-02-10', 28.00, 0, '全新', '2026-02-10 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (10, 4, 'BK20260010', 0, NULL, 'A区-5排-3列', '2026-02-10', 28.00, 1, '良好', '2026-02-10 10:00:00', '2026-08-01 16:53:30');
INSERT INTO `book_stock` VALUES (11, 5, 'BK20260011', 1, 5, 'B区-3排-4列', '2026-03-15', 30.00, 0, '已借出', '2026-03-15 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (12, 6, 'BK20260012', 0, NULL, 'B区-3排-5列', '2026-04-01', 28.00, 2, '一般', '2026-04-01 10:00:00', '2026-08-08 17:57:35');
INSERT INTO `book_stock` VALUES (13, 7, 'BK20260013', 1, 10, 'C区-5排-2列', '2026-05-01', 45.00, 0, '全新', '2026-05-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (14, 7, 'BK20260014', 0, NULL, 'C区-5排-2列', '2026-05-01', 45.00, 0, '全新', '2026-05-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (15, 8, 'BK20260015', 0, NULL, 'C区-6排-1列', '2026-05-15', 38.00, 0, '全新', '2026-05-15 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (16, 9, 'BK20260016', 0, NULL, 'D区-1排-3列', '2026-06-01', 55.00, 0, '全新', '2026-06-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (17, 9, 'BK20260017', 2, NULL, 'D区-1排-3列', '2026-06-01', 55.00, 0, '维护中', '2026-06-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (18, 10, 'BK20260018', 2, NULL, 'D区-2排-1列', '2026-06-15', 60.00, 3, '陈旧，需修复', '2026-06-15 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `book_stock` VALUES (20, 21, 'BK2026021A', 0, NULL, 'C区-少儿-1排', '2026-07-30', 10.00, 0, '全新', '2026-07-30 23:16:39', '2026-07-30 23:16:39');
INSERT INTO `book_stock` VALUES (21, 22, 'BK2026022A', 0, NULL, 'C区-少儿-2排', '2026-07-30', 8.00, 0, '全新', '2026-07-30 23:16:39', '2026-07-30 23:16:39');
INSERT INTO `book_stock` VALUES (22, 23, 'BK2026023A', 0, NULL, 'C区-少儿-3排', '2026-07-30', 7.00, 0, '全新', '2026-07-30 23:16:39', '2026-07-30 23:16:39');
INSERT INTO `book_stock` VALUES (23, 24, 'BK20260024A', 1, 11, '仓库A', '2026-08-01', 8.50, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (24, 25, 'BK20260025A', 0, NULL, '仓库A', '2026-08-01', 7.90, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (25, 26, 'BK20260026A', 0, NULL, '仓库A', '2026-08-01', 8.20, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (26, 27, 'BK20260027A', 1, 12, '仓库A', '2026-08-01', 8.80, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (27, 28, 'BK20260028A', 0, NULL, '仓库A', '2026-08-01', 8.10, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (28, 29, 'BK20260029A', 0, NULL, '仓库A', '2026-08-01', 7.60, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (29, 30, 'BK20260030A', 0, NULL, '仓库A', '2026-08-01', 9.00, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (30, 31, 'BK20260031A', 0, NULL, '仓库A', '2026-08-01', 9.50, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (31, 32, 'BK20260032A', 0, NULL, '仓库A', '2026-08-01', 9.20, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (32, 33, 'BK20260033A', 0, NULL, '仓库A', '2026-08-01', 10.50, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (33, 34, 'BK20260034A', 0, NULL, '仓库A', '2026-08-01', 7.80, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (34, 35, 'BK20260035A', 0, NULL, '仓库A', '2026-08-01', 8.60, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (35, 36, 'BK20260036A', 1, 13, '仓库A', '2026-08-01', 8.30, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (36, 37, 'BK20260037A', 0, NULL, '仓库A', '2026-08-01', 7.70, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (37, 38, 'BK20260038A', 0, NULL, '仓库A', '2026-08-01', 7.30, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 01:25:52');
INSERT INTO `book_stock` VALUES (38, 39, 'BK20260039A', 0, NULL, '仓库A', '2026-08-01', 9.10, 0, NULL, '2026-08-02 01:25:52', '2026-08-02 16:53:50');
INSERT INTO `book_stock` VALUES (39, 15, 'BK15-1', 0, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-02 17:11:28', '2026-08-02 17:11:28');
INSERT INTO `book_stock` VALUES (40, 40, 'BK40-1', 0, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-08 18:02:10', '2026-08-08 18:02:10');

-- ----------------------------
-- Table structure for book_type
-- ----------------------------
DROP TABLE IF EXISTS `book_type`;
CREATE TABLE `book_type`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称（如：文学、科技、历史）',
  `info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类描述',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类图标URL',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类推荐图URL',
  `parent_id` int NULL DEFAULT 0 COMMENT '父分类ID（0表示顶级分类）',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序序号（越小越靠前）',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `is_recommend` tinyint NULL DEFAULT 0 COMMENT '是否推荐到首页：0-不推荐，1-推荐',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图书分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of book_type
-- ----------------------------
INSERT INTO `book_type` VALUES (1, '文学', '文学作品、诗歌、散文等', 'http://127.0.0.1:9090/web/download/5b8c764375a147ed961f97baf45156f5.png', 'http://127.0.0.1:9090/web/download/ceead1a684b74bf4bbab251ae19cc4f0.png', 0, 1, 1, 1);
INSERT INTO `book_type` VALUES (2, '小说', '各类小说作品', 'http://127.0.0.1:9090/web/download/icon_xiaoshuo.png', 'http://127.0.0.1:9090/web/download/d09269fe2bfb48e98171deaac193baf9.png', 0, 2, 1, 1);
INSERT INTO `book_type` VALUES (3, '历史', '历史、传记、考古等', 'http://127.0.0.1:9090/web/download/icon_lishi.png', 'http://127.0.0.1:9090/web/download/6e4b0f8e191b49828764615e218f5bd2.png', 0, 3, 1, 0);
INSERT INTO `book_type` VALUES (4, '科技', '计算机、人工智能、互联网等', 'http://127.0.0.1:9090/web/download/ae8cb43a94864f4da0fc9f9687ffa857.png', 'http://127.0.0.1:9090/web/download/de5a82ab24094440bb9ddbb4902bfb4f.png', 0, 4, 1, 0);
INSERT INTO `book_type` VALUES (5, '哲学', '哲学思想、逻辑学等', 'http://127.0.0.1:9090/web/download/icon_zhexue.png', 'http://127.0.0.1:9090/web/download/e8bc69ec5c00477d9119276adeeb753b.png', 0, 5, 1, 0);
INSERT INTO `book_type` VALUES (6, '艺术', '绘画、音乐、设计等', 'http://127.0.0.1:9090/web/download/icon_yishu.png', 'http://127.0.0.1:9090/web/download/05558d2702a84b1dbf5c11763780ec18.png', 0, 6, 1, 0);
INSERT INTO `book_type` VALUES (7, '少儿', '儿童绘本、少儿文学等', 'http://127.0.0.1:9090/web/download/icon_shaoer.png', 'http://127.0.0.1:9090/web/download/35e9f194a7b549099030a4d2eba31894.png', 0, 7, 1, 1);
INSERT INTO `book_type` VALUES (8, '教育', '教育理论、学习方法等', 'http://127.0.0.1:9090/web/download/icon_jiaoyu.png', 'http://127.0.0.1:9090/web/download/3ccc84777b19479ca3ea58da552458ca.png', 0, 8, 1, 0);
INSERT INTO `book_type` VALUES (9, '生活', '生活百科、健康、旅游等', 'http://127.0.0.1:9090/web/download/icon_shenghuo.png', 'http://127.0.0.1:9090/web/download/24619059a3b547a2955ebd199e2994c5.png', 0, 9, 1, 0);
INSERT INTO `book_type` VALUES (10, '科幻小说', '科幻题材小说', 'http://127.0.0.1:9090/web/download/icon_kehuan.png', 'http://127.0.0.1:9090/web/download/9ea02c29be9b481c8da2ab96aa94a104.png', 2, 1, 1, 1);
INSERT INTO `book_type` VALUES (11, '悬疑小说', '悬疑、推理小说', 'http://127.0.0.1:9090/web/download/icon_xuanyi.png', 'http://127.0.0.1:9090/web/download/4275f2f1e6fe46c88a58357b4ad6ab87.png', 2, 2, 1, 0);
INSERT INTO `book_type` VALUES (12, '中国文学', '中国文学作品', 'http://127.0.0.1:9090/web/download/icon_zhongguo.png', 'http://127.0.0.1:9090/web/download/bd082699a0884b0da4dc4fc73a2793c0.png', 1, 1, 1, 0);
INSERT INTO `book_type` VALUES (13, '外国文学', '外国文学作品', 'http://127.0.0.1:9090/web/download/icon_waiguo.png', 'http://127.0.0.1:9090/web/download/ff6a41f45d154145abb8553b764858c4.png', 1, 2, 1, 0);

-- ----------------------------
-- Table structure for book_type_rel
-- ----------------------------
DROP TABLE IF EXISTS `book_type_rel`;
CREATE TABLE `book_type_rel`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `type_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_book_type`(`book_id` ASC, `type_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of book_type_rel
-- ----------------------------
INSERT INTO `book_type_rel` VALUES (4, 1, 22);
INSERT INTO `book_type_rel` VALUES (5, 1, 24);
INSERT INTO `book_type_rel` VALUES (6, 3, 24);
INSERT INTO `book_type_rel` VALUES (1, 4, 23);
INSERT INTO `book_type_rel` VALUES (2, 5, 23);
INSERT INTO `book_type_rel` VALUES (3, 6, 23);
INSERT INTO `book_type_rel` VALUES (7, 7, 23);
INSERT INTO `book_type_rel` VALUES (8, 9, 23);
INSERT INTO `book_type_rel` VALUES (12, 21, 7);
INSERT INTO `book_type_rel` VALUES (13, 22, 7);
INSERT INTO `book_type_rel` VALUES (14, 23, 7);

-- ----------------------------
-- Table structure for borrow_record
-- ----------------------------
DROP TABLE IF EXISTS `borrow_record`;
CREATE TABLE `borrow_record`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '借阅记录ID',
  `no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '借阅单号（唯一编号）',
  `stock_id` int NOT NULL COMMENT '库存ID（关联book_stock表）',
  `book_id` int NOT NULL COMMENT '图书ID（关联book表）',
  `book_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图书名称（冗余字段）',
  `book_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图书封面（冗余字段）',
  `from_user_id` int NOT NULL COMMENT '图书所有者ID（借出人/卖家）',
  `to_user_id` int NOT NULL COMMENT '借阅人ID（借入人/买家）',
  `borrow_date` datetime NULL DEFAULT NULL COMMENT '实际借出日期',
  `due_date` datetime NULL DEFAULT NULL COMMENT '应归还日期',
  `return_date` datetime NULL DEFAULT NULL COMMENT '实际归还日期',
  `extend_count` int NULL DEFAULT 0 COMMENT '续借次数',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '待审核' COMMENT '借阅状态：待审核/借阅中/已归还/逾期/拒绝/已损坏',
  `borrower_rating` int NULL DEFAULT NULL COMMENT '借阅人评分（1-5分，评价图书所有者）',
  `borrower_review` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '借阅人评价内容',
  `owner_rating` int NULL DEFAULT NULL COMMENT '图书所有者评分（1-5分，评价借阅人）',
  `owner_review` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图书所有者评价内容',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_no`(`no` ASC) USING BTREE,
  INDEX `idx_book_id`(`book_id` ASC) USING BTREE,
  INDEX `idx_from_user_id`(`from_user_id` ASC) USING BTREE,
  INDEX `idx_to_user_id`(`to_user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_borrow_date`(`borrow_date` ASC) USING BTREE,
  INDEX `idx_due_date`(`due_date` ASC) USING BTREE,
  INDEX `idx_stock_id`(`stock_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '借阅记录表（替代订单表）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of borrow_record
-- ----------------------------
INSERT INTO `borrow_record` VALUES (1, 'BR20260701001', 2, 1, '活着', 'http://127.0.0.1:9090/web/download/huozhe.jpg', 1, 2, '2026-07-31 22:17:15', '2026-08-30 22:17:15', '2026-08-02 17:00:38', 0, '已归还', 5, '余华老师的作品真的太震撼了！', NULL, NULL, NULL, '2026-07-01 10:00:00', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (2, 'BR20260702002', 5, 2, '三体', 'http://127.0.0.1:9090/web/download/santi.jpg', 2, 3, '2026-07-02 14:00:00', '2026-08-01 14:00:00', '2026-08-02 16:49:08', 0, '已归还', 5, '强烈推荐，脑洞大开', NULL, NULL, NULL, '2026-07-02 10:00:00', '2026-08-02 16:04:46');
INSERT INTO `borrow_record` VALUES (3, 'BR20260703003', 8, 3, '百年孤独', 'http://127.0.0.1:9090/web/download/bainian.jpg', 3, 4, '2026-07-03 14:00:00', '2026-08-02 14:00:00', NULL, 0, '借阅中', NULL, NULL, NULL, NULL, NULL, '2026-07-03 10:00:00', '2026-08-02 17:00:38');
INSERT INTO `borrow_record` VALUES (4, 'BR20260704004', 10, 4, '平凡的世界', 'http://127.0.0.1:9090/web/download/pingfan.jpg', 1, 3, '2026-07-04 14:00:00', '2026-08-03 14:00:00', '2026-08-01 16:53:31', 0, '已归还', 4, '感觉很不错，很透彻', NULL, NULL, NULL, '2026-07-04 10:00:00', '2026-08-01 17:00:30');
INSERT INTO `borrow_record` VALUES (5, 'BR20260705005', 11, 5, '解忧杂货店', 'http://127.0.0.1:9090/web/download/jieyou.jpg', 2, 1, '2026-07-05 14:00:00', '2026-08-04 14:00:00', NULL, 0, '借阅中', NULL, NULL, NULL, NULL, NULL, '2026-07-05 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `borrow_record` VALUES (7, '20260731235116999672984', 7, 3, '百年孤独', 'http://127.0.0.1:9090/web/download/bainian.jpg', 3, 1, NULL, NULL, NULL, 0, '拒绝', NULL, NULL, NULL, NULL, '张三 13800000001 浙江省/杭州市/滨江区 滨江区长河街道江汉路1649号', '2026-07-31 23:51:17', '2026-08-02 17:00:38');
INSERT INTO `borrow_record` VALUES (8, '20260801151117516438834', 12, 6, '白夜行', 'http://127.0.0.1:9090/web/download/baiyexing.jpg', 3, 1, '2026-08-01 15:17:26', '2026-08-31 15:17:26', '2026-08-08 17:57:35', 0, '已归还', 5, '这本书的内容很不错！！！', NULL, NULL, '张三 13800000001 浙江省/杭州市/滨江区 滨江区长河街道江汉路1649号', '2026-08-01 15:11:17', '2026-08-08 17:57:52');
INSERT INTO `borrow_record` VALUES (9, '20260801152203845885546', 9, 4, '平凡的世界', 'http://127.0.0.1:9090/web/download/pingfan.jpg', 1, 2, NULL, NULL, NULL, 0, '拒绝', NULL, NULL, NULL, NULL, '张三 13800000001 浙江省/杭州市/滨江区 滨江区长河街道江汉路1649号', '2026-08-01 15:22:03', '2026-08-02 17:00:38');
INSERT INTO `borrow_record` VALUES (10, '20260801162023841254866', 13, 7, '明朝那些事儿', 'http://127.0.0.1:9090/web/download/mingchao.jpg', 4, 3, NULL, NULL, NULL, 0, '待审核', NULL, NULL, NULL, NULL, '王五 13800000003 上海市/市辖区/浦东新区 浦东新区世纪大道88号', '2026-08-01 16:20:23', '2026-08-02 17:00:38');
INSERT INTO `borrow_record` VALUES (11, 'BR20260801024', 23, 24, '瓦尔登湖', 'http://127.0.0.1:9090/web/download/waerdenghu.jpg', 1, 2, '2026-08-01 18:00:00', '2026-08-31 18:00:00', NULL, 0, '借阅中', NULL, NULL, NULL, NULL, '李四 13800000002 北京市/市辖区/朝阳区 朝阳区望京街道阜通东大街1号', '2026-08-02 01:25:52', '2026-08-02 17:00:38');
INSERT INTO `borrow_record` VALUES (12, 'BR20260801027', 26, 27, '局外人', 'http://127.0.0.1:9090/web/download/juwairen.jpg', 1, 3, '2026-08-01 18:10:00', '2026-08-31 18:10:00', NULL, 0, '借阅中', NULL, NULL, NULL, NULL, '王五 13800000003 上海市/市辖区/浦东新区 浦东新区世纪大道88号', '2026-08-02 01:25:52', '2026-08-02 17:00:38');
INSERT INTO `borrow_record` VALUES (13, 'BR20260801036', 35, 36, '学习之道', 'http://127.0.0.1:9090/web/download/xuexizhidao.jpg', 1, 4, '2026-08-08 17:57:23', '2026-09-07 17:57:23', NULL, 0, '借阅中', NULL, NULL, NULL, NULL, '赵六 13800000004 广东省/广州市/天河区 天河区体育西路189号', '2026-08-02 01:25:52', '2026-08-02 17:00:38');
INSERT INTO `borrow_record` VALUES (14, 'BR20260801039', 38, 39, '流浪地球', 'http://127.0.0.1:9090/web/download/liulang.jpg', 1, 5, '2026-08-01 18:20:00', '2026-08-31 18:20:00', NULL, 0, '已归还', 5, '很有启发，打开了新思路', NULL, NULL, '孙七 13800000005 浙江省/杭州市/西湖区 西湖区文三路478号', '2026-08-02 01:25:52', '2026-08-02 16:04:46');
INSERT INTO `borrow_record` VALUES (15, '20260526144746000201', 9, 4, '平凡的世界', 'http://127.0.0.1:9090/web/download/pingfan.jpg', 3, 1, '2026-05-06 14:47:46', '2026-05-21 14:47:46', '2026-05-26 14:47:46', 0, '已归还', 5, '中国科幻的巅峰之作！', NULL, NULL, NULL, '2026-05-26 14:47:46', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (16, '20260601144746000303', 16, 9, '算法导论', 'http://127.0.0.1:9090/web/download/suanfa.jpg', 5, 3, '2026-05-12 14:47:46', '2026-05-27 14:47:46', '2026-06-01 14:47:46', 0, '已归还', 5, '历史写得太有意思了。', NULL, NULL, NULL, '2026-06-01 14:47:46', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (17, '20260730180000000404', 39, 15, '食物：味道的历史', 'http://127.0.0.1:9090/web/download/foodhistory.jpg', 1, 4, '2026-07-10 18:00:00', '2026-07-25 18:00:00', '2026-07-30 18:00:00', 0, '已归还', 5, '朋友推荐的，果然没让我失望。', NULL, NULL, NULL, '2026-07-30 18:00:00', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (18, '20260726200000000501', 24, 25, '沙之书', 'http://127.0.0.1:9090/web/download/shazhishu.jpg', 8, 1, '2026-07-06 20:00:00', '2026-07-21 20:00:00', '2026-07-26 20:00:00', 0, '已归还', 4, '观点很清晰，笔记做了不少。', NULL, NULL, NULL, '2026-07-26 20:00:00', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (19, '20260729170000000605', 25, 26, '湘行散记', 'http://127.0.0.1:9090/web/download/xiangxingsanji.jpg', 1, 5, '2026-07-09 17:00:00', '2026-07-24 17:00:00', '2026-07-29 17:00:00', 0, '已归还', 5, '适合周末安静读完。', NULL, NULL, NULL, '2026-07-29 17:00:00', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (20, '20260802190000001104', 28, 29, '苔丝', 'http://127.0.0.1:9090/web/download/taisi.jpg', 5, 4, '2026-07-13 19:00:00', '2026-07-28 19:00:00', '2026-08-02 19:00:00', 0, '已归还', 4, '看完想马上再借下一本同类书。', NULL, NULL, NULL, '2026-08-02 19:00:00', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (21, '20260728130000001304', 18, 10, '人工智能：一种现代方法', 'http://127.0.0.1:9090/web/download/ai.jpg', 5, 4, '2026-07-08 13:00:00', '2026-07-23 13:00:00', '2026-07-28 13:00:00', 0, '已归还', 3, '书有点旧了，但是不影响看', NULL, NULL, NULL, '2026-07-28 13:00:00', '2026-08-02 17:11:28');
INSERT INTO `borrow_record` VALUES (22, '20260808175713540301664', 7, 3, '百年孤独', 'http://127.0.0.1:9090/web/download/bainian.jpg', 3, 1, '2026-08-08 18:10:31', '2026-09-07 18:10:31', NULL, 0, '借阅中', NULL, NULL, NULL, NULL, '张三 13800000001 浙江省/杭州市/滨江区 滨江区长河街道江汉路1649号', '2026-08-08 17:57:13', '2026-08-08 17:57:13');

-- ----------------------------
-- Table structure for chat
-- ----------------------------
DROP TABLE IF EXISTS `chat`;
CREATE TABLE `chat`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '聊天记录ID',
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '聊天内容',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'text' COMMENT '消息类型：text-文字/image-图片/file-文件',
  `time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发送时间',
  `from_user_id` int NULL DEFAULT NULL COMMENT '发送者ID（关联sys_user表）',
  `to_user_id` int NULL DEFAULT NULL COMMENT '接收者ID（关联sys_user表）',
  `is_read` tinyint NULL DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_from_user`(`from_user_id` ASC) USING BTREE,
  INDEX `idx_to_user`(`to_user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '聊天管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of chat
-- ----------------------------
INSERT INTO `chat` VALUES (18, '你好，想问下这本书内容多吗', '文字', '2026/8/2 16:50:50', 3, 1, 1);
INSERT INTO `chat` VALUES (19, '书里的内容讲解的详细嘛', '文字', '2026/8/2 17:25:35', 1, 4, 0);
INSERT INTO `chat` VALUES (20, '想问一下这本书怎么样', '文字', '2026/8/8 18:04:08', 1, 2, 1);
INSERT INTO `chat` VALUES (21, '讲的内容很有趣', '文字', '2026/8/8 18:04:41', 2, 1, 0);

-- ----------------------------
-- Table structure for collect
-- ----------------------------
DROP TABLE IF EXISTS `collect`;
CREATE TABLE `collect`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` int NULL DEFAULT NULL COMMENT '收藏用户ID（关联sys_user表）',
  `book_id` int NULL DEFAULT NULL COMMENT '收藏图书ID（关联book表）',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收藏备注：想读/在读/已读',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_book`(`user_id` ASC, `book_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_book_id`(`book_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图书收藏表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of collect
-- ----------------------------
INSERT INTO `collect` VALUES (1, 1, 1, '想读', '2026-07-10 10:00:00');
INSERT INTO `collect` VALUES (2, 1, 2, '在读', '2026-07-11 10:00:00');
INSERT INTO `collect` VALUES (3, 1, 3, '已读', '2026-07-12 10:00:00');
INSERT INTO `collect` VALUES (4, 2, 1, '想读', '2026-07-13 10:00:00');
INSERT INTO `collect` VALUES (5, 2, 4, '在读', '2026-07-14 10:00:00');
INSERT INTO `collect` VALUES (6, 2, 7, '想读', '2026-07-15 10:00:00');
INSERT INTO `collect` VALUES (7, 3, 2, '已读', '2026-07-16 10:00:00');
INSERT INTO `collect` VALUES (8, 3, 5, '想读', '2026-07-17 10:00:00');
INSERT INTO `collect` VALUES (9, 3, 7, '在读', '2026-07-18 10:00:00');
INSERT INTO `collect` VALUES (10, 4, 1, '想读', '2026-07-19 10:00:00');
INSERT INTO `collect` VALUES (11, 4, 6, '想读', '2026-07-20 10:00:00');
INSERT INTO `collect` VALUES (12, 5, 3, '在读', '2026-07-21 10:00:00');
INSERT INTO `collect` VALUES (13, 5, 4, '想读', '2026-07-22 10:00:00');
INSERT INTO `collect` VALUES (22, 5, 24, '在读', '2026-07-27 19:00:00');
INSERT INTO `collect` VALUES (23, 3, 24, '在读', '2026-07-28 03:00:00');
INSERT INTO `collect` VALUES (24, 1, 24, '已读', '2026-07-27 00:00:00');
INSERT INTO `collect` VALUES (25, 5, 25, '想读', '2026-07-22 16:00:00');
INSERT INTO `collect` VALUES (26, 4, 25, '已读', '2026-07-27 13:00:00');
INSERT INTO `collect` VALUES (27, 3, 25, '已读', '2026-07-25 21:00:00');
INSERT INTO `collect` VALUES (28, 2, 25, '已读', '2026-07-21 23:00:00');
INSERT INTO `collect` VALUES (29, 1, 25, '已读', '2026-07-26 01:00:00');
INSERT INTO `collect` VALUES (30, 4, 26, '已读', '2026-07-25 22:00:00');
INSERT INTO `collect` VALUES (31, 1, 26, '在读', '2026-08-01 12:00:00');
INSERT INTO `collect` VALUES (32, 4, 27, '想读', '2026-07-29 17:00:00');
INSERT INTO `collect` VALUES (33, 5, 28, '在读', '2026-07-25 01:00:00');
INSERT INTO `collect` VALUES (34, 3, 28, '在读', '2026-07-30 02:00:00');
INSERT INTO `collect` VALUES (35, 2, 28, '在读', '2026-08-02 11:00:00');
INSERT INTO `collect` VALUES (37, 4, 29, '想读', '2026-07-29 16:00:00');
INSERT INTO `collect` VALUES (38, 3, 29, '在读', '2026-07-22 16:00:00');
INSERT INTO `collect` VALUES (39, 2, 29, '已读', '2026-07-27 13:00:00');
INSERT INTO `collect` VALUES (40, 1, 29, '在读', '2026-07-30 21:00:00');
INSERT INTO `collect` VALUES (41, 4, 30, '想读', '2026-07-27 13:00:00');
INSERT INTO `collect` VALUES (42, 3, 30, '想读', '2026-07-22 21:00:00');
INSERT INTO `collect` VALUES (43, 2, 30, '想读', '2026-07-23 19:00:00');
INSERT INTO `collect` VALUES (44, 1, 30, '已读', '2026-07-25 14:00:00');
INSERT INTO `collect` VALUES (45, 3, 31, '已读', '2026-07-26 19:00:00');
INSERT INTO `collect` VALUES (46, 2, 31, '已读', '2026-07-29 03:00:00');
INSERT INTO `collect` VALUES (47, 1, 31, '已读', '2026-07-21 16:00:00');
INSERT INTO `collect` VALUES (48, 5, 32, '已读', '2026-07-25 12:00:00');
INSERT INTO `collect` VALUES (49, 3, 32, '在读', '2026-07-27 21:00:00');
INSERT INTO `collect` VALUES (50, 2, 32, '已读', '2026-07-25 15:00:00');
INSERT INTO `collect` VALUES (51, 1, 32, '在读', '2026-07-31 20:00:00');
INSERT INTO `collect` VALUES (52, 5, 33, '已读', '2026-07-23 19:00:00');
INSERT INTO `collect` VALUES (53, 3, 33, '已读', '2026-07-27 17:00:00');
INSERT INTO `collect` VALUES (54, 2, 33, '已读', '2026-07-30 10:00:00');
INSERT INTO `collect` VALUES (55, 5, 34, '想读', '2026-07-31 21:00:00');
INSERT INTO `collect` VALUES (56, 4, 34, '想读', '2026-07-27 15:00:00');
INSERT INTO `collect` VALUES (57, 2, 34, '已读', '2026-07-22 10:00:00');
INSERT INTO `collect` VALUES (58, 4, 35, '在读', '2026-07-31 14:00:00');
INSERT INTO `collect` VALUES (59, 2, 35, '想读', '2026-07-24 17:00:00');
INSERT INTO `collect` VALUES (60, 5, 36, '已读', '2026-07-26 18:00:00');
INSERT INTO `collect` VALUES (61, 3, 36, '想读', '2026-08-03 01:00:00');
INSERT INTO `collect` VALUES (62, 2, 36, '想读', '2026-08-03 01:00:00');
INSERT INTO `collect` VALUES (63, 5, 37, '想读', '2026-07-24 11:00:00');
INSERT INTO `collect` VALUES (64, 4, 37, '在读', '2026-07-31 05:00:00');
INSERT INTO `collect` VALUES (65, 2, 37, '已读', '2026-07-22 16:00:00');
INSERT INTO `collect` VALUES (66, 1, 37, '在读', '2026-07-21 10:00:00');
INSERT INTO `collect` VALUES (67, 4, 38, '已读', '2026-07-21 01:00:00');
INSERT INTO `collect` VALUES (68, 2, 38, '在读', '2026-07-29 22:00:00');
INSERT INTO `collect` VALUES (69, 1, 38, '已读', '2026-07-24 21:00:00');
INSERT INTO `collect` VALUES (70, 1, 21, NULL, '2026-08-08 18:04:55');

-- ----------------------------
-- Table structure for config
-- ----------------------------
DROP TABLE IF EXISTS `config`;
CREATE TABLE `config`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键名',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '配置值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配置描述',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of config
-- ----------------------------
INSERT INTO `config` VALUES (1, 'borrow_days', '30', '默认借阅天数（30天）');
INSERT INTO `config` VALUES (2, 'max_borrow_count', '5', '用户最大同时借阅数量（5本）');
INSERT INTO `config` VALUES (3, 'extend_days', '15', '续借天数（15天）');
INSERT INTO `config` VALUES (4, 'max_extend_count', '2', '最大续借次数（2次）');
INSERT INTO `config` VALUES (5, 'late_fee_per_day', '0.50', '逾期费用（元/天）');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告标题',
  `info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '公告内容',
  `time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-已下架，1-已发布',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序序号（越小越靠前）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '公告管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (1, '欢迎来到图书共享借阅平台', '在这里您可以免费借阅海量图书，分享阅读的快乐！请遵守借阅规则，按时归还图书。', '2026-07-01 10:00:00', 1, 1);
INSERT INTO `notice` VALUES (2, '新书推荐活动', '本月新上架100本热门图书，涵盖文学、科技、历史、少儿等多个类别，欢迎借阅！', '2026-07-15 10:00:00', 1, 2);
INSERT INTO `notice` VALUES (3, '关于逾期还书的说明', '请各位书友按时归还图书，逾期将影响信用积分（每逾期1天扣1分）。', '2026-07-20 10:00:00', 1, 3);

-- ----------------------------
-- Table structure for sys_admin
-- ----------------------------
DROP TABLE IF EXISTS `sys_admin`;
CREATE TABLE `sys_admin`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理员用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理员密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '管理员昵称',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '管理员头像URL',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '管理员邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '管理员手机号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '管理员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_admin
-- ----------------------------
INSERT INTO `sys_admin` VALUES (1, 'admin', 'admin123', '系统管理员', 'http://127.0.0.1:9090/web/download/3fe29f87d95c41fca08ec894e6ab3a0a.jpg', 'admin@book.com', '13800000000');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（登录账号）',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户昵称（显示名称）',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户头像URL',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '电子邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '账号状态：0-已封禁，1-正常',
  `credit_score` int NULL DEFAULT 100 COMMENT '信用积分（初始100分，逾期扣分）',
  `borrow_count` int NULL DEFAULT 0 COMMENT '累计借阅次数',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'zhangsan', '123456', '爱读书的张三', 'http://127.0.0.1:9090/web/download/a68a438da1ac401b8a474882c590aa4d.jpg', 'zhangsan@qq.com', '13800000333', 1, 100, 0, '2026-07-01 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `sys_user` VALUES (2, 'lisi', '123456', '书虫李四', 'http://127.0.0.1:9090/web/download/83145a3b6ab74dec9101f4fb190c1505.jpg', 'lisi@qq.com', '13800000002', 1, 95, 0, '2026-07-02 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `sys_user` VALUES (3, 'wangwu', '123456', '阅读者王五', 'http://127.0.0.1:9090/web/download/79b9a86351444e2397fc372198013718.jpg', 'wangwu@qq.com', '13800000003', 1, 100, 0, '2026-07-03 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `sys_user` VALUES (4, 'zhaoliu', '123456', '书友赵六', 'http://127.0.0.1:9090/web/download/ee838c907b0946fd82dc1a4a62d01350.webp', 'zhaoliu@qq.com', '13800000004', 1, 80, 0, '2026-07-04 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `sys_user` VALUES (5, 'sunqi', '123456', '悦读孙七', 'http://127.0.0.1:9090/web/download/99580a058815436a9a9ea3e8673bad52.jpg', 'sunqi@qq.com', '13800000005', 1, 100, 0, '2026-07-05 10:00:00', '2026-07-26 14:00:00');
INSERT INTO `sys_user` VALUES (8, 'taotao', '123456', '淘桃', 'http://127.0.0.1:9090/web/download/user2.jpg', 'taotao@qq.com', '13800000008', 1, 100, 0, '2026-08-02 17:04:40', '2026-08-02 17:04:40');

-- ----------------------------
-- Table structure for user_view_log
-- ----------------------------
DROP TABLE IF EXISTS `user_view_log`;
CREATE TABLE `user_view_log`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '浏览记录ID',
  `user_id` int NOT NULL COMMENT '用户ID（关联sys_user表）',
  `book_id` int NOT NULL COMMENT '浏览图书ID（关联book表）',
  `view_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
  `duration_seconds` int NULL DEFAULT 0 COMMENT '停留时长（秒）',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'IP地址',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_book_id`(`book_id` ASC) USING BTREE,
  INDEX `idx_view_time`(`view_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户浏览记录表（用于个性化推荐分析）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_view_log
-- ----------------------------
INSERT INTO `user_view_log` VALUES (1, 5, 24, '2026-07-29 20:00:00', 272, '192.168.1.105');
INSERT INTO `user_view_log` VALUES (2, 3, 24, '2026-08-02 20:00:00', 297, '192.168.1.182');
INSERT INTO `user_view_log` VALUES (3, 2, 24, '2026-07-31 12:00:00', 61, '192.168.1.196');
INSERT INTO `user_view_log` VALUES (4, 1, 24, '2026-08-03 02:00:00', 319, '192.168.1.110');
INSERT INTO `user_view_log` VALUES (5, 5, 25, '2026-07-31 13:00:00', 115, '192.168.1.157');
INSERT INTO `user_view_log` VALUES (6, 2, 25, '2026-08-01 11:00:00', 262, '192.168.1.86');
INSERT INTO `user_view_log` VALUES (7, 1, 25, '2026-08-01 11:00:00', 123, '192.168.1.44');
INSERT INTO `user_view_log` VALUES (8, 4, 26, '2026-07-31 08:00:00', 75, '192.168.1.149');
INSERT INTO `user_view_log` VALUES (9, 3, 26, '2026-07-28 12:00:00', 253, '192.168.1.45');
INSERT INTO `user_view_log` VALUES (10, 3, 27, '2026-08-01 08:00:00', 320, '192.168.1.168');
INSERT INTO `user_view_log` VALUES (11, 2, 27, '2026-08-02 21:00:00', 311, '192.168.1.14');
INSERT INTO `user_view_log` VALUES (12, 1, 27, '2026-07-30 09:00:00', 84, '192.168.1.148');
INSERT INTO `user_view_log` VALUES (13, 4, 28, '2026-07-28 22:00:00', 293, '192.168.1.118');
INSERT INTO `user_view_log` VALUES (14, 3, 28, '2026-08-02 01:00:00', 129, '192.168.1.94');
INSERT INTO `user_view_log` VALUES (15, 2, 28, '2026-07-29 10:00:00', 222, '192.168.1.192');
INSERT INTO `user_view_log` VALUES (16, 1, 28, '2026-07-30 12:00:00', 212, '192.168.1.118');
INSERT INTO `user_view_log` VALUES (17, 3, 29, '2026-07-30 10:00:00', 102, '192.168.1.180');
INSERT INTO `user_view_log` VALUES (18, 2, 29, '2026-07-28 11:00:00', 133, '192.168.1.55');
INSERT INTO `user_view_log` VALUES (19, 1, 29, '2026-08-02 03:00:00', 231, '192.168.1.182');
INSERT INTO `user_view_log` VALUES (20, 5, 30, '2026-08-02 20:00:00', 319, '192.168.1.63');
INSERT INTO `user_view_log` VALUES (21, 4, 30, '2026-07-31 03:00:00', 287, '192.168.1.167');
INSERT INTO `user_view_log` VALUES (22, 3, 30, '2026-07-30 09:00:00', 36, '192.168.1.197');
INSERT INTO `user_view_log` VALUES (23, 2, 30, '2026-07-29 16:00:00', 325, '192.168.1.192');
INSERT INTO `user_view_log` VALUES (24, 1, 30, '2026-07-30 03:00:00', 32, '192.168.1.139');
INSERT INTO `user_view_log` VALUES (25, 5, 31, '2026-07-29 07:00:00', 166, '192.168.1.87');
INSERT INTO `user_view_log` VALUES (26, 4, 31, '2026-08-02 01:00:00', 183, '192.168.1.95');
INSERT INTO `user_view_log` VALUES (27, 3, 31, '2026-08-02 00:00:00', 156, '192.168.1.10');
INSERT INTO `user_view_log` VALUES (28, 5, 32, '2026-08-02 22:00:00', 60, '192.168.1.144');
INSERT INTO `user_view_log` VALUES (29, 4, 32, '2026-07-29 11:00:00', 298, '192.168.1.22');
INSERT INTO `user_view_log` VALUES (30, 3, 32, '2026-08-03 07:00:00', 321, '192.168.1.195');
INSERT INTO `user_view_log` VALUES (31, 4, 33, '2026-07-28 23:00:00', 36, '192.168.1.43');
INSERT INTO `user_view_log` VALUES (32, 2, 33, '2026-07-31 01:00:00', 237, '192.168.1.55');
INSERT INTO `user_view_log` VALUES (33, 1, 33, '2026-08-01 00:00:00', 270, '192.168.1.190');
INSERT INTO `user_view_log` VALUES (34, 5, 34, '2026-08-01 23:00:00', 305, '192.168.1.134');
INSERT INTO `user_view_log` VALUES (35, 4, 34, '2026-08-02 18:00:00', 159, '192.168.1.187');
INSERT INTO `user_view_log` VALUES (36, 3, 34, '2026-07-29 03:00:00', 280, '192.168.1.169');
INSERT INTO `user_view_log` VALUES (37, 2, 34, '2026-08-02 19:00:00', 169, '192.168.1.185');
INSERT INTO `user_view_log` VALUES (38, 1, 34, '2026-07-31 04:00:00', 98, '192.168.1.115');
INSERT INTO `user_view_log` VALUES (39, 4, 35, '2026-07-29 00:00:00', 105, '192.168.1.56');
INSERT INTO `user_view_log` VALUES (40, 3, 35, '2026-07-30 19:00:00', 115, '192.168.1.20');
INSERT INTO `user_view_log` VALUES (41, 2, 35, '2026-08-02 08:00:00', 226, '192.168.1.39');
INSERT INTO `user_view_log` VALUES (42, 5, 36, '2026-07-29 02:00:00', 230, '192.168.1.25');
INSERT INTO `user_view_log` VALUES (43, 4, 36, '2026-07-31 10:00:00', 177, '192.168.1.53');
INSERT INTO `user_view_log` VALUES (44, 3, 36, '2026-07-30 08:00:00', 306, '192.168.1.131');
INSERT INTO `user_view_log` VALUES (45, 2, 36, '2026-07-31 08:00:00', 157, '192.168.1.16');
INSERT INTO `user_view_log` VALUES (46, 5, 37, '2026-07-30 02:00:00', 107, '192.168.1.14');
INSERT INTO `user_view_log` VALUES (47, 4, 37, '2026-07-31 08:00:00', 135, '192.168.1.141');
INSERT INTO `user_view_log` VALUES (48, 3, 37, '2026-07-28 08:00:00', 221, '192.168.1.44');
INSERT INTO `user_view_log` VALUES (49, 1, 37, '2026-07-28 22:00:00', 318, '192.168.1.208');
INSERT INTO `user_view_log` VALUES (50, 5, 38, '2026-07-31 03:00:00', 255, '192.168.1.86');
INSERT INTO `user_view_log` VALUES (51, 3, 38, '2026-08-01 05:00:00', 198, '192.168.1.28');
INSERT INTO `user_view_log` VALUES (52, 1, 38, '2026-08-02 07:00:00', 227, '192.168.1.72');
INSERT INTO `user_view_log` VALUES (53, 5, 39, '2026-08-02 08:00:00', 98, '192.168.1.28');

-- ----------------------------
-- View structure for v_book_stock_summary
-- ----------------------------
DROP VIEW IF EXISTS `v_book_stock_summary`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_book_stock_summary` AS select `b`.`id` AS `book_id`,`b`.`name` AS `book_name`,`b`.`author` AS `author`,`b`.`img` AS `img`,`b`.`user_id` AS `user_id`,`u`.`nickname` AS `owner_nickname`,`b`.`view_count` AS `view_count`,`b`.`status` AS `book_status`,`b`.`quality` AS `quality`,`b`.`publish_date` AS `publish_date`,`b`.`borrow_count` AS `borrow_count`,`b`.`favorite_count` AS `favorite_count`,`b`.`avg_rating` AS `avg_rating`,count(`s`.`id`) AS `total_copies`,sum((case when (`s`.`status` = 0) then 1 else 0 end)) AS `available_copies`,sum((case when (`s`.`status` = 1) then 1 else 0 end)) AS `borrowed_copies`,sum((case when (`s`.`status` = 2) then 1 else 0 end)) AS `maintenance_copies`,sum((case when (`s`.`status` = 3) then 1 else 0 end)) AS `damaged_copies`,sum((case when (`s`.`status` = 4) then 1 else 0 end)) AS `offline_copies` from ((`book` `b` left join `book_stock` `s` on((`b`.`id` = `s`.`book_id`))) left join `sys_user` `u` on((`b`.`user_id` = `u`.`id`))) group by `b`.`id`;

-- ----------------------------
-- View structure for v_favorite_rank
-- ----------------------------
DROP VIEW IF EXISTS `v_favorite_rank`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_favorite_rank` AS select `b`.`id` AS `book_id`,`b`.`name` AS `book_name`,`b`.`author` AS `author`,`b`.`img` AS `img`,`b`.`favorite_count` AS `favorite_count`,`b`.`borrow_count` AS `borrow_count`,`b`.`avg_rating` AS `avg_rating`,`b`.`user_id` AS `user_id`,`u`.`nickname` AS `owner_nickname`,row_number() OVER (ORDER BY `b`.`favorite_count` desc )  AS `rank_position` from (`book` `b` left join `sys_user` `u` on((`b`.`user_id` = `u`.`id`))) where (`b`.`status` <> '已下架') order by `b`.`favorite_count` desc limit 20;

-- ----------------------------
-- View structure for v_recommend_rank
-- ----------------------------
DROP VIEW IF EXISTS `v_recommend_rank`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_recommend_rank` AS select 'hot_borrow' AS `rank_type`,'热门借阅榜' AS `rank_name`,`b`.`id` AS `book_id`,`b`.`name` AS `book_name`,`b`.`author` AS `author`,`b`.`img` AS `img`,`b`.`borrow_count` AS `score_value`,`b`.`favorite_count` AS `favorite_count`,`b`.`avg_rating` AS `avg_rating`,`u`.`nickname` AS `owner_nickname`,row_number() OVER (ORDER BY `b`.`borrow_count` desc )  AS `rank_position` from (`book` `b` left join `sys_user` `u` on((`b`.`user_id` = `u`.`id`))) where (`b`.`status` <> '已下架') union all select 'high_rating' AS `rank_type`,'高分好评榜' AS `rank_name`,`b`.`id` AS `book_id`,`b`.`name` AS `book_name`,`b`.`author` AS `author`,`b`.`img` AS `img`,`b`.`avg_rating` AS `score_value`,`b`.`favorite_count` AS `favorite_count`,`b`.`avg_rating` AS `avg_rating`,`u`.`nickname` AS `owner_nickname`,row_number() OVER (ORDER BY `b`.`avg_rating` desc )  AS `rank_position` from (`book` `b` left join `sys_user` `u` on((`b`.`user_id` = `u`.`id`))) where ((`b`.`status` <> '已下架') and (`b`.`avg_rating` > 0)) union all select 'most_collect' AS `rank_type`,'最多收藏榜' AS `rank_name`,`b`.`id` AS `book_id`,`b`.`name` AS `book_name`,`b`.`author` AS `author`,`b`.`img` AS `img`,`b`.`favorite_count` AS `score_value`,`b`.`favorite_count` AS `favorite_count`,`b`.`avg_rating` AS `avg_rating`,`u`.`nickname` AS `owner_nickname`,row_number() OVER (ORDER BY `b`.`favorite_count` desc )  AS `rank_position` from (`book` `b` left join `sys_user` `u` on((`b`.`user_id` = `u`.`id`))) where (`b`.`status` <> '已下架') union all select 'most_view' AS `rank_type`,'最多浏览榜' AS `rank_name`,`b`.`id` AS `book_id`,`b`.`name` AS `book_name`,`b`.`author` AS `author`,`b`.`img` AS `img`,`b`.`view_count` AS `score_value`,`b`.`favorite_count` AS `favorite_count`,`b`.`avg_rating` AS `avg_rating`,`u`.`nickname` AS `owner_nickname`,row_number() OVER (ORDER BY `b`.`view_count` desc )  AS `rank_position` from (`book` `b` left join `sys_user` `u` on((`b`.`user_id` = `u`.`id`))) where (`b`.`status` <> '已下架') union all select 'new_book' AS `rank_type`,'新书上架榜' AS `rank_name`,`b`.`id` AS `book_id`,`b`.`name` AS `book_name`,`b`.`author` AS `author`,`b`.`img` AS `img`,unix_timestamp(`b`.`create_time`) AS `score_value`,`b`.`favorite_count` AS `favorite_count`,`b`.`avg_rating` AS `avg_rating`,`u`.`nickname` AS `owner_nickname`,row_number() OVER (ORDER BY `b`.`create_time` desc )  AS `rank_position` from (`book` `b` left join `sys_user` `u` on((`b`.`user_id` = `u`.`id`))) where (`b`.`status` <> '已下架');

-- ----------------------------
-- Triggers structure for table book_rating
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_rating_update_avg`;
delimiter ;;
CREATE TRIGGER `trg_rating_update_avg` AFTER INSERT ON `book_rating` FOR EACH ROW BEGIN
  UPDATE book b
  SET b.avg_rating = (
    SELECT ROUND(AVG(score), 2) FROM book_rating WHERE book_id = NEW.book_id
  )
  WHERE b.id = NEW.book_id;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table borrow_record
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_borrow_update_stats`;
delimiter ;;
CREATE TRIGGER `trg_borrow_update_stats` AFTER INSERT ON `borrow_record` FOR EACH ROW BEGIN
  -- 只有当状态为"借阅中"时才更新统计
  IF NEW.status = '借阅中' THEN
    -- 更新图书借阅次数
    UPDATE book SET borrow_count = borrow_count + 1 WHERE id = NEW.book_id;
    -- 更新库存状态为已借出
    UPDATE book_stock SET status = 1, borrow_record_id = NEW.id WHERE id = NEW.stock_id;
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table borrow_record
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_return_update_stock`;
delimiter ;;
CREATE TRIGGER `trg_return_update_stock` AFTER UPDATE ON `borrow_record` FOR EACH ROW BEGIN
  -- 当状态变为"已归还"时
  IF NEW.status = '已归还' AND OLD.status != '已归还' THEN
    -- 更新库存状态为可借
    UPDATE book_stock SET status = 0, borrow_record_id = NULL WHERE id = NEW.stock_id;
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table collect
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_collect_update_count`;
delimiter ;;
CREATE TRIGGER `trg_collect_update_count` AFTER INSERT ON `collect` FOR EACH ROW BEGIN
  UPDATE book SET favorite_count = favorite_count + 1 WHERE id = NEW.book_id;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table collect
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_uncollect_update_count`;
delimiter ;;
CREATE TRIGGER `trg_uncollect_update_count` AFTER DELETE ON `collect` FOR EACH ROW BEGIN
  UPDATE book SET favorite_count = favorite_count - 1 WHERE id = OLD.book_id;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
