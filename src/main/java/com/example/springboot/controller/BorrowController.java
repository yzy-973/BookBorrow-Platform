package com.example.springboot.controller;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Address;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.BookRating;
import com.example.springboot.entity.BookStock;
import com.example.springboot.entity.BorrowRecord;
import com.example.springboot.exception.ServiceException;
import com.example.springboot.service.IAddressService;
import com.example.springboot.service.IBookRatingService;
import com.example.springboot.service.IBookService;
import com.example.springboot.service.IBookStockService;
import com.example.springboot.service.IBorrowRecordService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

/**
 * 借阅记录控制器。
 * <p>
 * 状态流转：待审核 →借阅中 →已归还；
 * 取消/拒绝会释放库存册。申请借阅时即锁定一册库存，避免超借。
 */
@RestController
@RequestMapping("/borrow")
public class BorrowController {

    @Resource
    private IBorrowRecordService borrowRecordService;
    @Resource
    private IBookService bookService;
    @Resource
    private IBookStockService bookStockService;
    @Resource
    private IAddressService addressService;
    @Resource
    private IBookRatingService bookRatingService;

    @PostMapping
    public Result save(@RequestBody BorrowRecord borrow) {
        if (borrow.getId() == null) {
            Account currentUser = TokenUtils.getCurrentUser();
            if (currentUser == null || currentUser.getId() == null) {
                throw new ServiceException("401", "请先登录");
            }
            Book book = bookService.getById(borrow.getBookId());
            if (book == null) {
                throw new ServiceException("400", "图书不存在");
            }
            if (!StrUtil.equals(book.getStatus(), "可借阅")) {
                throw new ServiceException("400", "图书当前不可借阅");
            }
            BookStock stock = bookStockService.getOne(new LambdaQueryWrapper<BookStock>()
                    .eq(BookStock::getBookId, book.getId())
                    .eq(BookStock::getStatus, 0)
                    .last("limit 1"));
            if (stock == null) {
                // 库存与状态不一致时，校正为已借出，避免前台仍显示可借
                syncBookStatusByStock(book.getId());
                throw new ServiceException("400", "暂无可用库存，图书已标记为已借出");
            }

            borrow.setNo(DateUtil.format(new Date(), "yyyyMMddHHmmssSSS") + RandomUtil.randomNumbers(6));
            borrow.setBookName(book.getName());
            borrow.setBookImg(book.getImg());
            borrow.setFromUserId(book.getUserId());
            borrow.setToUserId(currentUser.getId());
            borrow.setStockId(stock.getId());
            borrow.setStatus("待审核");
            borrow.setExtendCount(0);
            if (borrow.getAddressId() != null) {
                Address address = addressService.getById(borrow.getAddressId());
                if (address != null) {
                    borrow.setRemark(address.getName() + " " + address.getPhone() + " " + address.getAddress()
                            + (StrUtil.isNotBlank(address.getInfo()) ? (" " + address.getInfo()) : ""));
                }
            }
            borrowRecordService.save(borrow);

            // 申请时锁定库存，防止超借；借阅量仍计一次申请（与现有逻辑一致）
            stock.setStatus(1);
            stock.setBorrowRecordId(borrow.getId());
            bookStockService.updateById(stock);

            book.setBorrowCount((book.getBorrowCount() == null ? 0 : book.getBorrowCount()) + 1);
            bookService.updateById(book);
            syncBookStatusByStock(book.getId());
            return Result.success(true);
        }
        // 更新用 saveOrUpdate；update-strategy 为 NOT_NULL 时，未传字段不会被清空
        boolean ok = borrowRecordService.saveOrUpdate(borrow);
        BorrowRecord db = borrow.getId() != null ? borrowRecordService.getById(borrow.getId()) : null;
        if (db != null) {
            // 未归还不允许保留评价
            if (!StrUtil.equals(db.getStatus(), "已归还")) {
                clearReviewIfNotReturned(db);
            } else if (borrow.getBorrowerRating() != null && borrow.getBorrowerRating() > 0
                    && StrUtil.isNotBlank(borrow.getBorrowerReview())) {
                // 前台评价可能只传 id/评分/内容
                if (borrow.getBookId() == null) {
                    borrow.setBookId(db.getBookId());
                }
                if (borrow.getToUserId() == null) {
                    borrow.setToUserId(db.getToUserId());
                }
                if (borrow.getBookId() != null && borrow.getToUserId() != null) {
                    syncBorrowReviewToBookRating(borrow);
                }
            }
        }
        return Result.success(ok);
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        BorrowRecord record = requireRecord(id);
        checkParty(record, true, true);
        restoreStock(record);
        syncBookStatusByStock(record.getBookId());
        return Result.success(borrowRecordService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        if (ids != null) {
            for (Integer id : ids) {
                BorrowRecord record = borrowRecordService.getById(id);
                if (record != null) {
                    restoreStock(record);
                    syncBookStatusByStock(record.getBookId());
                }
            }
        }
        return Result.success(borrowRecordService.removeByIds(ids));
    }

    @GetMapping
    public Result findAll() {
        return Result.success(borrowRecordService.list());
    }

    @GetMapping("/user/{id}")
    public Result findUser(@PathVariable Integer id) {
        LambdaQueryWrapper<BorrowRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(BorrowRecord::getId)
                .eq(BorrowRecord::getFromUserId, id)
                .isNotNull(BorrowRecord::getBorrowerReview)
                .isNotNull(BorrowRecord::getBorrowerRating);
        return Result.success(borrowRecordService.list(wrapper));
    }

    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        return Result.success(requireRecord(id));
    }

    /** 取消/拒绝借阅，释放库存 */
    @PostMapping("/cancel/{id}")
    public Result cancel(@PathVariable Integer id) {
        BorrowRecord record = requireRecord(id);
        checkParty(record, true, true);
        record.setStatus("拒绝");
        restoreStock(record);
        syncBookStatusByStock(record.getBookId());
        borrowRecordService.updateById(record);
        return Result.success();
    }

    /** 书主同意借出 */
    @PostMapping("/approve/{id}")
    public Result approve(@PathVariable Integer id) {
        BorrowRecord record = requireRecord(id);
        checkParty(record, true, false);
        record.setStatus("借阅中");
        record.setBorrowDate(LocalDateTime.now());
        record.setDueDate(LocalDateTime.now().plusDays(30));
        borrowRecordService.updateById(record);
        return Result.success();
    }

    /** 确认归还，释放库存 */
    @PostMapping("/receipt/{id}")
    public Result receipt(@PathVariable Integer id) {
        BorrowRecord record = requireRecord(id);
        checkParty(record, false, true);
        record.setStatus("已归还");
        record.setReturnDate(LocalDateTime.now());
        restoreStock(record);
        syncBookStatusByStock(record.getBookId());
        borrowRecordService.updateById(record);
        return Result.success();
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {
        LambdaQueryWrapper<BorrowRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(BorrowRecord::getId);
        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(BorrowRecord::getNo, keyword);
        }
        Page<BorrowRecord> page = borrowRecordService.page(new Page<>(pageNum, pageSize), queryWrapper);
        for (BorrowRecord record : page.getRecords()) {
            decorateReview(record);
        }
        return Result.success(page);
    }

    @GetMapping("/front/page")
    public Result findFrontPage(@RequestParam Integer pageNum,
                                @RequestParam Integer pageSize,
                                @RequestParam(defaultValue = "") String keyword,
                                @RequestParam(defaultValue = "全部") String status,
                                @RequestParam(defaultValue = "我借出的") String flag) {
        LambdaQueryWrapper<BorrowRecord> wrapper = new LambdaQueryWrapper<>();
        Account account = TokenUtils.getCurrentUser();
        if (account == null || account.getId() == null) {
            throw new ServiceException("401", "请先登录");
        }
        wrapper.orderByDesc(BorrowRecord::getCreateTime);
        if (StrUtil.isNotBlank(keyword)) {
            wrapper.like(BorrowRecord::getNo, keyword);
        }
        if (!StrUtil.equals(status, "全部")) {
            wrapper.eq(BorrowRecord::getStatus, status);
        }
        if (StrUtil.equals(flag, "我借出的")) {
            wrapper.eq(BorrowRecord::getFromUserId, account.getId());
        }
        if (StrUtil.equals(flag, "我借入的")) {
            wrapper.eq(BorrowRecord::getToUserId, account.getId());
        }
        Page<BorrowRecord> page = borrowRecordService.page(new Page<>(pageNum, pageSize), wrapper);
        for (BorrowRecord record : page.getRecords()) {
            decorateReview(record);
        }
        return Result.success(page);
    }

    @GetMapping("/comments/{bookId}")
    public Result getCommentsByBookId(@PathVariable Integer bookId) {
        LambdaQueryWrapper<BorrowRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BorrowRecord::getBookId, bookId)
                .isNotNull(BorrowRecord::getBorrowerReview)
                .isNotNull(BorrowRecord::getBorrowerRating)
                .eq(BorrowRecord::getStatus, "已归还")
                .orderByDesc(BorrowRecord::getId);
        return Result.success(borrowRecordService.list(wrapper));
    }

    private BorrowRecord requireRecord(Integer id) {
        BorrowRecord record = borrowRecordService.getById(id);
        if (record == null) {
            throw new ServiceException("404", "借阅记录不存在");
        }
        return record;
    }

    /**
     * 校验当前用户是否有权操作该借阅单。
     * needOwner：需为书主；needBorrower：需为借阅人；二者都为 true 表示任一方均可；管理员放行。
     */
    private void checkParty(BorrowRecord record, boolean needOwner, boolean needBorrower) {
        Account account = TokenUtils.getCurrentUser();
        if (account == null || account.getId() == null) {
            throw new ServiceException("401", "请先登录");
        }
        if (StrUtil.equals(account.getRole(), "ROLE_ADMIN")) {
            return;
        }
        boolean isOwner = record.getFromUserId() != null && record.getFromUserId().equals(account.getId());
        boolean isBorrower = record.getToUserId() != null && record.getToUserId().equals(account.getId());
        if (needOwner && needBorrower) {
            if (!isOwner && !isBorrower) {
                throw new ServiceException("403", "无权操作该借阅单");
            }
            return;
        }
        if (needOwner && !isOwner) {
            throw new ServiceException("403", "仅书主可操作");
        }
        if (needBorrower && !isBorrower) {
            throw new ServiceException("403", "仅借阅人可操作");
        }
    }

    private void restoreStock(BorrowRecord record) {
        if (record.getStockId() == null) {
            return;
        }
        BookStock stock = bookStockService.getById(record.getStockId());
        if (stock != null) {
            stock.setStatus(0);
            stock.setBorrowRecordId(null);
            bookStockService.updateById(stock);
        }
    }

    /** 按可借库存同步图书状态：有库存=可借阅，无库存=已借出（维护中/已下架不改） */
    private void syncBookStatusByStock(Integer bookId) {
        if (bookId == null) {
            return;
        }
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

    /** 列表展示时屏蔽未归还单上的评价字段 */
    private void decorateReview(BorrowRecord record) {
        if (record == null || StrUtil.equals(record.getStatus(), "已归还")) {
            return;
        }
        record.setBorrowerRating(null);
        record.setBorrowerReview(null);
    }

    /** 未归还单清空评价字段（含历史误写） */
    private void clearReviewIfNotReturned(BorrowRecord record) {
        if (record == null || StrUtil.equals(record.getStatus(), "已归还")) {
            return;
        }
        if (record.getBorrowerRating() == null && StrUtil.isBlank(record.getBorrowerReview())) {
            return;
        }
        borrowRecordService.update(new UpdateWrapper<BorrowRecord>()
                .eq("id", record.getId())
                .set("borrower_rating", null)
                .set("borrower_review", null));
        record.setBorrowerRating(null);
        record.setBorrowerReview(null);
    }

    /** 借阅评价写入 book_rating，与详情页评价互通 */
    private void syncBorrowReviewToBookRating(BorrowRecord borrow) {
        LambdaQueryWrapper<BookRating> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BookRating::getBookId, borrow.getBookId())
                .eq(BookRating::getUserId, borrow.getToUserId());
        BookRating exist = bookRatingService.getOne(wrapper);
        if (exist != null) {
            exist.setScore(borrow.getBorrowerRating());
            exist.setComment(borrow.getBorrowerReview().trim());
            bookRatingService.updateById(exist);
            return;
        }
        BookRating rating = new BookRating();
        rating.setBookId(borrow.getBookId());
        rating.setUserId(borrow.getToUserId());
        rating.setScore(borrow.getBorrowerRating());
        rating.setComment(borrow.getBorrowerReview().trim());
        bookRatingService.save(rating);
    }
}
