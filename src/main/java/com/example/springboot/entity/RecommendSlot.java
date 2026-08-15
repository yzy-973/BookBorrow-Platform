package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 推荐位实体（运营配置的图书推荐槽位，如首页固定推荐位；
 * 与用户个人「推荐图书」{@link BookRecommend} 不同）。
 */
@Data
@TableName(value = "recommend_slot")
public class RecommendSlot {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private String slotName;

    private String slotCode;

    private Integer bookId;

    private Integer sortOrder;

    /** 0-禁用，1-启用 */
    private Integer status;

    private LocalDateTime startTime;

    private LocalDateTime endTime;

    private String remark;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    @TableField(exist = false)
    private String bookName;

    @TableField(exist = false)
    private String bookImg;

    @TableField(exist = false)
    private String bookStatus;
}
