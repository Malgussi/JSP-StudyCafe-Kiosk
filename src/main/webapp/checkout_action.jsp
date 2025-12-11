<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String resId = request.getParameter("resId");
    String seatId = request.getParameter("seatId"); // 좌석 ID (Room ID 포함)

    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=Asia/Seoul";
    String id = "root";
    String pw = "your_passwd"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    boolean isSuccess = false;
    String alertMsg = "";
    int usedMinutes = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        conn.setAutoCommit(false); 

        // 1. 예약 정보와 상품 정보 조회
        String sql = "SELECT r.start_datetime, r.remaining_minutes, p.days, p.product_type " +
                     "FROM Reservation r JOIN Product p ON r.product_id = p.product_id " +
                     "WHERE reservation_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, resId);
        rs = pstmt.executeQuery();

        Timestamp startTime = null;
        int remainingMin = 0;
        int pDays = 0;
        String pType = "";

        if(rs.next()) {
            startTime = rs.getTimestamp("start_datetime");
            remainingMin = rs.getInt("remaining_minutes");
            pDays = rs.getInt("days");
            pType = rs.getString("product_type");
        }
        pstmt.close();

        // 2. 이용 시간 계산 (분 단위)
        if(startTime != null) {
            long diff = System.currentTimeMillis() - startTime.getTime();
            usedMinutes = (int) (diff / (1000 * 60));
        }
        if(usedMinutes < 0) usedMinutes = 0;

        // 3. 상태 결정 및 시간 차감 로직
        String nextStatus = "Scheduled"; // ★ 기본값: 퇴실 후 다시 예약 대기 상태로
        String updateTimeSql = ", start_datetime = NULL "; // 입실 시간은 무조건 초기화

        if(pDays == 0 && "SEAT".equals(pType)) { // [시간권]일 경우만 차감 로직 적용
            int newRemaining = remainingMin - usedMinutes;
            
            if(newRemaining <= 0) {
                newRemaining = 0;
                nextStatus = "Completed"; // 잔여 시간이 0이면 완전히 종료
            }
            updateTimeSql = ", remaining_minutes = " + newRemaining + ", start_datetime = NULL ";
        } 
        
        // 사물함(LOCKER)인 경우 상태를 InUse 전 상태 (Active 또는 Scheduled)로 되돌림
        if("LOCKER".equals(pType)) {
             nextStatus = "Active"; // 사물함은 보통 Active로 관리됨
        }


        // 4. 예약 테이블 업데이트 (퇴실 처리)
        // 좌석/룸 ID만 NULL로 만들고, 사물함 ID는 유지
        String updateResSql = "UPDATE Reservation SET seat_id = NULL, status = ? " + updateTimeSql + " WHERE reservation_id = ?";
        
        pstmt = conn.prepareStatement(updateResSql);
        pstmt.setString(1, nextStatus);
        pstmt.setString(2, resId);
        pstmt.executeUpdate();
        pstmt.close();

        // 5. 좌석/룸 테이블 업데이트 (빈 자리로 만듦)
        // 좌석/룸일 때만 상태를 Available로 변경 (사물함은 이용 종료 버튼이 없거나, 다른 프로세스가 필요)
        if(seatId != null && !seatId.isEmpty() && !"LOCKER".equals(pType)) {
            String updateSeatSql = "UPDATE Seat SET status = 'Available' WHERE seat_id = ?";
            pstmt = conn.prepareStatement(updateSeatSql);
            pstmt.setString(1, seatId);
            pstmt.executeUpdate();
        }
        
        conn.commit(); 
        isSuccess = true;
        alertMsg = "퇴실 처리가 완료되었습니다.\\n이용 시간: " + usedMinutes + "분";

    } catch(Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        isSuccess = false;
        alertMsg = "에러 발생: " + e.getMessage().replace("'", "").replace("\n", " ");
    } finally {
        if(pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if(conn != null) try { conn.close(); } catch(SQLException ex) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>퇴실 처리 결과</title>
</head>
<body>
    <script>
        alert("✅ <%= alertMsg %>");

        <% if(isSuccess) { %>
            // 성공 시 -> 다시 키오스크 목록 화면으로 이동
            location.href = "checkin_list.jsp";
        <% } else { %>
            // 실패 시 -> 이전 화면으로 복귀
            history.back();
        <% } %>
    </script>
</body>
</html>
