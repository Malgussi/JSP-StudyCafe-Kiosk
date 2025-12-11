<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { 
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
        return; 
    }

    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=Asia/Seoul";
    String id = "root";
    String pw = "your_passwd"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
<title>입실/이용 선택</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; background-color: #f0f2f5; padding: 30px; text-align: center; }
    .container { width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    .ticket-box { border: 2px solid #ddd; border-radius: 10px; padding: 20px; margin-bottom: 20px; text-align: left; position: relative; background-color: #fff; }
    .ticket-title { font-size: 20px; font-weight: bold; color: #333; margin-bottom: 5px; }
    .ticket-info { color: #666; font-size: 14px; }
    .ticket-time { font-size: 13px; color: #999; margin-top: 3px; }
    
    .btn-enter { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); padding: 12px 25px; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; color: white; font-size: 16px; }
    .btn-blue { background-color: #1890ff; } 
    .btn-green { background-color: #4CAF50; } 
    .btn-orange { background-color: #ff9800; } 
    .btn-gray { background-color: #9e9e9e; cursor: not-allowed; } /* 대기 */
    .btn-dark { background-color: #555; cursor: not-allowed; } /* 종료 */
    
    .empty-msg { color: #888; margin-top: 50px; font-size: 18px; }
</style>
</head>
<body>
    <div class="container">
        <h2>📱 키오스크 (입실 대기 목록)</h2>
        <p style="color:#666; margin-bottom:30px;">사용하실 이용권을 선택해주세요.</p>
        
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, id, pw);
                
                // end_datetime 도 같이 조회
                String sql = "SELECT r.reservation_id, r.seat_id, r.locker_id, r.start_datetime, r.end_datetime, r.status, " +
                             "p.product_name, p.product_type, " +
                             "s.seat_number, rm.room_name, l.locker_number " +
                             "FROM Reservation r " +
                             "JOIN Product p ON r.product_id = p.product_id " +
                             "LEFT JOIN Seat s ON r.seat_id = s.seat_id " +
                             "LEFT JOIN Room rm ON r.room_id = rm.room_id " +
                             "LEFT JOIN Locker l ON r.locker_id = l.locker_id " +
                             "WHERE r.member_id = ? AND r.status IN ('Scheduled', 'Active', 'Paid', 'InUse') " +
                             "ORDER BY r.start_datetime DESC";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, userId);
                rs = pstmt.executeQuery();
                
                boolean hasTicket = false;
                while(rs.next()) {
                    hasTicket = true;
                    int resId = rs.getInt("reservation_id");
                    String pName = rs.getString("product_name");
                    String type = rs.getString("product_type"); 
                    String status = rs.getString("status");
                    Timestamp startDt = rs.getTimestamp("start_datetime");
                    Timestamp endDt = rs.getTimestamp("end_datetime"); // 종료 시간
                    
                    String seatNum = rs.getString("seat_number");
                    String roomName = rs.getString("room_name");
                    String lockerNum = rs.getString("locker_number");
                    
                    // 시간 체크 로직
                    Timestamp now = new Timestamp(System.currentTimeMillis());
                    boolean isFuture = startDt.after(now); // 미래인가?
                    boolean isExpired = (endDt != null) && now.after(endDt); // 끝났는가? (현재시간 > 종료시간)
                    boolean isInUse = "InUse".equals(status);
                    
                    String startStr = sdf.format(startDt);
                    String endStr = (endDt != null) ? sdf.format(endDt) : "";
                    
                    String timeText = "이용 시간: " + startStr + " ~ " + endStr;
                    if(endDt == null) timeText = "시작 일시: " + startStr; // 기간권 등
                    
                    // 텍스트 정리
                    String infoText = "";
                    if(seatNum == null && "SEAT".equals(type)) infoText = "📢 좌석 미지정";
                    else if(lockerNum == null && "LOCKER".equals(type)) infoText = "🔒 사물함 미지정";
                    else if(roomName != null) infoText = "🚪 스터디룸: " + roomName;
                    else if(lockerNum != null) infoText = "🔑 사물함 번호: " + lockerNum;
                    else infoText = "💺 지정석: " + seatNum;
        %>
            <div class="ticket-box">
                <div class="ticket-title"><%= pName %></div>
                <div class="ticket-info"><%= infoText %></div>
                <div class="ticket-time"><%= timeText %></div>
                
                <% 
                   // [버튼 로직]
                   
                   // 1. 이미 입실 처리된 경우
                   if(isInUse) { 
                %>
                    <button class="btn-enter btn-green" onclick="alert('현재 이용 중입니다.')">이용 중 ✅</button>
                
                <% 
                   // 2. 이미 종료된 시간인 경우
                   } else if(isExpired) { 
                %>
                    <button class="btn-enter btn-dark" onclick="alert('이용 시간이 종료되었습니다.')">이용 종료 🚫</button>

                <% 
                   // 3. 시간이 아직 안 된 경우 (미래)
                   } else if(isFuture) { 
                %>
                    <button class="btn-enter btn-gray" onclick="alert('예약 시간이 되어야 입실할 수 있습니다.\n시작시간: <%= startStr %>')">오픈 대기 ⏳</button>
                
                <% 
                   // 4. 입장 가능!
                   } else {
                        if("SEAT".equals(type)) {
                            if(seatNum == null) {
                %>
                                <button class="btn-enter btn-blue" onclick="location.href='checkin_seat_select.jsp?resId=<%= resId %>'">좌석 선택 💺</button>
                <%          } else { %>
                                <button class="btn-enter btn-green" onclick="location.href='checkin_action.jsp?resId=<%= resId %>'">입실 하기 🚪</button>
                <%          }
                        } else if("LOCKER".equals(type)) {
                            if(lockerNum == null) {
                %>
                                <button class="btn-enter btn-orange" onclick="location.href='checkin_locker_select.jsp?resId=<%= resId %>'">사물함 선택 🔑</button>
                <%          } else { %>
                                <button class="btn-enter btn-green" onclick="location.href='checkin_action.jsp?resId=<%= resId %>'">사용 하기 🔓</button>
                <%          }
                        } else { 
                %>
                        <button class="btn-enter btn-green" onclick="location.href='checkin_action.jsp?resId=<%= resId %>'">입실 하기 🚪</button>
                <%      } 
                   } 
                %>
            </div>
        <%
                }
                if(!hasTicket) {
        %>
            <div class="empty-msg">
                사용 가능한 이용권이 없습니다.<br>
                <a href="step1_date.jsp" style="font-size:16px; color:#1890ff; font-weight:bold;">[예약하러 가기]</a>
            </div>
        <%
                }
            } catch(Exception e) { e.printStackTrace(); }
            finally { if(conn!=null) conn.close(); }
        %>
        
        <div style="margin-top:40px;">
            <a href="main.jsp" style="color:#666; text-decoration:none; border:1px solid #ccc; padding:10px 20px; border-radius:20px;">← 메인으로 돌아가기</a>
        </div>
        </body>
</html>
