package com.example.springboot.config.interceptor;

import cn.hutool.core.util.StrUtil;
import com.auth0.jwt.JWT;
import com.example.springboot.common.Constants;
import com.example.springboot.exception.ServiceException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 管理端接口角色校验：普通用户不可访问管理员专用接口
 */
public class AdminInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String uri = request.getRequestURI();
        String method = request.getMethod();
        if (!needAdmin(method, uri)) {
            return true;
        }
        String token = request.getHeader("token");
        if (StrUtil.isBlank(token)) {
            token = request.getParameter("token");
        }
        if (StrUtil.isBlank(token)) {
            throw new ServiceException(Constants.CODE_401, "无token,请重新登录");
        }
        try {
            String accountInfo = JWT.decode(token).getAudience().get(0);
            String role = accountInfo.split("-")[1];
            if (!StrUtil.equals(role, "ROLE_ADMIN")) {
                throw new ServiceException("403", "无管理员权限");
            }
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException(Constants.CODE_401, "token验证失败，请重新登录");
        }
        return true;
    }

    private boolean needAdmin(String method, String uri) {
        if (uri == null) {
            return false;
        }
        // 管理员账号管理
        if (uri.startsWith("/admin")) {
            return true;
        }
        // 用户分页与封禁（前台用 /user/simple）
        if (uri.startsWith("/user/page") || uri.contains("/status") || uri.startsWith("/user/batch")) {
            return true;
        }
        if ("DELETE".equalsIgnoreCase(method) && uri.matches("/user/\\d+")) {
            return true;
        }
        // 公告 / 轮播写操作仅管理员
        if (("POST".equalsIgnoreCase(method) || "DELETE".equalsIgnoreCase(method))
                && (uri.startsWith("/notice") || uri.startsWith("/banner"))) {
            return true;
        }
        return false;
    }
}
