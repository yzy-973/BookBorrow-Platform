package com.example.springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboot.entity.BookRecommend;
import com.example.springboot.mapper.BookRecommendMapper;
import com.example.springboot.service.IBookRecommendService;
import org.springframework.stereotype.Service;

@Service
public class BookRecommendServiceImpl extends ServiceImpl<BookRecommendMapper, BookRecommend> implements IBookRecommendService {
}
