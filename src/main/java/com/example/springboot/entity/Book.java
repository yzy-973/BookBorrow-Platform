package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 图书实体。
 * <p>
 * 业务状态约定：{@code 可借阅}/{@code 已借出} 一般由库存可用册数推导；
 * {@code 维护中}/{@code 已下架} 为管理员手工状态，库存同步时不会覆盖。
 */
@Data
@TableName(value = "book")
public class Book {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private String name;

    private String img;

    private String imgList;

    private Integer typeId;

    private String author;

    private String publisher;

    private String isbn;

    private Integer publishYear;

    private String content;

    private String place;

    private Integer userId;

    private Integer viewCount;

    /** 可借阅 / 已借出 / 维护中 / 已下架 */
    private String status;

    private String quality;

    private String publishDate;

    private Integer borrowCount;

    private Integer favoriteCount;

    private Integer recommendCount;

    /** 借阅费（元 / 30 天） */
    private Double price;

    /** 图书原价（展示划线价，非支付金额） */
    private Double rePrice;

    private BigDecimal avgRating;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    /** 当前用户是否已收藏（非表字段） */
    @TableField(exist = false)
    private Boolean isCollected;

    /** 当前用户是否已推荐（非表字段） */
    @TableField(exist = false)
    private Boolean isRecommended;

    /** 库存总数（非表字段） */
    @TableField(exist = false)
    private Integer stockTotal;

    /** 可借库存数（非表字段） */
    @TableField(exist = false)
    private Integer stockAvailable;
}
