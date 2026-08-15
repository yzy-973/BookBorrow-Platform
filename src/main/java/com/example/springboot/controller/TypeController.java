package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.Type;
import com.example.springboot.service.IBookService;
import com.example.springboot.service.ITypeService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 图书分类控制器。
 * <p>
 * 首页推荐接口 {@code GET /type/front}：返回已启用且 isRecommend=1 的分类，
 * 并为每个分类附加本类及子类下浏览量靠前的可借图书。
 */
@RestController
@RequestMapping("/type")
public class TypeController {

    @Resource
    private ITypeService typeService;
    @Resource
    private IBookService bookService;

    @PostMapping
    public Result save(@RequestBody Type type) {
        return Result.success(typeService.saveOrUpdate(type));
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        return Result.success(typeService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(typeService.removeByIds(ids));
    }

    /** 首页推荐分类：含本类及子类下浏览量靠前的可借图书（顶级/子分类均可推荐） */
    @GetMapping("/front")
    public Result findFront() {
        LambdaQueryWrapper<Type> wrapper = new LambdaQueryWrapper<>();
        // 不限制 parentId：子分类开启「首页推荐」后也应出现在用户首页
        // 按 sortOrder、id 排序，取全部启用且已推荐的分类（首页网格可自适应多行）
        wrapper.eq(Type::getStatus, 1)
                .eq(Type::getIsRecommend, 1)
                .orderByAsc(Type::getSortOrder)
                .orderByAsc(Type::getId);
        List<Type> typeList = typeService.list(wrapper);
        for (Type type : typeList) {
            LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
            Integer typeId = type.getId();
            // 本分类或子分类下的图书
            queryWrapper.and(w -> w.eq(Book::getTypeId, typeId)
                            .or()
                            .inSql(Book::getTypeId, "select id from book_type where parent_id = " + typeId))
                    .eq(Book::getStatus, "可借阅")
                    .orderByDesc(Book::getViewCount)
                    .last("limit 3");
            type.setBookList(bookService.list(queryWrapper));
        }
        return Result.success(typeList);
    }

    @GetMapping
    public Result findAll() {
        return Result.success(typeService.list());
    }

    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        return Result.success(typeService.getById(id));
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {
        LambdaQueryWrapper<Type> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Type::getId);
        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Type::getName, keyword);
        }
        return Result.success(typeService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }
}
