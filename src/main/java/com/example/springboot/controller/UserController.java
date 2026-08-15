package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.User;
import com.example.springboot.service.IUserService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/user")
public class UserController {

    @Resource
    private IUserService userService;

    @PostMapping
    public Result save(@RequestBody User user) {
        return Result.success(userService.saveOrUpdate(user));
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        return Result.success(userService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(userService.removeByIds(ids));
    }

    /** 公开简要信息：仅 id / 昵称 / 头像，供前台展示 */
    @GetMapping("/simple")
    public Result findSimple() {
        List<Map<String, Object>> list = userService.list().stream().map(u -> {
            Map<String, Object> row = new HashMap<>();
            row.put("id", u.getId());
            row.put("nickname", u.getNickname());
            row.put("avatarUrl", u.getAvatarUrl());
            return row;
        }).collect(Collectors.toList());
        return Result.success(list);
    }

    @GetMapping
    public Result findAll() {
        List<User> list = userService.list();
        list.forEach(this::maskSensitive);
        return Result.success(list);
    }

    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        User user = userService.getById(id);
        maskSensitive(user);
        return Result.success(user);
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum, @RequestParam Integer pageSize, @RequestParam(defaultValue = "") String keyword) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(User::getId);

        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(User::getNickname, keyword);
        }

        Page<User> page = userService.page(new Page<>(pageNum, pageSize), queryWrapper);
        if (page.getRecords() == null) {
            page.setRecords(new ArrayList<>());
        }
        page.getRecords().forEach(this::maskSensitive);
        return Result.success(page);
    }

    @PutMapping("/{id}/status")
    public Result updateStatus(@PathVariable Integer id, @RequestParam Integer status) {
        return userService.updateStatus(id, status);
    }

    @PutMapping("/batch/status")
    public Result batchUpdateStatus(@RequestBody Map<String, Object> params) {
        @SuppressWarnings("unchecked")
        List<Integer> ids = (List<Integer>) params.get("ids");
        Integer status = (Integer) params.get("status");
        return userService.batchUpdateStatus(ids, status);
    }

    private void maskSensitive(User user) {
        if (user == null) {
            return;
        }
        user.setPassword(null);
    }
}
