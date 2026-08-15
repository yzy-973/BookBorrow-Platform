package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 图书评论实体（表 book_comment 预留；当前业务评价走 book_rating / borrow_record）。
 */
@Data
@TableName("book_comment")
public class BookComment {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private Integer bookId;

    private Integer userId;

    private String content;

    private Integer likeCount;

    private Integer replyCount;

    private Integer parentId;

    private Integer status;

    private LocalDateTime createTime;
}
