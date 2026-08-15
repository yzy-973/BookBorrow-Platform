package com.example.springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboot.entity.BookComment;
import com.example.springboot.mapper.BookCommentMapper;
import com.example.springboot.service.IBookCommentService;
import org.springframework.stereotype.Service;

@Service
public class BookCommentServiceImpl extends ServiceImpl<BookCommentMapper, BookComment> implements IBookCommentService {
}
