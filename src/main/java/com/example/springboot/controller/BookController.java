package com.example.springboot.controller;

import cn.hutool.core.collection.CollectionUtil;
import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.BookRecommend;
import com.example.springboot.entity.BookStock;
import com.example.springboot.entity.Collect;
import com.example.springboot.exception.ServiceException;
import com.example.springboot.service.IBookRecommendService;
import com.example.springboot.service.IBookService;
import com.example.springboot.service.IBookStockService;
import com.example.springboot.service.ICollectService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 图书控制器
 */
@RestController
@RequestMapping("/book")
public class BookController {

    @Resource
    private IBookService bookService;
    @Resource
    private ICollectService collectService;
    @Resource
    private IBookRecommendService bookRecommendService;
    @Resource
    private IBookStockService bookStockService;

    @PostMapping
    public Result save(@RequestBody Book book) {
        if (book.getId() == null) {
            // 前台发布默认归属当前用户；后台可指定所属用户
            if (book.getUserId() == null) {
                book.setUserId(TokenUtils.getCurrentUser().getId());
            }
            book.setStatus("可借阅");
            book.setViewCount(0);
            book.setFavoriteCount(0);
            book.setRecommendCount(0);
            book.setBorrowCount(0);
            bookService.save(book);
            ensureStockExists(book.getId());
            return Result.success(true);
        }
        Account current = TokenUtils.getCurrentUser();
        Book db = bookService.getById(book.getId());
        if (db == null) {
            throw new ServiceException("404", "图书不存在");
        }
        // 普通用户只能改自己的书
        if (current != null && StrUtil.equals(current.getRole(), "ROLE_USER")
                && db.getUserId() != null && !db.getUserId().equals(current.getId())) {
            throw new ServiceException("403", "无权修改该图书");
        }
        bookService.saveOrUpdate(book);
        // 可借阅 / 已借出由库存推导；维护中 / 已下架为手工状态
        if (StrUtil.equals(book.getStatus(), "可借阅")) {
            ensureStockExists(book.getId());
            syncBookStatusByStock(book.getId());
        } else if (StrUtil.equals(book.getStatus(), "已借出")) {
            // 手工设为已借出：不补库存，也不被库存同步改回可借阅
        } else if (StrUtil.equals(book.getStatus(), "维护中") || StrUtil.equals(book.getStatus(), "已下架")) {
            // 手工状态，不同步
        } else {
            syncBookStatusByStock(book.getId());
        }
        return Result.success(true);
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        Account current = TokenUtils.getCurrentUser();
        Book db = bookService.getById(id);
        if (db == null) {
            throw new ServiceException("404", "图书不存在");
        }
        if (current != null && StrUtil.equals(current.getRole(), "ROLE_USER")
                && db.getUserId() != null && !db.getUserId().equals(current.getId())) {
            throw new ServiceException("403", "无权删除该图书");
        }
        return Result.success(bookService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(bookService.removeByIds(ids));
    }

    @GetMapping
    public Result findAll() {
        return Result.success(bookService.list());
    }

    @GetMapping("/user/{id}")
    public Result findByUser(@PathVariable Integer id) {
        LambdaQueryWrapper<Book> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Book::getId).eq(Book::getUserId, id);
        return Result.success(bookService.list(wrapper));
    }

    @GetMapping("/front")
    public Result findFront() {
        LambdaQueryWrapper<Book> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Book::getViewCount)
                .eq(Book::getStatus, "可借阅");
        return Result.success(bookService.list(wrapper.last("LIMIT 12")));
    }

    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        Book book = bookService.getById(id);
        if (book == null) {
            return Result.error("404", "图书不存在");
        }
        book.setViewCount((book.getViewCount() == null ? 0 : book.getViewCount()) + 1);
        book.setIsCollected(false);
        book.setIsRecommended(false);
        Account currentUser = TokenUtils.getCurrentUser();
        if (ObjectUtil.isNotNull(currentUser) && currentUser.getId() != null) {
            LambdaQueryWrapper<Collect> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Collect::getBookId, id).eq(Collect::getUserId, currentUser.getId());
            book.setIsCollected(collectService.getOne(wrapper) != null);

            LambdaQueryWrapper<BookRecommend> recommendWrapper = new LambdaQueryWrapper<>();
            recommendWrapper.eq(BookRecommend::getBookId, id).eq(BookRecommend::getUserId, currentUser.getId());
            book.setIsRecommended(bookRecommendService.getOne(recommendWrapper) != null);
        }
        bookService.updateById(book);
        fillStockInfo(book);
        return Result.success(book);
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {
        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Book::getId);
        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Book::getName, keyword);
        }
        Page<Book> page = bookService.page(new Page<>(pageNum, pageSize), queryWrapper);
        if (page.getRecords() != null) {
            for (Book book : page.getRecords()) {
                fillStockInfo(book);
            }
        }
        return Result.success(page);
    }

    @GetMapping("/collect/page")
    public Result findCollectPage(@RequestParam(defaultValue = "") String keyword,
                                  @RequestParam Integer pageNum,
                                  @RequestParam Integer pageSize) {
        LambdaQueryWrapper<Collect> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Collect::getUserId, TokenUtils.getCurrentUser().getId());
        List<Integer> ids = collectService.list(wrapper).stream()
                .map(Collect::getBookId)
                .collect(Collectors.toList());
        if (CollectionUtil.isEmpty(ids)) {
            return Result.success(new Page<>(pageNum, pageSize));
        }
        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.like(StrUtil.isNotEmpty(keyword), Book::getName, keyword);
        queryWrapper.in(Book::getId, ids);
        return Result.success(bookService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

    @GetMapping("/front/page")
    public Result findFrontPage(@RequestParam(defaultValue = "") String keyword,
                                @RequestParam(defaultValue = "0") Integer typeId,
                                @RequestParam(defaultValue = "all") String sortBy,
                                @RequestParam Integer pageNum,
                                @RequestParam Integer pageSize) {
        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Book::getStatus, "可借阅");
        if (StrUtil.equals(sortBy, "all")) {
            queryWrapper.orderByAsc(Book::getId);
        } else if (StrUtil.equals(sortBy, "new")) {
            queryWrapper.orderByDesc(Book::getCreateTime);
        } else if (StrUtil.equals(sortBy, "recommend") || StrUtil.equals(sortBy, "hot")) {
            queryWrapper.orderByDesc(Book::getRecommendCount).orderByDesc(Book::getViewCount);
        } else if (StrUtil.equals(sortBy, "collect") || StrUtil.equals(sortBy, "favorite")) {
            queryWrapper.orderByDesc(Book::getFavoriteCount);
        } else if (StrUtil.equals(sortBy, "price")) {
            queryWrapper.orderByAsc(Book::getPrice).orderByDesc(Book::getId);
        } else {
            queryWrapper.orderByDesc(Book::getId);
        }
        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Book::getName, keyword);
        }
        if (typeId != null && typeId != 0) {
            queryWrapper.and(w -> w.eq(Book::getTypeId, typeId)
                    .or()
                    .inSql(Book::getTypeId, "select id from book_type where parent_id = " + typeId));
        }
        return Result.success(bookService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

    @GetMapping("/rank")
    public Result rank(@RequestParam(defaultValue = "recommend") String type,
                       @RequestParam(defaultValue = "10") Integer limit) {
        LambdaQueryWrapper<Book> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Book::getStatus, "可借阅");
        if ("collect".equals(type) || "favorite".equals(type)) {
            wrapper.orderByDesc(Book::getFavoriteCount).orderByDesc(Book::getViewCount);
        } else {
            wrapper.orderByDesc(Book::getRecommendCount).orderByDesc(Book::getViewCount);
        }
        wrapper.last("limit " + Math.min(Math.max(limit, 1), 50));
        return Result.success(bookService.list(wrapper));
    }

    private void fillStockInfo(Book book) {
        if (book == null || book.getId() == null) {
            return;
        }
        long total = bookStockService.count(new LambdaQueryWrapper<BookStock>()
                .eq(BookStock::getBookId, book.getId()));
        long available = bookStockService.count(new LambdaQueryWrapper<BookStock>()
                .eq(BookStock::getBookId, book.getId())
                .eq(BookStock::getStatus, 0));
        book.setStockTotal((int) total);
        book.setStockAvailable((int) available);
    }

    /** 一册都没有时才补库存，避免「已全部借出」时再造出多余册 */
    private void ensureStockExists(Integer bookId) {
        long total = bookStockService.count(new LambdaQueryWrapper<BookStock>()
                .eq(BookStock::getBookId, bookId));
        if (total > 0) {
            return;
        }
        BookStock stock = new BookStock();
        stock.setBookId(bookId);
        stock.setStockCode(nextStockCode(bookId));
        stock.setStatus(0);
        bookStockService.save(stock);
    }

    /** 生成不与唯一索引冲突的库存编号 */
    private String nextStockCode(Integer bookId) {
        long seq = bookStockService.count(new LambdaQueryWrapper<BookStock>()
                .eq(BookStock::getBookId, bookId)) + 1;
        for (int i = 0; i < 1000; i++) {
            String code = "BK" + bookId + "-" + (seq + i);
            long exists = bookStockService.count(new LambdaQueryWrapper<BookStock>()
                    .eq(BookStock::getStockCode, code));
            if (exists == 0) {
                return code;
            }
        }
        return "BK" + bookId + "-" + System.currentTimeMillis();
    }

    /** 按可借库存同步图书状态：有库存=可借阅，无库存=已借出（维护中/已下架不改） */
    private void syncBookStatusByStock(Integer bookId) {
        Book book = bookService.getById(bookId);
        if (book == null) {
            return;
        }
        if (StrUtil.equals(book.getStatus(), "维护中") || StrUtil.equals(book.getStatus(), "已下架")) {
            return;
        }
        long available = bookStockService.count(new LambdaQueryWrapper<BookStock>()
                .eq(BookStock::getBookId, bookId)
                .eq(BookStock::getStatus, 0));
        String target = available > 0 ? "可借阅" : "已借出";
        if (!StrUtil.equals(book.getStatus(), target)) {
            book.setStatus(target);
            bookService.updateById(book);
        }
    }
}
