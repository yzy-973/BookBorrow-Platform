package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

/**
 * 登录账号公共字段（用户/管理员共用）
 */
@Data
public class Account {
    private Integer id;
    private String username;
    private String password;
    private String nickname;
    private String avatarUrl;

    /** 角色：ROLE_USER / ROLE_ADMIN（非表字段，登录后由 token 写入） */
    @TableField(exist = false)
    private String role;
    /** 修改密码时的新密码（非表字段） */
    @TableField(exist = false)
    private String newPassword;
    /** 登录成功后下发的 JWT（非表字段） */
    @TableField(exist = false)
    private String token;
}
