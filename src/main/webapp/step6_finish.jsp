<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    String payMethod = request.getParameter("payMethod");
    String couponIdStr = request.getParameter("couponId");
    
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "your_password";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    boolean isSuccess = false;
    int finalAmount = 0;
    int discountAmount = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        
        // ★ 트랜잭션 시작 (자동 저장 끔)
        conn.setAutoCommit(false);
        
        // 1. 장바구니 총액 계산 & 상품 타입 확인
        // (사물함/좌석은 Active, 룸은 Scheduled로 바꾸기 위해 조회)
        String sumSql = "SELECT SUM(total_fee) FROM Reservation WHERE member_id = ? AND status = 'InCart'";
        pstmt = conn.prepareStatement(sumSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        int originalTotal = 0;
        if(rs.next()) originalTotal = rs.getInt(1);
        rs.close(); pstmt.close();
        
        // 2. 쿠폰 할인 계산
        int couponId = 0;
        if(couponIdStr != null && !couponIdStr.equals("0")) {
            couponId = Integer.parseInt(couponIdStr);
            
            // 쿠폰 정보 가져오기 (할인율/할인액)
            String cSql = "SELECT c.discount_type, c.discount_value, c.coupon_name " +
                          "FROM Member_Coupon mc JOIN Coupon c ON mc.coupon_id = c.coupon_id " +
                          "WHERE mc.member_coupon_id = ? AND mc.status = 'Available'";
            pstmt = conn.prepareStatement(cSql);
            pstmt.setInt(1, couponId);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                String type = rs.getString("discount_type");
                int val = rs.getInt("discount_value");
                
                // (간단하게 전체 금액에서 할인 적용 - 정밀한 대상 구분 로직은 생략)
                if("Fixed".equals(type)) discountAmount = val;
                else discountAmount = (int)(originalTotal * (val / 100.0));
                
                if(discountAmount > originalTotal) discountAmount = originalTotal;
            }
            rs.close(); pstmt.close();
        }
        
        finalAmount = originalTotal - discountAmount;
        
        // 3. Payment(영수증) 생성
        String paySql = "INSERT INTO Payment (member_id, final_amount, payment_method, used_points, member_coupon_id) VALUES (?, ?, ?, 0, ?)";
        pstmt = conn.prepareStatement(paySql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, userId);
        pstmt.setInt(2, finalAmount);
        pstmt.setString(3, payMethod);
        if(couponId > 0) pstmt.setInt(4, couponId); else pstmt.setNull(4, java.sql.Types.INTEGER);
        
        pstmt.executeUpdate();
        
        // 방금 만든 영수증 번호 가져오기
        rs = pstmt.getGeneratedKeys();
        int paymentId = 0;
        if(rs.next()) paymentId = rs.getInt(1);
        rs.close(); pstmt.close();
        
        // 4. Reservation 업데이트
        // 룸 -> Scheduled(예정), 좌석/사물함 -> Active(즉시사용)
        String updateResSql = "UPDATE Reservation r " +
                              "JOIN Product p ON r.product_id = p.product_id " +
                              "SET r.status = CASE " +
                              "  WHEN p.product_type = 'ROOM' THEN 'Scheduled' " +
                              "  ELSE 'Active' END, " +
                              "r.payment_id = ? " +
                              "WHERE r.member_id = ? AND r.status = 'InCart'";
                              
        pstmt = conn.prepareStatement(updateResSql);
        pstmt.setInt(1, paymentId);
        pstmt.setInt(2, userId);
        int updateCount = pstmt.executeUpdate();
        
        // 5. 쿠폰 사용 처리
        if(couponId > 0) {
            String useCouponSql = "UPDATE Member_Coupon SET status = 'Used' WHERE member_coupon_id = ?";
            pstmt = conn.prepareStatement(useCouponSql);
            pstmt.setInt(1, couponId);
            pstmt.executeUpdate();
        }
        
        // ★ 모든 과정 성공 시 커밋 (저장)
        if(updateCount > 0) {
            conn.commit();
            isSuccess = true;
        } else {
            conn.rollback(); // 실패하면 되돌리기
        }
        
    } catch(Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
    } finally {
        if(rs!=null) rs.close();
        if(pstmt!=null) pstmt.close();
        if(conn!=null) conn.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
<title>결제 완료</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; text-align: center; padding: 50px; background-color: #f9f9f9; }
    .container { width: 500px; margin: 0 auto; background: white; padding: 50px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    .icon { font-size: 80px; margin-bottom: 20px; }
    h2 { margin: 10px 0; color: #333; }
    p { color: #666; margin-bottom: 40px; }
    .btn-home { padding: 15px 40px; background-color: #4CAF50; color: white; font-size: 18px; border: none; border-radius: 8px; cursor: pointer; text-decoration: none; }
    .btn-home:hover { background-color: #45a049; }
</style>
</head>
<body>
    <div class="container">
        <% if (isSuccess) { %>
            <div class="icon">🎉</div>
            <h2>결제가 완료되었습니다!</h2>
            <p>예약하신 내역은 [마이페이지]에서 확인 가능합니다.</p>
            <div style="background:#f5f5f5; padding:20px; border-radius:10px; margin-bottom:30px;">
                결제금액: <strong><%= String.format("%,d", finalAmount) %>원</strong>
            </div>
            <a href="main.jsp" class="btn-home">🏠 홈으로 돌아가기</a>
        <% } else { %>
            <div class="icon">😢</div>
            <h2>결제에 실패했습니다.</h2>
            <p>관리자에게 문의해주세요.</p>
            <a href="step5_payment.jsp" class="btn-home" style="background-color:#ff4d4f;">다시 시도하기</a>
        <% } %>
    </div>
</body>

</html>
