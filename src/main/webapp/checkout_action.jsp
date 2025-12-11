<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String resId = request.getParameter("resId");
    String seatId = request.getParameter("seatId");

    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=Asia/Seoul";
    String id = "root";
    String pw = "akfrnTl13!"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        conn.setAutoCommit(false);

        // 1. 입실 시간(start_datetime)과 남은 시간 조회
        String sql = "SELECT start_datetime, remaining_minutes, p.days " +
                     "FROM Reservation r JOIN Product p ON r.product_id = p.product_id " +
                     "WHERE reservation_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, resId);
        rs = pstmt.executeQuery();

        Timestamp startTime = null;
        int remainingMin = 0;
        int pDays = 0; // 0이면 시간권, 0보다 크면 기간권

        if(rs.next()) {
            startTime = rs.getTimestamp("start_datetime");
            remainingMin = rs.getInt("remaining_minutes");
            pDays = rs.getInt("days");
        }
        pstmt.close();

        // 2. 이용 시간 계산 (분 단위)
        int usedMinutes = 0;
        if(startTime != null) {
            long diff = System.currentTimeMillis() - startTime.getTime();
            usedMinutes = (int) (diff / (1000 * 60)); // 밀리초 -> 분 변환
        }
        
        // 1분 미만 사용은 0분 처리 or 최소 1분 처리 (여기선 그냥 계산)
        if(usedMinutes < 0) usedMinutes = 0;

        // 3. 시간권이라면 -> 잔여 시간 차감
        String updateTimeSql = "";
        String nextStatus = "Scheduled"; // 퇴실하면 다시 '예약가능' 상태로 (다음에 또 쓰게)

        if(pDays == 0) { // 시간권인 경우만 차감
            int newRemaining = remainingMin - usedMinutes;
            
            if(newRemaining <= 0) {
                newRemaining = 0;
                nextStatus = "Completed"; // 시간 다 썼으면 종료 처리
            }
            
            // start_datetime을 NULL로 초기화해야 다음 입실 때 새로 시간 잴 수 있음
            updateTimeSql = ", remaining_minutes = " + newRemaining + ", start_datetime = NULL ";
        } else {
            // 기간권은 시간 차감 없음, 입실시간만 초기화
            updateTimeSql = ", start_datetime = NULL ";
        }

        // 4. 예약 테이블 업데이트 (퇴실 처리)
        String updateResSql = "UPDATE Reservation SET seat_id = NULL, status = ? " + updateTimeSql + " WHERE reservation_id = ?";
        pstmt = conn.prepareStatement(updateResSql);
        pstmt.setString(1, nextStatus);
        pstmt.setString(2, resId);
        pstmt.executeUpdate();
        pstmt.close();

        // 5. 좌석 테이블 업데이트 (빈 자리로 만듦)
        String updateSeatSql = "UPDATE Seat SET status = 'Available' WHERE seat_id = ?";
        pstmt = conn.prepareStatement(updateSeatSql);
        pstmt.setString(1, seatId);
        pstmt.executeUpdate();

        conn.commit();
        
%>
<script>
    alert("👋 퇴실 처리가 완료되었습니다.\n이용 시간: <%= usedMinutes %>분");
    location.href = "main.jsp";
</script>
<%
    } catch(Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
    } finally {
        if(conn != null) conn.close();
    }
%>