package com.example.springboot.controller;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.example.springboot.common.Constants;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.User;
import com.example.springboot.service.IAdminService;
import com.example.springboot.service.IUserService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;

/**
 * 登录注册与文件上传下载
 */
@RestController
@RequestMapping("/web")
public class WebController {

    private static final String FILE_UPLOAD_PATH = System.getProperty("user.dir") + File.separator + "files" + File.separator;
    @Value("${ip:localhost}")
    String ip;

    @Value("${server.port}")
    String port;

    @Resource
    private IUserService userService;
    @Resource
    private IAdminService adminService;


    /** 登录（封禁校验在 UserServiceImpl.login） */
    @PostMapping("/login")
    public Result login(@RequestBody Account account) {
        if (StrUtil.isBlank(account.getUsername()) || StrUtil.isBlank(account.getPassword())||StrUtil.isBlank(account.getRole())) {
            return Result.error(Constants.CODE_400,"参数错误");
        }
        if (StrUtil.equals(account.getRole(),"ROLE_USER")){
            account=userService.login(account);
        }
        if (StrUtil.equals(account.getRole(),"ROLE_ADMIN")){
            account=adminService.login(account);
        }
        if (account != null) {
            account.setPassword(null);
        }
        return Result.success(account);
    }

    /** 公开注册：仅允许普通用户，管理员须由后台创建 */
    @PostMapping("/register")
    public Result register(@RequestBody Account account) {
        if (StrUtil.isEmpty(account.getUsername()) || StrUtil.isEmpty(account.getPassword())) {
            return Result.error(Constants.CODE_400,"参数错误");
        }
        if (StrUtil.equals(account.getRole(), "ROLE_ADMIN")) {
            return Result.error(Constants.CODE_400, "不允许公开注册管理员账号");
        }
        account.setRole("ROLE_USER");
        userService.register(account);
        return Result.success();
    }

    //修改密码
    @PostMapping("/password")
    public Result updatePassword(@RequestBody Account account) {
        if (StrUtil.isBlank(account.getPassword()) || StrUtil.isBlank(account.getNewPassword())) {
            return Result.error(Constants.CODE_400,"参数错误");
        }
        Account one= TokenUtils.getCurrentUser();//拿到当前用户信息
        account.setUsername(one.getUsername());

        if (StrUtil.equals(one.getRole(),"ROLE_USER")){
            userService.updatePassword(account);
        }

        if (StrUtil.equals(one.getRole(),"ROLE_ADMIN")){
            adminService.updatePassword(account);
        }

        return Result.success();
    }

    /** 当前登录用户信息 */
    @GetMapping("/userInfo")
    public Result userInfo(){
        Account account=TokenUtils.getCurrentUser();
        if (account == null || account.getId() == null) {
            return Result.error(Constants.CODE_401, "请先登录");
        }

        if (StrUtil.equals(account.getRole(),"ROLE_USER")){
            User user = userService.getById(account.getId());
            if (user != null) {
                user.setPassword(null);
            }
            return Result.success(user);
        }
        if (StrUtil.equals(account.getRole(),"ROLE_ADMIN")){
            Account admin = adminService.getById(account.getId());
            if (admin != null) {
                admin.setPassword(null);
            }
            return Result.success(admin);
        }

        return Result.error(Constants.CODE_605,"获取用户信息失败");
    }

    /** 上传文件，UUID 命名后返回可访问 URL */
    @PostMapping("/upload")
    public String upload(@RequestParam MultipartFile file) throws IOException{
        String originalFilename = file.getOriginalFilename();
        String type = FileUtil.extName(originalFilename);
        String fileUUID = IdUtil.fastSimpleUUID() + StrUtil.DOT + type;

        File uploadFile = new File(FILE_UPLOAD_PATH + fileUUID);
        File parenFile = uploadFile.getParentFile();
        if (!parenFile.exists()) {
            parenFile.mkdirs();
        }

        file.transferTo(uploadFile);
        return "http://" + ip + ":" + port + "/web/download/" + fileUUID;
    }

    /** 文件下载；图片按真实类型返回 Content-Type，便于页面预览 */
    @GetMapping("/download/{fileUUID}")
    public void download(@PathVariable String fileUUID, HttpServletResponse response) throws IOException {
        String safeName = fileUUID == null ? "" : fileUUID.replace("\\", "").replace("/", "");
        File uploadFile = new File(FILE_UPLOAD_PATH + safeName);
        if (!uploadFile.exists() || !uploadFile.isFile()) {
            File fallback = new File(FILE_UPLOAD_PATH + "default.jpg");
            if (fallback.exists()) {
                uploadFile = fallback;
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        }

        String lower = uploadFile.getName().toLowerCase();
        String contentType = "application/octet-stream";
        if (lower.endsWith(".png")) contentType = "image/png";
        else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) contentType = "image/jpeg";
        else if (lower.endsWith(".webp")) contentType = "image/webp";
        else if (lower.endsWith(".gif")) contentType = "image/gif";

        // 用 setHeader 避免被追加 charset
        response.setHeader("Content-Type", contentType);
        response.setHeader("Content-Disposition", "inline;filename=" + URLEncoder.encode(safeName, "UTF-8"));

        try (ServletOutputStream os = response.getOutputStream()) {
            os.write(FileUtil.readBytes(uploadFile));
            os.flush();
        }
    }

}
