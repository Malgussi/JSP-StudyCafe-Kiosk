<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 1. 로그인 세션 체크
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. DB 연결 정보
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=Asia/Seoul";
    String id = "root";
    String pw = "your_passwd";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
<title>키오스크 - 입실/퇴실</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; padding: 20px; text-align: center; }
    .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
    
    h2 { color: #333; margin-bottom: 10px; }
    .subtitle { color: #666; margin-bottom: 30px; }

    /* 리스트 카드 스타일 */
    .ticket-list { display: flex; flex-direction: column; gap: 15px; }
    .ticket-box { 
        border: 1px solid #ddd; padding: 20px; border-radius: 10px; 
        display: flex; justify-content: space-between; align-items: center;
        background: white; transition: 0.2s;
    }
    .ticket-box:hover { box-shadow: 0 5px 15px rgba(0,0,0,0.05); transform: translateY(-2px); }

    .info-area { text-align: left; }
    .prod-name { font-size: 18px; font-weight: bold; color: #333; margin-bottom: 5px; }
    .seat-info { font-size: 14px; color: #666; margin-bottom: 3px; }
    .time-info { font-size: 12px; color: #888; }
    
    .seat-badge { font-weight: bold; color: #007bff; }
    .locker-badge { font-weight: bold; color: #e67e22; }

    /* 버튼 스타일 */
    .btn { padding: 12px 20px; border: none; border-radius: 6px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; }
    
    /* 입실 버튼 (초록) */
    .btn-checkin { background-color: #28a745; color: white; }
    .btn-checkin:hover { background-color: #218838; }

    /* 좌석 선택 버튼 (노랑) */
    .btn-select { background-color: #ffc107; color: #333; }
    .btn-select:hover { background-color: #e0a800; }

    /* 퇴실 버튼 (빨강) */
    .btn-checkout { background-color: #dc3545; color: white; }
    .btn-checkout:hover { background-color: #c82333; }

    /* 비활성 버튼 (회색) */
    .btn-disabled { background-color: #e9ecef; color: #adb5bd; cursor: not-allowed; }

    .btn-back { margin-top: 30px; padding: 10px 30px; background: #fff; border: 1px solid #ccc; border-radius: 20px; cursor: pointer; }
</style>
<script>
    function checkIn(resId, targetId) {
        if(confirm('입실 하시겠습니까?')) {
            // targetId가 null이면 빈 문자열로 처리 (오류 방지)
            if(targetId == null || targetId == 'null') targetId = '';
            
            // 사물함인지 좌석인지 구분 없이, ID가 있으면 넘김
            // (checkin_action.jsp가 알아서 처리함)
            location.href = 'checkin_action.jsp?resId=' + resId + '&seatId=' + targetId + '&lockerId=' + targetId;
        }
    }

    function checkOut(resId, seatId) {
        if(confirm('정말 이용을 종료(퇴실) 하시겠습니까?\n남은 시간은 저장됩니다.')) {
            location.href = 'checkout_action.jsp?resId=' + resId + '&seatId=' + seatId;
        }
    }
</script>
</head>
<body>

    <div class="container">
        <h2>📱 키오스크 (입실 대기 목록)</h2>
        <p class="subtitle">사용하실 이용권을 선택해주세요.</p>

        <div class="ticket-list">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, id, pw);

                    // 나의 'Scheduled(예약됨)' 또는 'InUse(사용중)' 상태인 예약 조회
                    String sql = "SELECT r.*, p.product_name, p.product_type " +
                                 "FROM Reservation r JOIN Product p ON r.product_id = p.product_id " +
                                 "WHERE r.member_id = ? AND r.status IN ('Scheduled', 'InUse') " +
                                 "ORDER BY r.status ASC, r.reservation_id DESC";
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, userId);
                    rs = pstmt.executeQuery();

                    while(rs.next()) {
                        int rId = rs.getInt("reservation_id");
                        String rStatus = rs.getString("status");
                        String pName = rs.getString("product_name");
                        String pType = rs.getString("product_type"); // SEAT, LOCKER, ROOM
                        
                        String seatId = rs.getString("seat_id");
                        String lockerId = rs.getString("locker_id");
                        
                        // 화면에 보여줄 시작/종료 시간
                        Timestamp startTs = rs.getTimestamp("start_datetime");
                        Timestamp endTs = rs.getTimestamp("end_datetime");
                        
                        // 오픈 대기 기능용 시간 비교
                        long nowTime = System.currentTimeMillis();
                        long startTime = (startTs != null) ? startTs.getTime() : 0;
                        boolean isTimeOk = (nowTime >= startTime); // 현재 시간이 시작 시간보다 지났는가?

                        String dateStr = (startTs != null && endTs != null) ? 
                                         startTs.toString().substring(5, 16) + " ~ " + endTs.toString().substring(5, 16) : "기간 미정";
            %>
            
                <div class="ticket-box">
                    <div class="info-area">
                        <div class="prod-name"><%= pName %></div>
                        
                        <div class="seat-info">
                            <% if("LOCKER".equals(pType)) { %>
                                🔑 <span class="locker-badge">
                                    <%= (lockerId != null) ? "사물함 번호: " + lockerId : "사물함 미지정" %>
                                </span>
                            <% } else { %>
                                💺 <span class="seat-badge">
                                    <%= (seatId != null) ? "지정석/룸: " + seatId : "좌석 미지정" %>
                                </span>
                            <% } %>
                        </div>
                        
                        <div class="time-info">이용 기간: <%= dateStr %></div>
                    </div>

                    <div class="btn-area">
                        <% 
                           // 1. [이용 중] 상태일 때 -> 퇴실 버튼 표시
                           if ("InUse".equals(rStatus)) { 
                        %>
                            <% if(!"LOCKER".equals(pType)) { %>
                                <button class="btn btn-checkout" onclick="checkOut(<%=rId%>, '<%=seatId%>')">
                                    이용중 (퇴실하기) 👋
                                </button>
                            <% } else { %>
                                <button class="btn btn-checkin" style="cursor:default;">이용 중 ✅</button>
                            <% } %>

                        <% 
                           // 2. [예약] 상태일 때
                           } else if ("Scheduled".equals(rStatus)) { 
                        %>
                            <% 
                               // (A) 좌석 선택이 필요한 경우: 
                               // "SEAT" 타입이면서 아직 좌석번호가 없는 경우만 해당 (ROOM은 제외!)
                               if (seatId == null && "SEAT".equals(pType)) { 
                            %>
                                <button class="btn btn-select" onclick="location.href='checkin_seat_select.jsp?resId=<%=rId%>'">
                                    좌석 선택 👆
                                </button>

                            <% 
                               // (B) 이미 배정되었거나(사물함/룸/지정석), 선택이 필요 없는 경우
                               } else { 
                            %>
                                <% if (isTimeOk) { %>
                                    <button class="btn btn-checkin" onclick="checkIn(<%=rId%>, '<%= (seatId!=null)?seatId:lockerId %>')">
                                        입실 하기 🚪
                                    </button>
                                <% } else { %>
                                    <button class="btn btn-disabled" disabled>
                                        오픈 대기 ⏳
                                    </button>
                                <% } %>
                            <% } %>
                        
                        <% } %>
                    </div>
                </div>

            <%
                    } // while 종료
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(rs!=null) rs.close();
                    if(pstmt!=null) pstmt.close();
                    if(conn!=null) conn.close();
                }
            %>
        </div>

        <button class="btn-back" onclick="location.href='main.jsp'">← 메인으로 돌아가기</button>
    </div>

</body>
</html>
