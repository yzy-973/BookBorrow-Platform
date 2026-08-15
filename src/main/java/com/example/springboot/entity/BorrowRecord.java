package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 借阅记录实体
 */
@Data
@TableName(value = "borrow_record")
public class BorrowRecord {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private String no;

    private Integer stockId;

    private Integer bookId;

    private String bookName;

    private String bookImg;

    /** 图书所有者（借出人） */
    private Integer fromUserId;

    /** 借阅人 */
    private Integer toUserId;

    private LocalDateTime borrowDate;

    private LocalDateTime dueDate;

    private LocalDateTime returnDate;

    private Integer extendCount;

    private String status;

    private Integer borrowerRating;

    private String borrowerReview;

    private Integer ownerRating;

    private String ownerReview;

    private String remark;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    /** 申请借阅时前端传入的取书地址 ID，仅用于组装 remark，不落库 */
    @TableField(exist = false)
    private Integer addressId;
}
