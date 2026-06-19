package com.trantatphat.back_end.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        
        // 1. Lấy chuỗi cấu hình Authorization từ Header của Request gửi lên
        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String userEmail;

        // 2. Kiểm tra nếu Header trống hoặc không bắt đầu bằng chữ "Bearer " thì bỏ qua bộ lọc này
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 3. Cắt bỏ 7 ký tự đầu tiên ("Bearer ") để lấy chính xác chuỗi mã JWT nguyên bản
        jwt = authHeader.substring(7);
        
        // Trích xuất Email người dùng từ chuỗi mã JWT vừa cắt
        userEmail = jwtTokenProvider.extractEmail(jwt);

        // 4. Nếu trích xuất được Email và User này chưa được nạp vào hệ thống bảo mật (Context) của Spring
        if (userEmail != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            
            // Tìm kiếm thông tin User chi tiết từ cơ sở dữ liệu PostgreSQL lên
            UserDetails userDetails = this.userDetailsService.loadUserByUsername(userEmail);

            // 5. Kiểm tra xem Token có hợp lệ và trùng khớp với dữ liệu User trong DB không
            if (jwtTokenProvider.validateToken(jwt, userDetails)) {
                
                // Khởi tạo đối tượng xác thực chứa thông tin User và Quyền hạn (Roles)
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );
                
                // Nạp thêm chi tiết request (IP, Session) vào đối tượng xác thực
                authToken.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );
                
                // ĐƯA USER VÀO VÙNG BẢO MẬT AN TOÀN - ĐÁNH DẤU LÀ ĐÃ ĐĂNG NHẬP THÀNH CÔNG
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }

        // 6. Cho phép request tiếp tục đi tới bộ lọc tiếp theo hoặc đi vào Controller xử lý dữ liệu
        filterChain.doFilter(request, response);
    }
}
