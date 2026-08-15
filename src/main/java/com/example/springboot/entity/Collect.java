package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 收藏实体
 */
@Data
@TableName(value = "collect")
public class Collect {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private Integer userId;

    private Integer bookId;

    private String remark;

    private LocalDateTime createTime;

    /**
     * 可选入参别名：部分前端用 itemId 传图书主键，写入时同步到 bookId。
     * 非表字段，仅参与反序列化。
     */
    @TableField(exist = false)
    private Integer itemId;

    public Integer getItemId() {
        return itemId != null ? itemId : bookId;
    }

    public void setItemId(Integer itemId) {
        this.itemId = itemId;
        if (itemId != null) {
            this.bookId = itemId;
        }
    }
}
