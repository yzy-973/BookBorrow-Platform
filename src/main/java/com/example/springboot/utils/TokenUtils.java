package com.example.springboot.utils;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.example.springboot.entity.Account;
import com.example.springboot.service.IAdminService;
import com.example.springboot.service.IUserService;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.Date;

/**
 * Token 工具：签发 JWT，以及从当前请求解析登录用户。
 * 未登录或解析失败时统一返回 {@code null}（不要返回空 Account，以免静默查出 user_id=null）。
 */
@Component
public class TokenUtils {

    private static IUserService staticUserService;
    private static IAdminService staticAdminService;

    @Resource
    private IUserService userService;
    @Resource
    private IAdminService adminService;

    @PostConstruct
    public void initService() {
        staticUserService = userService;
        staticAdminService = adminService;
    }

    /**
     * @param data 载荷，约定为 {@code id-ROLE_USER} 或 {@code id-ROLE_ADMIN}
     * @param sign HMAC 密钥（当前实现使用登录密码明文）
     */
    public static String createToken(String data, String sign) {
        return JWT.create().withAudience(data)
                .withExpiresAt(DateUtil.offsetHour(new Date(), 2))
                .sign(Algorithm.HMAC256(sign));
    }

    /** @return 当前请求对应用户；无 token / 非法时返回 null */
    public static Account getCurrentUser() {
        try {
            HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
            String token = request.getHeader("token");
            if (StrUtil.isNotEmpty(token)) {
                String accountInfo = JWT.decode(token).getAudience().get(0);
                String accountId = accountInfo.split("-")[0];
                String accountRole = accountInfo.split("-")[1];

                Account account = null;
                if (StrUtil.equals(accountRole, "ROLE_USER")) {
                    account = staticUserService.getById(Integer.valueOf(accountId));
                }
                if (StrUtil.equals(accountRole, "ROLE_ADMIN")) {
                    account = staticAdminService.getById(Integer.valueOf(accountId));
                }
                if (account != null) {
                    // role 不在用户表字段中，需从 token 写回便于后续鉴权
                    account.setRole(accountRole);
                }
                return account;
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
}
