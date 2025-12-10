<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String resId = request.getParameter("resId"); 
    
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "your_password"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
<title>좌석 배정 (키오스크)</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; padding: 30px; background-color: #f9f9f9; }
    .container { width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    
    h2 { text-align: center; margin-bottom: 10px; color: #333; }
    p.subtitle { text-align: center; color: #666; margin-bottom: 30px; }

    .legend { display: flex; gap: 15px; font-size: 14px; margin-bottom: 15px; color: #666; justify-content: center; }
    .box { width: 15px; height: 15px; display: inline-block; border-radius: 3px; margin-right: 5px; vertical-align: middle; }
    .box.selectable { background: #e8f5e9; border: 2px solid #4CAF50; } 
    .box.disabled { background: #eee; } 

    .seat-grid { 
        display: grid; 
        grid-template-columns: repeat(5, 1fr); 
        gap: 12px; 
        margin-top: 10px; 
    }
    
    .seat-box { 
        border: 1px solid #ccc; padding: 15px 5px; text-align: center; border-radius: 8px; cursor: pointer; 
        transition: 0.2s; background: white; position: relative;
    }
    
    /* [1] 선택 가능 (빈 자리면 무조건!) */
    .seat-box.selectable {
        border: 2px solid #4CAF50; background-color: #f1f8e9;
    }
    .seat-box.selectable:hover { background-color: #dcedc8; transform: translateY(-3px); }

    /* [2] 선택 불가 (누가 쓰고 있음) */
    .seat-box.disabled { 
        background-color: #eee; color: #aaa; cursor: not-allowed; pointer-events: none; border-color: #ddd;
    }
    
    .seat-num { font-size: 18px; font-weight: bold; display: block; margin-bottom: 5px; }
    .seat-desc { font-size: 12px; display: block; color: #555; }
    
    .status-text { font-size: 12px; font-weight: bold; margin-top:5px; display:block;}
    .text-avail { color: #4CAF50; }
    .text-inuse { color: #f44336; }

    .btn-back { display: block; width: 100%; margin-top: 30px; padding: 15px; background-color: #666; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: bold; }
    .btn-back:hover { background-color: #444; }
</style>
<script>
    function selectSeat(seatId, seatNum) {
        if(confirm(seatNum + "번 좌석을 배정받으시겠습니까?")) {
            location.href = "checkin_action.jsp?resId=<%=resId%>&seatId=" + seatId;
        }
    }
</script>
</head>
<body>
    <div class="container">
        <h2>💺 좌석 배정 (입실)</h2>
        <p class="subtitle">빈 좌석을 선택하면 즉시 입실 처리됩니다.</p>
        
        <div class="legend">
            <span><span class="box selectable"></span>선택가능</span>
            <span><span class="box disabled"></span>사용중(입실불가)</span>
        </div>

        <div class="seat-grid">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, id, pw);
                    
                    // 홍대점(2) 모든 좌석 조회
                    String sql = "SELECT * FROM Seat WHERE branch_id=2 ORDER BY seat_number";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    
                    while(rs.next()) {
                        String sId = rs.getString("seat_id");
                        String sNum = rs.getString("seat_number");
                        String sType = rs.getString("seat_type"); 
                        String status = rs.getString("status");   
                        
                        if(sType == null) sType = "";
                        if(status == null) status = "Available";

                        boolean canSelect = "Available".equalsIgnoreCase(status);
                        
                        // 화면 표시 텍스트
                        String typeText = "";
                        if(sType.contains("Free")) typeText = "오픈석";
                        else if(sType.contains("Partition")) typeText = "파티션석";
                        else if(sType.contains("Cubic")) typeText = "싱글큐빅";
                        else if(sType.contains("Single")) typeText = "1인실";
                        else typeText = "좌석";

                        String boxClass = "";
                        String statusHtml = "";

                        if (canSelect) {
                            // [선택 가능] 초록색
                            boxClass = "selectable";
                            statusHtml = "<span class='status-text text-avail'>선택가능</span>";
                        } else {
                            // [선택 불가] 이미 누가 앉아있음
                            boxClass = "disabled";
                            statusHtml = "<span class='status-text text-inuse'>사용중</span>";
                        }
            %>
                <div class="seat-box <%= boxClass %>" 
                     onclick="<%= canSelect ? "selectSeat("+sId+", '"+sNum+"')" : "" %>">
                    
                    <span class="seat-num"><%= sNum %></span>
                    <span class="seat-desc"><%= typeText %></span>
                    <%= statusHtml %>
                    
                </div>
            <%
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally { 
                    if(conn!=null) conn.close(); 
                }
            %>
        </div>
        
        <button class="btn-back" onclick="history.back()">뒤로가기</button>
    </div>
</body>

</html>
