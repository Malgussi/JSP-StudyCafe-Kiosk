<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String resId = request.getParameter("resId");
    String seatId = request.getParameter("seatId");
    String lockerId = request.getParameter("lockerId");

    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=Asia/Seoul";
    String id = "root";
    String pw = "your_password"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        conn.setAutoCommit(false); 

        // 1. 해당 예약의 상품 정보(이용 시간/기간) 조회
        String prodSql = "SELECT p.hours, p.days, p.product_type FROM Reservation r " + 
                         "JOIN Product p ON r.product_id = p.product_id WHERE r.reservation_id = ?";
        pstmt = conn.prepareStatement(prodSql);
        pstmt.setString(1, resId);
        rs = pstmt.executeQuery();
        
        int pHours = 0;
        int pDays = 0;
        String pType = "";
        if(rs.next()) {
            pHours = rs.getInt("hours");
            pDays = rs.getInt("days");
            pType = rs.getString("product_type");
        }
        pstmt.close();

        // 2. 예약 정보 업데이트 (시간 재설정 + 상태 변경)
        // 스터디룸(ROOM)은 예약 시간이 고정되어야 하므로 시간 변경 안 함.
        // 좌석(SEAT)이나 사물함(LOCKER)만 입실 순간부터 카운트 시작.
        
        String updateTimePart = "";
        if(!"ROOM".equals(pType)) {
            // 시작시간 = 현재
            // 종료시간 = 현재 + 이용기간
            if(pDays > 0) {
                updateTimePart = ", start_datetime = NOW(), end_datetime = DATE_ADD(NOW(), INTERVAL " + pDays + " DAY) ";
            } else if(pHours > 0) {
                updateTimePart = ", start_datetime = NOW(), end_datetime = DATE_ADD(NOW(), INTERVAL " + pHours + " HOUR) ";
            }
        }

        // 3. 상황별 처리 (좌석배정 / 사물함배정 / 단순입실)
        if(seatId != null) {
            String updateResSql = "UPDATE Reservation SET seat_id = ?, status='InUse'" + updateTimePart + " WHERE reservation_id = ?";
            pstmt = conn.prepareStatement(updateResSql);
            pstmt.setString(1, seatId);
            pstmt.setString(2, resId);
            pstmt.executeUpdate();
            pstmt.close();
            
            String updateSeatSql = "UPDATE Seat SET status = 'InUse' WHERE seat_id = ?";
            pstmt = conn.prepareStatement(updateSeatSql);
            pstmt.setString(1, seatId);
            pstmt.executeUpdate();
            pstmt.close();
        } 
        else if(lockerId != null) {
            String updateResSql = "UPDATE Reservation SET locker_id = ?, status='InUse'" + updateTimePart + " WHERE reservation_id = ?";
            pstmt = conn.prepareStatement(updateResSql);
            pstmt.setString(1, lockerId);
            pstmt.setString(2, resId);
            pstmt.executeUpdate();
            pstmt.close();
            
            String updateLockerSql = "UPDATE Locker SET status = 'InUse' WHERE locker_id = ?";
            pstmt = conn.prepareStatement(updateLockerSql);
            pstmt.setString(1, lockerId);
            pstmt.executeUpdate();
            pstmt.close();
        }
        else {
            // 지정석 등 단순 입실
            String finalSql = "UPDATE Reservation SET status='InUse'" + updateTimePart + " WHERE reservation_id = ?";
            pstmt = conn.prepareStatement(finalSql);
            pstmt.setString(1, resId);
            pstmt.executeUpdate();
        }
        
        conn.commit(); 

    } catch(Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
    } finally {
        if(conn != null) conn.close();
    }
%>
<script>
    alert("✅ 입실 처리가 완료되었습니다.\n지금부터 이용 시간이 카운트됩니다.");
    location.href = "main.jsp";

</script>

