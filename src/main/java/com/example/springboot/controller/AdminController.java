package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Admin;
import com.example.springboot.service.IAdminService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员控制器
 */
@RestController
@RequestMapping("/admin")
public class AdminController {

    @Resource
    private IAdminService adminService;

    @PostMapping
    public Result save(@RequestBody Admin admin) {
        return Result.success(adminService.saveOrUpdate(admin));
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        return Result.success(adminService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(adminService.removeByIds(ids));
    }

    @GetMapping
    public Result findAll() {
        List<Admin> list = adminService.list();
        list.forEach(a -> a.setPassword(null));
        return Result.success(list);
    }

    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        Admin admin = adminService.getById(id);
        if (admin != null) {
            admin.setPassword(null);
        }
        return Result.success(admin);
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum, @RequestParam Integer pageSize, @RequestParam(defaultValue = "") String keyword) {

        LambdaQueryWrapper<Admin> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Admin::getId);

        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Admin::getNickname, keyword);
        }

        Page<Admin> page = adminService.page(new Page<>(pageNum, pageSize), queryWrapper);
        if (page.getRecords() != null) {
            page.getRecords().forEach(a -> a.setPassword(null));
        }
        return Result.success(page);
    }
}
