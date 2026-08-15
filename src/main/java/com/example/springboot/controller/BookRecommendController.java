package com.example.springboot.controller;

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

import java.util.HashMap;
import java.util.Map;

/**
 * 图书推荐控制器（详情页推荐/取消切换）。
 * 与 {@link RecommendController} 分工：本类负责 toggle；后者负责「我的推荐」列表与按书取消。
 */
@RestController
@RequestMapping("/bookRecommend")
public class BookRecommendController {

    @Resource
    private IBookRecommendService bookRecommendService;
    @Resource
    private IBookService bookService;

    @PostMapping
    public Result toggle(@RequestBody Map<String, Integer> body) {
        Account currentUser = TokenUtils.getCurrentUser();
        Integer bookId = body.get("bookId");
        // 部分调用方用 itemId 传图书主键
        if (bookId == null) {
            bookId = body.get("itemId");
        }
        if (bookId == null) {
            return Result.error("400", "请选择图书");
        }

        LambdaQueryWrapper<BookRecommend> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BookRecommend::getUserId, currentUser.getId())
                .eq(BookRecommend::getBookId, bookId);
        BookRecommend exist = bookRecommendService.getOne(wrapper);
        Map<String, Object> data = new HashMap<>();
        if (exist != null) {
            bookRecommendService.removeById(exist.getId());
            decreaseRecommend(bookId);
            data.put("recommended", false);
            data.put("count", recommendCountOf(bookId));
            return Result.success(data);
        }

        BookRecommend row = new BookRecommend();
        row.setUserId(currentUser.getId());
        row.setBookId(bookId);
        bookRecommendService.save(row);
        increaseRecommend(bookId);
        data.put("recommended", true);
        data.put("count", recommendCountOf(bookId));
        return Result.success(data);
    }

    private Integer recommendCountOf(Integer bookId) {
        Book book = bookService.getById(bookId);
        return book == null || book.getRecommendCount() == null ? 0 : book.getRecommendCount();
    }

    private void increaseRecommend(Integer bookId) {
        Book book = bookService.getById(bookId);
        if (book != null) {
            book.setRecommendCount((book.getRecommendCount() == null ? 0 : book.getRecommendCount()) + 1);
            bookService.updateById(book);
        }
    }

    private void decreaseRecommend(Integer bookId) {
        Book book = bookService.getById(bookId);
        if (book != null) {
            int count = book.getRecommendCount() == null ? 0 : book.getRecommendCount();
            book.setRecommendCount(Math.max(0, count - 1));
            bookService.updateById(book);
        }
    }
}
