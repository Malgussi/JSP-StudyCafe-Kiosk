<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "your_password";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    int totalSum = 0;
%>
<!DOCTYPE html>
<html>
<head>
<title>내 장바구니</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; background-color: #f0f2f5; padding: 30px; }
    .container { width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    h2 { text-align: center; margin-bottom: 30px; color: #333; }
    
    /* 리스트 스타일 */
    .cart-item { 
        display: flex; justify-content: space-between; align-items: center;
        padding: 20px; border-bottom: 1px solid #eee;
    }
    .cart-item:last-child { border-bottom: none; }
    
    .item-info { flex: 1; }
    .item-title { font-size: 18px; font-weight: bold; color: #333; margin-bottom: 5px; }
    .item-desc { font-size: 14px; color: #666; }
    .item-price { font-size: 18px; font-weight: bold; color: #1890ff; margin-right: 20px; }
    
    /* 삭제 버튼 */
    .btn-delete { 
        padding: 8px 15px; background-color: #fff; border: 1px solid #ff4d4f; 
        color: #ff4d4f; border-radius: 5px; cursor: pointer; font-weight: bold; 
    }
    .btn-delete:hover { background-color: #fff1f0; }
    
    /* 하단 총액 및 버튼 */
    .bottom-area { margin-top: 30px; text-align: right; border-top: 2px solid #333; padding-top: 20px; }
    .total-label { font-size: 18px; font-weight: bold; margin-right: 10px; }
    .total-price { font-size: 28px; color: #1890ff; font-weight: bold; }
    
    .btn-group { display: flex; justify-content: center; gap: 15px; margin-top: 30px; }
    button { padding: 15px 40px; font-size: 18px; border-radius: 8px; cursor: pointer; border: none; font-weight: bold; }
    .btn-pay { background-color: #1890ff; color: white; }
    .btn-back { background-color: #eee; color: #333; }
</style>
</head>
<body>
    <div class="container">
        <h2>🛒 내 장바구니</h2>
        <hr>
        
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, id, pw);
                
                // 장바구니 목록 조회 (어떤 방/사물함인지 이름까지 조인해서 가져오기)
                String sql = "SELECT r.reservation_id, r.total_fee, r.start_datetime, r.end_datetime, " +
                             "p.product_name, ro.room_name, l.locker_number " +
                             "FROM Reservation r " +
                             "JOIN Product p ON r.product_id = p.product_id " +
                             "LEFT JOIN Room ro ON r.room_id = ro.room_id " +
                             "LEFT JOIN Locker l ON r.locker_id = l.locker_id " +
                             "WHERE r.member_id = ? AND r.status = 'InCart' " +
                             "ORDER BY r.reservation_id DESC";
                             
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, userId);
                rs = pstmt.executeQuery();
                
                boolean isEmpty = true;
                
                while(rs.next()) {
                    isEmpty = false;
                    int rId = rs.getInt("reservation_id");
                    String pName = rs.getString("product_name");
                    int price = rs.getInt("total_fee");
                    String start = rs.getString("start_datetime").substring(0, 16); // 초 단위 자르기
                    String end = rs.getString("end_datetime").substring(11, 16);
                    
                    // 상세 이름 (방 이름 or 사물함 번호)
                    String detailName = "";
                    if(rs.getString("room_name") != null) {
                        detailName = "📍 " + rs.getString("room_name");
                    } else if(rs.getString("locker_number") != null) {
                        detailName = "🎒 사물함 " + rs.getString("locker_number") + "번";
                    }
                    
                    totalSum += price;
        %>
            <div class="cart-item">
                <div class="item-info">
                    <div class="item-title"><%= pName %></div>
                    <div class="item-desc">
                        <%= detailName %> <br>
                        이용시간: <%= start %> ~ <%= end %>
                    </div>
                </div>
                <div class="item-price"><%= String.format("%,d", price) %>원</div>
                
                <button class="btn-delete" onclick="if(confirm('정말 삭제하시겠습니까?')) location.href='deleteCartAction.jsp?id=<%=rId%>'">
                    삭제 🗑️
                </button>
            </div>
        <%
                }
                
                if(isEmpty) {
        %>
            <div style="text-align:center; padding:50px; color:#999;">
                <h3>장바구니가 비어있습니다 😢</h3>
            </div>
        <%
                }
            } catch(Exception e) { e.printStackTrace(); }
            finally {
                if(rs!=null) rs.close();
                if(pstmt!=null) pstmt.close();
                if(conn!=null) conn.close();
            }
        %>
        
        <% if(totalSum > 0) { %>
            <div class="bottom-area">
                <span class="total-label">총 결제 예정 금액:</span>
                <span class="total-price"><%= String.format("%,d", totalSum) %>원</span>
            </div>
            
            <div class="btn-group">
                <button class="btn-back" onclick="location.href='step1_date.jsp'">더 담으러 가기</button>
                <button class="btn-pay" onclick="location.href='step5_payment.jsp'">결제하기 💳</button>
            </div>
        <% } else { %>
            <div class="btn-group">
                <button class="btn-pay" onclick="location.href='step1_date.jsp'">예약하러 가기</button>
            </div>
        <% } %>
        
    </div>
</body>

</html>
