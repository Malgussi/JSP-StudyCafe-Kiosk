<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 파라미터 받기
    String resId = request.getParameter("resId");
    String seatId = request.getParameter("seatId");

    // DB 연결 정보
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=Asia/Seoul";
    String id = "root";
    String pw = "your_passwd"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 결과 처리를 위한 변수
    boolean isSuccess = false;
    String alertMsg = "";
    int usedMinutes = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 1. 입실 시간과 남은 시간 조회
        String sql = "SELECT start_datetime, remaining_minutes, p.days " +
                     "FROM Reservation r JOIN Product p ON r.product_id = p.product_id " +
                     "WHERE reservation_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, resId);
        rs = pstmt.executeQuery();

        Timestamp startTime = null;
        int remainingMin = 0;
        int pDays = 0;

        if(rs.next()) {
            startTime = rs.getTimestamp("start_datetime");
            remainingMin = rs.getInt("remaining_minutes");
            pDays = rs.getInt("days");
        }
        pstmt.close();

        // 2. 이용 시간 계산 (입실 시간이 없으면 0분 처리)
        if(startTime != null) {
            long diff = System.currentTimeMillis() - startTime.getTime();
            usedMinutes = (int) (diff / (1000 * 60)); // 분 단위 변환
        }
        if(usedMinutes < 0) usedMinutes = 0;

        // 3. 시간 차감 로직 (시간권만 차감)
        String updateTimeSql = "";
        String nextStatus = "Scheduled"; // 기본적으로 퇴실 후 다시 '예약 상태'로 돌아감

        if(pDays == 0) { // 시간권
            int newRemaining = remainingMin - usedMinutes;
            if(newRemaining <= 0) {
                newRemaining = 0;
                nextStatus = "Completed"; // 시간 다 썼으면 종료
            }
            // 남은 시간 업데이트 + 입실시간 초기화(NULL)
            updateTimeSql = ", remaining_minutes = " + newRemaining + ", start_datetime = NULL ";
        } else {
            // 기간권 (시간 차감 없음, 입실시간만 초기화)
            updateTimeSql = ", start_datetime = NULL ";
        }

        // 4. 예약 테이블 업데이트 (퇴실 처리)
        // 주의: seat_id를 NULL로 만들지 않으면 다음 입실 때 꼬일 수 있으니 NULL 처리
        String updateResSql = "UPDATE Reservation SET seat_id = NULL, locker_id = NULL, status = ? " + updateTimeSql + " WHERE reservation_id = ?";

        pstmt = conn.prepareStatement(updateResSql);
        pstmt.setString(1, nextStatus);
        pstmt.setString(2, resId);
        pstmt.executeUpdate();
        pstmt.close();

        // 5. 좌석 테이블 업데이트 (좌석 비우기 'Available')
        if(seatId != null && !seatId.equals("null") && !seatId.equals("")) {
            String updateSeatSql = "UPDATE Seat SET status = 'Available' WHERE seat_id = ?";
            pstmt = conn.prepareStatement(updateSeatSql);
            pstmt.setString(1, seatId);
            pstmt.executeUpdate();
            pstmt.close();
        }

        conn.commit(); // 커밋
        isSuccess = true;
        alertMsg = "퇴실 처리가 완료되었습니다.\\n이용 시간: " + usedMinutes + "분";

    } catch(Exception e) {
        if(conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        isSuccess = false;
        alertMsg = "에러 발생: " + e.getMessage().replace("'", "").replace("\n", " ");
    } finally {
        if(pstmt != null) pstmt.close();
        if(conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>퇴실 처리 중</title>
</head>
<body>
    <script>
        // 결과 메시지 띄우기
        alert("<%= alertMsg %>");

        <% if(isSuccess) { %>
            // 성공 시 -> 다시 키오스크 목록(입실 화면)으로 이동
            location.href = "checkin_list.jsp";
        <% } else { %>
            // 실패 시 -> 이전 화면으로 복귀
            history.back();
        <% } %>
    </script>
</body>
</html>
