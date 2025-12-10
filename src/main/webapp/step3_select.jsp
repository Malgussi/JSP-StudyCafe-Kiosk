<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String branchId = request.getParameter("branchId");
    String selectedDate = request.getParameter("selectedDate");
    String category = request.getParameter("category"); // 'ROOM' or 'SEAT'
    
    // 좌석 세부 타입 (지정석/자유석)
    String seatType = request.getParameter("seatType");
    if(seatType == null) seatType = "FIXED"; 

    // DB 연결
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
<title>3단계: 상세 선택</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; padding: 30px; background-color: #f9f9f9; }
    .container { width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    
    /* 탭 메뉴 */
    .tab-menu { display: flex; margin-bottom: 20px; border-bottom: 2px solid #ddd; }
    .tab-item { 
        padding: 15px 30px; font-size: 18px; cursor: pointer; color: #666; text-decoration: none; 
        border-bottom: 3px solid transparent; margin-bottom: -2px;
    }
    .tab-item:hover { color: #1890ff; }
    .tab-item.active { color: #1890ff; border-bottom: 3px solid #1890ff; font-weight: bold; }
    
    /* --- [ROOM] 스타일 --- */
    .room-item { border: 1px solid #ddd; padding: 20px; margin-bottom: 20px; border-radius: 12px; }
    .room-title { font-size: 18px; font-weight: bold; color: #333; margin-bottom: 10px; display: block;}
    
    .time-grid { display: flex; width: 100%; overflow-x: auto; padding-bottom: 5px; user-select: none; }
    .time-slot { 
        flex: 1; height: 50px; border: 1px solid #e0e0e0; border-right: none; 
        display: flex; align-items: center; justify-content: center; font-size: 12px; 
        cursor: pointer; background-color: white; transition: all 0.1s; position: relative;
    }
    .time-slot:last-child { border-right: 1px solid #e0e0e0; }
    .time-slot:not(.disabled):hover { background-color: #e8f5e9; }
    
    /* 상태별 스타일 (수리중, 마감 등) */
    .time-slot.disabled { background-color: #eee; color: #aaa; cursor: not-allowed; pointer-events: none; }
    .time-slot.maintenance { background-color: #ffebee; color: #d32f2f; font-weight:bold; cursor: help; } /* 수리중 */
    .time-slot.selected-start { background-color: #2E7D32; color: white; font-weight: bold; }
    .time-slot.selected-range { background-color: #4CAF50; color: white; }

    /* --- [SEAT] 스타일 --- */
    .seat-grid { 
        display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; 
        margin-top: 20px; padding: 20px; background-color: #f0f2f5; border-radius: 10px;
    }
    .seat-box { 
        background: white; border: 1px solid #ccc; border-radius: 8px; 
        padding: 20px 10px; text-align: center; cursor: pointer; position: relative;
        transition: 0.2s; box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    .seat-box:hover { transform: translateY(-3px); box-shadow: 0 5px 10px rgba(0,0,0,0.1); border-color: #1890ff; }
    
    .seat-box.disabled { background-color: #eee; color: #aaa; cursor: not-allowed; pointer-events: none; border-color: #ddd; }
    
    .seat-box:has(input:checked) { background-color: #1890ff; color: white; border-color: #1890ff; font-weight: bold; }
    .seat-box input[type="radio"] { position: absolute; opacity: 0; cursor: pointer; inset:0; width:100%; height:100%; }
    
    .seat-num { font-size: 20px; font-weight: bold; display: block; margin-bottom: 5px; }
    .seat-desc { font-size: 12px; color: #666; display: block; }
    .seat-box:has(input:checked) .seat-desc { color: #e6f7ff; }

    /* 공통 요소 */
    .legend { display: flex; gap: 15px; font-size: 14px; margin-bottom: 10px; color: #666; }
    .box { width: 15px; height: 15px; display: inline-block; border-radius: 3px; margin-right: 5px; vertical-align: middle; }
    .box.available { border: 1px solid #ccc; background: white; }
    .box.disabled { background: #eee; }
    .box.maint { background: #ffebee; } /* 수리중 범례 */
    .box.selected { background: #4CAF50; }
    .box.seat-selected { background: #1890ff; }

    /* 상품 섹션 */
    .prod-section { margin-top: 40px; display: none; border-top: 2px dashed #ddd; padding-top: 30px;}
    .prod-section.active { display: block; animation: fadeIn 0.5s; }
    .prod-list { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 15px; }
    .prod-item { border: 1px solid #ddd; padding: 15px; border-radius: 8px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
    .prod-item:has(input:checked) { background-color: #e6f7ff; border-color: #1890ff; }

    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

    .bottom-bar { position: fixed; bottom: 0; left: 0; width: 100%; background: white; padding: 20px; border-top: 1px solid #ddd; display: flex; justify-content: center; gap: 20px; transform: translateY(100%); transition: 0.3s; z-index: 100; }
    .bottom-bar.active { transform: translateY(0); }
    .next-btn { padding: 12px 30px; background-color: #2E7D32; color: white; font-size: 18px; border: none; border-radius: 8px; cursor: pointer; }
    .next-btn:disabled { background-color: #ccc; cursor: not-allowed; }
</style>

<script>
    // [ROOM] 시간 선택 로직
    let currentRoomId = null;
    let startHour = null;
    let endHour = null;

    function selectTime(roomId, hour) {
        if (currentRoomId !== roomId) { resetSelection(); currentRoomId = roomId; }
        if (startHour === null) { startHour = hour; endHour = hour; } 
        else {
            if (hour < startHour) { startHour = hour; endHour = hour; } 
            else {
                if (checkObstacle(roomId, startHour, hour)) { alert("선택하신 구간에 예약 불가(마감/수리) 시간이 포함되어 있습니다."); return; }
                endHour = hour;
            }
        }
        renderSelection();
        updateFormRoom();
    }

    function checkObstacle(roomId, start, end) {
        for (let h = start; h <= end; h++) {
            let el = document.getElementById('slot-' + roomId + '-' + h);
            if (el.classList.contains('disabled') || el.classList.contains('maintenance')) return true;
        }
        return false;
    }

    function renderSelection() {
        document.querySelectorAll('.time-slot').forEach(el => el.classList.remove('selected-start', 'selected-range'));
        if (currentRoomId !== null && startHour !== null) {
            for (let h = startHour; h <= endHour; h++) {
                let el = document.getElementById('slot-' + currentRoomId + '-' + h);
                if(el) {
                    if (h === startHour) el.classList.add('selected-start');
                    else el.classList.add('selected-range');
                }
            }
        }
    }

    function resetSelection() {
        currentRoomId = null; startHour = null; endHour = null;
        renderSelection();
        document.querySelector('.bottom-bar').classList.remove('active');
    }

    function updateFormRoom() {
        if (currentRoomId !== null && startHour !== null) {
            let duration = (endHour - startHour) + 1;
            let startTimeStr = (startHour < 10 ? "0" : "") + startHour + ":00";
            document.getElementById('selectedRoom').value = currentRoomId;
            document.getElementById('selectedStartTime').value = startTimeStr;
            document.getElementById('selectedDuration').value = duration;
            document.getElementById('submitBtnRoom').disabled = false;
            document.querySelector('.bottom-bar').classList.add('active');
        }
    }

    // [SEAT] 탭 이동 & 상품 표시
    function changeTab(type) {
        location.href = "step3_select.jsp?branchId=<%=branchId%>&selectedDate=<%=selectedDate%>&category=SEAT&seatType=" + type;
    }
    
    function showProducts() {
        document.getElementById('productSection').classList.add('active');
        // 부드럽게 스크롤 이동
        setTimeout(function() {
            document.getElementById('productSection').scrollIntoView({ behavior: 'smooth', block: 'start' });
        }, 100);
    }
</script>
</head>
<body>
    <div class="container">
        
        <% if ("ROOM".equals(category)) { %>
            <h3>📅 룸별 예약 현황 (<%= selectedDate %>)</h3>
            <div class="legend">
                <span><span class="box available"></span>예약가능</span>
                <span><span class="box disabled"></span>마감</span>
                <span><span class="box maint"></span>수리중(사유)</span>
                <span><span class="box selected"></span>선택구간</span>
            </div>
            <hr>

            <form action="step4_cart.jsp" method="post">
                <input type="hidden" name="branchId" value="<%= branchId %>">
                <input type="hidden" name="selectedDate" value="<%= selectedDate %>">
                <input type="hidden" name="category" value="ROOM">
                <input type="hidden" name="targetId" id="selectedRoom">
                <input type="hidden" name="startTime" id="selectedStartTime">
                <input type="hidden" name="duration" id="selectedDuration">

                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(url, id, pw);
                        
                        String roomSql = "SELECT * FROM Room WHERE branch_id = ? ORDER BY capacity DESC";
                        pstmt = conn.prepareStatement(roomSql);
                        pstmt.setString(1, branchId);
                        rs = pstmt.executeQuery();
                        
                        while(rs.next()) {
                            String rId = rs.getString("room_id");
                            String rName = rs.getString("room_name");
                            String rType = rs.getString("room_type");
                %>
                    <div class="room-item">
                        <span class="room-title">🚪 <%= rName %> <small>(<%= rType %>)</small></span>
                        <div class="time-grid">
                            <%
                                PreparedStatement chkStmt = null; ResultSet chkRs = null;
                                for(int hour=9; hour<=22; hour++) {
                                    String timeStr = String.format("%02d:00", hour);
                                    String checkDateTime = selectedDate + " " + timeStr + ":00";
                                    
                                    boolean isBooked = false;
                                    boolean isMaint = false;
                                    String maintReason = "";
                                    
                                    // 1. 예약 확인
                                    String bookSql = "SELECT count(*) FROM Reservation WHERE room_id=? AND status IN ('Scheduled','InUse') AND start_datetime <= ? AND end_datetime > ?";
                                    chkStmt = conn.prepareStatement(bookSql);
                                    chkStmt.setString(1, rId); chkStmt.setString(2, checkDateTime); chkStmt.setString(3, checkDateTime);
                                    chkRs = chkStmt.executeQuery();
                                    if(chkRs.next() && chkRs.getInt(1)>0) isBooked=true;
                                    
                                    // 2. 유지보수 확인
                                    if(!isBooked) {
                                        String maintSql = "SELECT reason FROM Room_Maintenance WHERE room_id=? AND start_datetime <= ? AND end_datetime > ?";
                                        chkStmt = conn.prepareStatement(maintSql);
                                        chkStmt.setString(1, rId); chkStmt.setString(2, checkDateTime); chkStmt.setString(3, checkDateTime);
                                        chkRs = chkStmt.executeQuery();
                                        if(chkRs.next()) {
                                            isMaint = true;
                                            maintReason = chkRs.getString("reason");
                                        }
                                    }
                                    
                                    String statusClass = "";
                                    String displayText = hour + "시";
                                    String tooltip = "";
                                    String onClick = "selectTime('" + rId + "', " + hour + ")";

                                    if(isBooked) {
                                        statusClass = "disabled";
                                        displayText = "마감";
                                        onClick = "";
                                    } else if(isMaint) {
                                        statusClass = "maintenance";
                                        displayText = "수리";
                                        tooltip = "title='⛔ " + maintReason + "'";
                                        onClick = "alert('⛔ 예약 불가: " + maintReason + "');";
                                    }
                            %>
                                <div id="slot-<%= rId %>-<%= hour %>" 
                                     class="time-slot room-<%= rId %> <%= statusClass %>" 
                                     <%= tooltip %> 
                                     onclick="<%= onClick %>">
                                    <%= displayText %>
                                </div>
                            <% } if(chkRs!=null) chkRs.close(); if(chkStmt!=null) chkStmt.close(); %>
                        </div>
                    </div>
                <% } } catch(Exception e) { e.printStackTrace(); } finally { if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close(); } %>
                
                <div class="bottom-bar">
                    <button type="submit" id="submitBtnRoom" class="next-btn" disabled>장바구니 담기 🛒</button>
                </div>
            </form>

        <% } else { %>
            
            <div class="tab-menu">
                <a onclick="changeTab('FIXED')" class="tab-item <%= "FIXED".equals(seatType) ? "active" : "" %>">지정석 (기간권)</a>
                <a onclick="changeTab('FREE')" class="tab-item <%= "FREE".equals(seatType) ? "active" : "" %>">자유석 (시간권)</a>
            </div>

            <form action="step4_cart.jsp" method="post">
                <input type="hidden" name="branchId" value="<%= branchId %>">
                <input type="hidden" name="selectedDate" value="<%= selectedDate %>">
                <input type="hidden" name="category" value="SEAT">
                <input type="hidden" name="seatType" value="<%= seatType %>">
                <input type="hidden" name="startTime" value="00:00">
                <input type="hidden" name="duration" value="0">

                <% if ("FIXED".equals(seatType)) { %>
                    <h3>1. 이용하실 좌석을 선택해주세요</h3>
                    <div class="legend" style="margin-bottom:0;">
                        <span><span class="box available"></span>선택가능</span>
                        <span><span class="box disabled"></span>사용중</span>
                        <span><span class="box seat-selected"></span>선택함</span>
                    </div>

                    <div class="seat-grid">
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection(url, id, pw);
                                
                                String seatSql = "SELECT * FROM Seat WHERE branch_id = ? AND seat_type NOT IN ('Open') ORDER BY seat_number";
                                pstmt = conn.prepareStatement(seatSql);
                                pstmt.setString(1, branchId);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                                    String sId = rs.getString("seat_id");
                                    String sNum = rs.getString("seat_number");
                                    String sTypeDB = rs.getString("seat_type");
                                    
                                    boolean isBooked = false;
                                    if(!"Available".equals(rs.getString("status"))) isBooked = true;
                                    
                                    if(!isBooked) {
                                        PreparedStatement chkStmt = conn.prepareStatement(
                                            "SELECT count(*) FROM Reservation WHERE seat_id=? AND status IN ('Scheduled','InUse') " +
                                            "AND start_datetime <= ? AND end_datetime >= ?");
                                        String checkDateEnd = selectedDate + " 23:59:59";
                                        String checkDateStart = selectedDate + " 00:00:00";
                                        chkStmt.setString(1, sId); chkStmt.setString(2, checkDateEnd); chkStmt.setString(3, checkDateStart);
                                        ResultSet chkRs = chkStmt.executeQuery();
                                        if(chkRs.next() && chkRs.getInt(1) > 0) isBooked = true;
                                        chkRs.close(); chkStmt.close();
                                    }
                                    
                                    String typeName = "좌석";
                                    if(sTypeDB.contains("Partition")) typeName = "파티션석";
                                    else if(sTypeDB.contains("Cubic")) typeName = "싱글큐빅";
                                    else if(sTypeDB.contains("SingleRoom")) typeName = "1인실";
                                    else if(sTypeDB.contains("New")) typeName = "뉴파티션";
                        %>
                            <label class="seat-box <%= isBooked ? "disabled" : "" %>">
                                <input type="radio" name="targetId" value="<%= sId %>" <%= isBooked ? "disabled" : "required" %> onclick="showProducts()">
                                <span class="seat-num"><%= sNum %></span>
                                <span class="seat-desc"><%= typeName %></span>
                                <% if(isBooked) { %><br><small style="color:red; font-weight:bold;">(사용중)</small><% } %>
                            </label>
                        <% } rs.close(); pstmt.close(); %>
                    </div>
                    
                    <div id="productSection" class="prod-section">
                        <h3>2. 이용 기간을 선택해주세요</h3>
                        <div class="prod-list">
                            <%
                                    String prodSql = "SELECT * FROM Product WHERE product_type='SEAT' AND days > 0 ORDER BY price";
                                    pstmt = conn.prepareStatement(prodSql);
                                    rs = pstmt.executeQuery();
                                    while(rs.next()) {
                                        int pId = rs.getInt("product_id");
                                        String pName = rs.getString("product_name");
                                        int price = rs.getInt("price");
                            %>
                                <label class="prod-item">
                                    <span><input type="radio" name="productId" value="<%= pId %>" required> <strong><%= pName %></strong></span>
                                    <span style="color:#1890ff; font-weight:bold;"><%= String.format("%,d", price) %>원</span>
                                </label>
                            <% } } catch(Exception e) {} %>
                        </div>
                        <button type="submit" class="next-btn">장바구니 담기 🛒</button>
                    </div>

                <% } else { %>
                    <h3>1. 이용권을 선택해주세요</h3>
                    <div class="prod-list">
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection(url, id, pw);
                                String prodSql = "SELECT * FROM Product WHERE product_type='SEAT' AND (hours > 0 OR fixed_time_hours > 0) ORDER BY price";
                                pstmt = conn.prepareStatement(prodSql);
                                rs = pstmt.executeQuery();
                                while(rs.next()) {
                        %>
                            <label class="prod-item">
                                <span><input type="radio" name="productId" value="<%= rs.getInt("product_id") %>" required> <%= rs.getString("product_name") %></span>
                                <b><%= String.format("%,d", rs.getInt("price")) %>원</b>
                            </label>
                        <% } } catch(Exception e) {} %>
                    </div>
                    <input type="hidden" name="targetId" value="0">
                    <button type="submit" class="next-btn" style="margin-top:20px;">장바구니 담기 🛒</button>
                <% } %>
            </form>
        <% } %>
    </div>
</body>
</html>

<% if(conn!=null) conn.close(); %>

