package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.BookRecommend;
import com.example.springboot.service.IBookRecommendService;
import com.example.springboot.service.IBookService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 我的推荐控制器
 */
@RestController
@RequestMapping("/recommend")
public class RecommendController {

    @Resource
    private IBookRecommendService bookRecommendService;
    @Resource
    private IBookService bookService;

    /** 我已推荐的图书 */
    @GetMapping("/my")
    public Result myBooks(@RequestParam(defaultValue = "") String keyword) {
        Account currentUser = TokenUtils.getCurrentUser();
        LambdaQueryWrapper<BookRecommend> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BookRecommend::getUserId, currentUser.getId()).orderByDesc(BookRecommend::getId);
        List<BookRecommend> recommends = bookRecommendService.list(wrapper);
        if (recommends.isEmpty()) {
            return Result.success(new ArrayList<>());
        }

        List<Integer> bookIds = recommends.stream().map(BookRecommend::getBookId).collect(Collectors.toList());
        Map<Integer, Book> bookMap = bookService.listByIds(bookIds).stream()
                .collect(Collectors.toMap(Book::getId, b -> b, (a, b) -> a));

        List<Map<String, Object>> result = new ArrayList<>();
        for (BookRecommend rec : recommends) {
            Book book = bookMap.get(rec.getBookId());
            if (book == null) {
                continue;
            }
            if (StrUtil.isNotBlank(keyword) && (book.getName() == null || !book.getName().contains(keyword))) {
                continue;
            }
            Map<String, Object> row = new HashMap<>();
            row.put("id", book.getId());
            row.put("name", book.getName());
            row.put("img", book.getImg());
            row.put("status", book.getStatus());
            row.put("author", book.getAuthor());
            row.put("userId", book.getUserId());
            row.put("price", book.getPrice());
            row.put("rePrice", book.getRePrice());
            row.put("recommended", true);
            result.add(row);
        }
        return Result.success(result);
    }

    /** 设为推荐 */
    @PostMapping
    public Result add(@RequestBody Map<String, Integer> body) {
        Account currentUser = TokenUtils.getCurrentUser();
        Integer bookId = body.get("bookId");
        // 部分调用方用 itemId 传图书主键
        if (bookId == null) {
            bookId = body.get("itemId");
        }
        if (bookId == null) {
            return Result.error("400", "请选择图书");
        }
        Book book = bookService.getById(bookId);
        if (book == null) {
            return Result.error("400", "图书不存在");
        }

        LambdaQueryWrapper<BookRecommend> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BookRecommend::getUserId, currentUser.getId())
                .eq(BookRecommend::getBookId, bookId);
        if (bookRecommendService.getOne(wrapper) != null) {
            return Result.success();
        }

        BookRecommend row = new BookRecommend();
        row.setUserId(currentUser.getId());
        row.setBookId(bookId);
        bookRecommendService.save(row);
        book.setRecommendCount((book.getRecommendCount() == null ? 0 : book.getRecommendCount()) + 1);
        bookService.updateById(book);
        return Result.success();
    }

    /** 取消推荐（按图书ID） */
    @DeleteMapping("/book/{bookId}")
    public Result cancelByBook(@PathVariable Integer bookId) {
        Account currentUser = TokenUtils.getCurrentUser();
        LambdaQueryWrapper<BookRecommend> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BookRecommend::getUserId, currentUser.getId())
                .eq(BookRecommend::getBookId, bookId);
        BookRecommend exist = bookRecommendService.getOne(wrapper);
        if (exist != null) {
            bookRecommendService.removeById(exist.getId());
            Book book = bookService.getById(bookId);
            if (book != null) {
                int count = book.getRecommendCount() == null ? 0 : book.getRecommendCount();
                book.setRecommendCount(Math.max(0, count - 1));
                bookService.updateById(book);
            }
        }
        return Result.success();
    }
}
