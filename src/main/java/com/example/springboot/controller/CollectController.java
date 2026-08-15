package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.Collect;
import com.example.springboot.service.IBookService;
import com.example.springboot.service.ICollectService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 收藏控制器
 */
@RestController
@RequestMapping("/collect")
public class CollectController {

    @Resource
    private ICollectService collectService;
    @Resource
    private IBookService bookService;

    /** 切换收藏：已收藏则取消，未收藏则新增 */
    @PostMapping
    public Result save(@RequestBody Collect collect) {
        Account currentUser = TokenUtils.getCurrentUser();
        Integer bookId = collect.getBookId() != null ? collect.getBookId() : collect.getItemId();
        if (bookId == null) {
            return Result.error("400", "请选择图书");
        }
        LambdaQueryWrapper<Collect> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Collect::getUserId, currentUser.getId())
                .eq(Collect::getBookId, bookId);
        Collect exist = collectService.getOne(wrapper);
        Map<String, Object> data = new HashMap<>();
        if (exist != null) {
            collectService.removeById(exist.getId());
            decreaseFavorite(bookId);
            data.put("collected", false);
            data.put("count", favoriteCountOf(bookId));
            return Result.success(data);
        }
        Collect row = new Collect();
        row.setUserId(currentUser.getId());
        row.setBookId(bookId);
        collectService.save(row);
        increaseFavorite(bookId);
        data.put("collected", true);
        data.put("count", favoriteCountOf(bookId));
        return Result.success(data);
    }

    /** 按图书 ID 取消当前用户的收藏 */
    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        Account currentUser = TokenUtils.getCurrentUser();
        LambdaQueryWrapper<Collect> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Collect::getUserId, currentUser.getId());
        wrapper.eq(Collect::getBookId, id);
        boolean removed = collectService.remove(wrapper);
        if (removed) {
            decreaseFavorite(id);
        }
        return Result.success();
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(collectService.removeByIds(ids));
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum, @RequestParam Integer pageSize, @RequestParam(defaultValue = "") String keyword) {
        LambdaQueryWrapper<Collect> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Collect::getId);
        if (StrUtil.isNotBlank(keyword) && StrUtil.isNumeric(keyword)) {
            queryWrapper.eq(Collect::getUserId, Integer.valueOf(keyword));
        }
        return Result.success(collectService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

    private Integer favoriteCountOf(Integer bookId) {
        Book book = bookService.getById(bookId);
        return book == null || book.getFavoriteCount() == null ? 0 : book.getFavoriteCount();
    }

    private void increaseFavorite(Integer bookId) {
        if (bookId == null) {
            return;
        }
        Book book = bookService.getById(bookId);
        if (book != null) {
            book.setFavoriteCount((book.getFavoriteCount() == null ? 0 : book.getFavoriteCount()) + 1);
            bookService.updateById(book);
        }
    }

    private void decreaseFavorite(Integer bookId) {
        if (bookId == null) {
            return;
        }
        Book book = bookService.getById(bookId);
        if (book != null) {
            int count = book.getFavoriteCount() == null ? 0 : book.getFavoriteCount();
            book.setFavoriteCount(Math.max(0, count - 1));
            bookService.updateById(book);
        }
    }
}
