package com.example.springboot.config.interceptor;

import cn.hutool.core.util.StrUtil;
import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTDecodeException;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.example.springboot.common.Constants;
import com.example.springboot.entity.Account;
import com.example.springboot.exception.ServiceException;
import com.example.springboot.service.IAdminService;
import com.example.springboot.service.IUserService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * JWT 登录校验拦截器。
 * <p>
 * token 载荷 audience 格式为 {@code userId-ROLE_xxx}；
 * 签名密钥使用账号当前密码，因此改密后旧 token 会立即。
 */
public class JwtInterceptor implements HandlerInterceptor {

    @Resource
    private IUserService userService;
    @Resource
    private IAdminService adminService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // 静态资源等非 Controller 方法直接放行
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }

        String token = request.getHeader("token");
        if (StrUtil.isBlank(token)) {
            token = request.getParameter("token");
        }
        if (StrUtil.isBlank(token)) {
            throw new ServiceException(Constants.CODE_401, "无token,请重新登录");
        }

        Account account = null;
        try {
            String accountInfo = JWT.decode(token).getAudience().get(0);
            String accountId = accountInfo.split("-")[0];
            String accountRole = accountInfo.split("-")[1];

            if (StrUtil.equals(accountRole, "ROLE_USER")) {
                account = userService.getById(Integer.valueOf(accountId));
            }
            if (StrUtil.equals(accountRole, "ROLE_ADMIN")) {
                account = adminService.getById(Integer.valueOf(accountId));
            }
        } catch (JWTDecodeException e) {
            throw new ServiceException(Constants.CODE_401, "token验证失败，请重新登录");
        }

        if (account == null) {
            throw new ServiceException(Constants.CODE_401, "用户不存在，请重新登录");
        }

        // 用库中密码做 HMAC，防止伪造或使用过期密码签发的 token
        JWTVerifier jwtVerifier = JWT.require(Algorithm.HMAC256(account.getPassword())).build();
        try {
            jwtVerifier.verify(token);
        } catch (JWTVerificationException e) {
            throw new ServiceException(Constants.CODE_401, "token验证失败，请重新登录");
        }
        return true;
    }
}
