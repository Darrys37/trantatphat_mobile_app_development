package com.example.auth.security;

import com.example.auth.auth.entity.User;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {
    
    @Value("${jwt.secret}")
    private String secretKey;
    
    @Value("${jwt.expiration}")
    private Long jwtExpiration;
    
    @Value("${jwt.refresh-expiration}")
    private Long refreshExpiration;
    
    private SecretKey getSigningKey() {
        byte[] keyBytes = secretKey.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }
    
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }
    
    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }
    
    public String generateToken(Map<String, Object> extraClaims, UserDetails userDetails) {
        return buildToken(extraClaims, userDetails, jwtExpiration);
    }
    
    public String generateRefreshToken(UserDetails userDetails) {
        return buildToken(new HashMap<>(), userDetails, refreshExpiration);
    }
    
    // ✅ API cho jjwt 0.11.5 - dùng setClaims, setSubject, setIssuedAt, setExpiration
    private String buildToken(Map<String, Object> extraClaims, UserDetails userDetails, long expiration) {
        User user = (User) userDetails;
        
        return Jwts.builder()
                .setClaims(extraClaims)                                          // ✅ setClaims (không phải claims)
                .setSubject(userDetails.getUsername())                           // ✅ setSubject (không phải subject)
                .claim("userId", user.getId())                                   // claim() giữ nguyên
                .claim("roles", user.getAuthorities())                           // claim() giữ nguyên
                .setIssuedAt(new Date(System.currentTimeMillis()))               // ✅ setIssuedAt (không phải issuedAt)
                .setExpiration(new Date(System.currentTimeMillis() + expiration)) // ✅ setExpiration
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)             // ✅ Thêm algorithm
                .compact();
    }
    
    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }
    
    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }
    
    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }
    
    // ✅ Parser API cho jjwt 0.11.5
    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()                    // ✅ parserBuilder (không phải parser)
                .setSigningKey(getSigningKey())        // ✅ setSigningKey (không phải verifyWith)
                .build()
                .parseClaimsJws(token)                 // ✅ parseClaimsJws (không phải parseSignedClaims)
                .getBody();                            // ✅ getBody (không phải getPayload)
    }
}