<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 1. 정보 받기
    String branchId = request.getParameter("branchId");
    String selectedDate = request.getParameter("selectedDate");
    String category = request.getParameter("category");
    String targetId = request.getParameter("targetId"); // 룸ID 또는 좌석ID
    
    // 시간 정보 (좌석일 땐 null일 수 있음)
    String startTime = request.getParameter("startTime"); 
    String durationStr = request.getParameter("duration");
    int duration = (durationStr != null && !durationStr.isEmpty()) ? Integer.parseInt(durationStr) : 0;
    
    // 상품 ID (좌석일 땐 여기서 바로 넘어옴)
    String productIdStr = request.getParameter("productId");
    int productIdInput = (productIdStr != null) ? Integer.parseInt(productIdStr) : 0;

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    // DB 연결
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "your_password";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String productName = "상품을 찾을 수 없습니다.";
    int totalPrice = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        
        int productId = 0;
        
        // ==========================================
        // CASE A: 스터디룸 (ROOM) - 시간당 단가 계산
        // ==========================================
        if("ROOM".equals(category)) {
            // 1. 방 이름 조회
            String roomSql = "SELECT room_name, room_type FROM Room WHERE room_id = ?";
            pstmt = conn.prepareStatement(roomSql);
            pstmt.setString(1, targetId);
            rs = pstmt.executeQuery();
            
            String rName = ""; String rType = "";
            if(rs.next()) { rName = rs.getString("room_name"); rType = rs.getString("room_type"); }
            rs.close(); pstmt.close();
            
            // 2. 상품 매칭
            String targetProductName = "";
            if (rName.contains("세미나")) targetProductName = "세미나룸(단체) 1시간";
            else if (rName.contains("포커스")) targetProductName = "포커스룸(2인) 1시간";
            else {
                if (rType.contains("6")) targetProductName = "미팅룸(6인) 1시간";
                else targetProductName = "미팅룸(4인) 1시간";
            }
            
            String prodSql = "SELECT product_id, price FROM Product WHERE product_name = ?";
            pstmt = conn.prepareStatement(prodSql);
            pstmt.setString(1, targetProductName);
            rs = pstmt.executeQuery();
            
            int unitPrice = 0;
            if(rs.next()) {
                productId = rs.getInt("product_id");
                unitPrice = rs.getInt("price");
                productName = targetProductName.replace(" 1시간", "") + " (" + duration + "시간 이용)";
            }
            totalPrice = unitPrice * duration;
        } 
        // ==========================================
        // CASE B: 좌석 (SEAT) - 상품 가격 그대로 사용
        // ==========================================
        else if("SEAT".equals(category)) {
            productId = productIdInput; // 앞에서 선택한 상품ID 그대로 사용
            
            // 상품 정보 조회
            String prodSql = "SELECT product_name, price FROM Product WHERE product_id = ?";
            pstmt = conn.prepareStatement(prodSql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                productName = rs.getString("product_name");
                totalPrice = rs.getInt("price");
                
                // 좌석 번호도 이름에 추가 (예: 지정석 4주권 (N-04))
                if(targetId != null && !targetId.equals("0")) {
                    PreparedStatement pstmt2 = conn.prepareStatement("SELECT seat_number FROM Seat WHERE seat_id = ?");
                    pstmt2.setString(1, targetId);
                    ResultSet rs2 = pstmt2.executeQuery();
                    if(rs2.next()) {
                        productName += " (" + rs2.getString("seat_number") + ")";
                    }
                    rs2.close(); pstmt2.close();
                }
            }
        }
        
        // 3. DB 저장 (공통)
        if (totalPrice > 0) {
            String startDateTime = "";
            String endDateTime = "";
            
            if ("ROOM".equals(category)) {
                // 스터디룸: 선택한 시간 적용
                startDateTime = selectedDate + " " + startTime + ":00";
                int startHour = Integer.parseInt(startTime.split(":")[0]);
                int endHour = startHour + duration;
                endDateTime = selectedDate + " " + String.format("%02d", endHour) + ":00:00";
            } else {
                // 좌석
                startDateTime = selectedDate + " 00:00:00";
                endDateTime = selectedDate + " 23:59:59"; // 임시
            }
            
            String insertSql = "INSERT INTO Reservation (member_id, product_id, room_id, seat_id, start_datetime, end_datetime, total_fee, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'InCart')";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            
            if("ROOM".equals(category)) {
                pstmt.setString(3, targetId); // room_id
                pstmt.setNull(4, java.sql.Types.INTEGER); // seat_id NULL
            } else {
                pstmt.setNull(3, java.sql.Types.INTEGER); // room_id NULL
                if(targetId.equals("0")) pstmt.setNull(4, java.sql.Types.INTEGER); // 자유석 (좌석미정)
                else pstmt.setString(4, targetId); // 지정석
            }
            
            pstmt.setString(5, startDateTime);
            pstmt.setString(6, endDateTime);
            pstmt.setInt(7, totalPrice);
            pstmt.executeUpdate();
        }
        
    } catch(Exception e) {
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
<title>장바구니</title>
<style>
    /* 기존 스타일 유지 */
    body { font-family: 'Noto Sans KR', sans-serif; text-align: center; padding: 50px; background-color: #f9f9f9; }
    .container { width: 700px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    .success-icon { font-size: 60px; margin-bottom: 20px; }
    .message { font-size: 26px; font-weight: bold; color: #333; margin-bottom: 40px; }
    .info-box { background-color: #fff; border: 1px solid #eee; padding: 30px; border-radius: 10px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    .prod-name { font-size: 20px; color: #555; margin-bottom: 10px; }
    .price-text { font-size: 28px; color: #1890ff; font-weight: bold; margin-top: 10px; }
    
    .addon-box { border: 2px dashed #4CAF50; padding: 20px; border-radius: 10px; background-color: #f1f8e9; margin-bottom: 30px; }
    .btn-locker { background-color: #4CAF50; color: white; padding: 10px 15px; font-size: 14px; border-radius: 20px; cursor: pointer; border: none; font-weight: bold; margin: 0 5px;}
    .btn-locker:hover { background-color: #388e3c; }

    .btn-group { display: flex; justify-content: center; gap: 15px; }
    .btn-common { padding: 15px 40px; font-size: 18px; border-radius: 8px; cursor: pointer; border: none; font-weight: bold; }
    .btn-pay { background-color: #1890ff; color: white; }
    .btn-more { background-color: #eee; color: #333; }
</style>
<script>
    function confirmLocker(type, priceStr) {
        var typeName = "";
        if(type === '1DAY') typeName = "1일권";
        else if(type === '4WEEKS') typeName = "4주권";
        else if(type === '12WEEKS') typeName = "12주권";

        var msg = "🎒 사물함 " + typeName + " (" + priceStr + ")\n\n" + 
                  "이 상품을 장바구니에 추가하시겠습니까?\n" + 
                  "(확인 시 즉시 장바구니에 담기고 결제 페이지로 이동합니다)";
        
        if (confirm(msg)) {
            location.href = 'addLockerAction.jsp?branchId=<%=branchId%>&type=' + type;
        }
    }
</script>
</head>
<body>
    <div class="container">
        <div class="success-icon">🛒</div>
        <div class="message">장바구니에 담았습니다!</div>
        
        <div class="info-box">
            <div class="prod-name"><%= productName %></div>
            <div class="price-text">총 결제금액: <%= String.format("%,d", totalPrice) %>원</div>
        </div>
        
        <div class="addon-box">
            <h3 style="margin-top:0; color:#2e7d32;">🎒 짐이 무거우신가요?</h3>
            <p style="color:#558b2f; font-size:14px; margin-bottom: 15px;">
                사물함도 함께 예약하고 편하게 다니세요!<br>(해당 지점의 빈 사물함이 자동 배정됩니다)
            </p>
            <div style="display:flex; justify-content:center;">
                <button class="btn-locker" onclick="confirmLocker('1DAY', '5,000원')">1일권 (5,000원) +</button>
                <button class="btn-locker" onclick="confirmLocker('4WEEKS', '9,000원')">4주권 (9,000원) +</button>
                <button class="btn-locker" onclick="confirmLocker('12WEEKS', '24,300원')">12주권 (24,300원) +</button>
            </div>
        </div>

        <div class="btn-group">
            <button class="btn-common btn-more" onclick="location.href='step1_date.jsp'">더 담기</button>
            <button class="btn-common btn-pay" onclick="location.href='cartList.jsp'">장바구니 목록 보기 📋</button>
        </div>
    </div>
</body>

</html>
