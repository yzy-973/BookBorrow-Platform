package com.example.springboot.config;

import com.example.springboot.config.interceptor.AdminInterceptor;
import com.example.springboot.config.interceptor.JwtInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * JWT 与管理员角色拦截器配置。
 * <p>
 * 实现 {@link WebMvcConfigurer} 而非继承 {@code WebMvcConfigurationSupport}，
 * 以免关闭 Spring Boot 对静态资源与消息转换器的自动配置。
 * {@code /user/simple}、登录注册、文件上下载放行。
 */
@Configuration
public class InterceptorConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(jwtInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/web/login", "/web/register")
                .excludePathPatterns("/web/upload", "/web/download/**")
                .excludePathPatterns("/user/simple");
        registry.addInterceptor(adminInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/web/login", "/web/register")
                .excludePathPatterns("/web/upload", "/web/download/**")
                .excludePathPatterns("/user/simple");
    }

    @Bean
    public JwtInterceptor jwtInterceptor() {
        return new JwtInterceptor();
    }

    @Bean
    public AdminInterceptor adminInterceptor() {
        return new AdminInterceptor();
    }
}
