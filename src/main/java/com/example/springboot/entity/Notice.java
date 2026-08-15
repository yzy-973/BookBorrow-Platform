package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 公告实体
 */
@Data
@TableName(value = "notice")
public class Notice {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private String name;

    private String info;

    private LocalDateTime time;

    private Integer status;

    private Integer sortOrder;
}
