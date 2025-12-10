<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String resId = request.getParameter("resId"); 
    
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "akfrnTl13!"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
<title>사물함 배정</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; padding: 30px; background-color: #f9f9f9; }
    .container { width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    
    h2 { text-align: center; margin-bottom: 10px; color: #333; }
    p.subtitle { text-align: center; color: #666; margin-bottom: 30px; }

    .legend { display: flex; gap: 15px; font-size: 14px; margin-bottom: 15px; color: #666; justify-content: center; }
    .box { width: 15px; height: 15px; display: inline-block; border-radius: 3px; margin-right: 5px; vertical-align: middle; }
    .box.selectable { background: #e8f5e9; border: 2px solid #4CAF50; } 
    .box.disabled { background: #eee; } 

    .locker-grid { 
        display: grid; 
        grid-template-columns: repeat(5, 1fr); 
        gap: 12px; 
        margin-top: 10px; 
    }
    
    .locker-box { 
        border: 1px solid #ccc; padding: 20px 10px; text-align: center; border-radius: 8px; cursor: pointer; 
        transition: 0.2s; background: white; position: relative;
    }
    
    /* 선택 가능 (빈 사물함) */
    .locker-box.selectable {
        border: 2px solid #4CAF50; background-color: #f1f8e9;
    }
    .locker-box.selectable:hover { background-color: #dcedc8; transform: translateY(-3px); }

    /* 선택 불가 (사용 중) */
    .locker-box.disabled { 
        background-color: #eee; color: #aaa; cursor: not-allowed; pointer-events: none; border-color: #ddd;
    }
    
    .locker-num { font-size: 20px; font-weight: bold; display: block; margin-bottom: 5px; }
    .locker-size { font-size: 12px; display: block; color: #555; }
    
    .status-text { font-size: 12px; font-weight: bold; margin-top:5px; display:block;}
    .text-avail { color: #4CAF50; }
    .text-inuse { color: #f44336; }

    .btn-back { display: block; width: 100%; margin-top: 30px; padding: 15px; background-color: #666; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: bold; }
</style>
<script>
    function selectLocker(lockerId, lockerNum) {
        if(confirm(lockerNum + "번 사물함을 사용하시겠습니까?")) {
            location.href = "checkin_action.jsp?resId=<%=resId%>&lockerId=" + lockerId;
        }
    }
</script>
</head>
<body>
    <div class="container">
        <h2>🔑 사물함 배정</h2>
        <p class="subtitle">이용하실 빈 사물함을 선택해주세요.</p>
        
        <div class="legend">
            <span><span class="box selectable"></span>선택가능</span>
            <span><span class="box disabled"></span>사용중</span>
        </div>

        <div class="locker-grid">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, id, pw);
                    
                    // 홍대점(2) 모든 사물함 조회
                    String sql = "SELECT * FROM Locker WHERE branch_id=2 ORDER BY locker_number";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    
                    while(rs.next()) {
                        String lId = rs.getString("locker_id");
                        String lNum = rs.getString("locker_number");
                        String lSize = rs.getString("locker_size"); // Small, Medium
                        String status = rs.getString("status");   
                        
                        if(status == null) status = "Available";

                        // 빈 사물함이면 선택 가능
                        boolean canSelect = "Available".equalsIgnoreCase(status);
                        
                        String boxClass = "";
                        String statusHtml = "";

                        if (canSelect) {
                            boxClass = "selectable";
                            statusHtml = "<span class='status-text text-avail'>선택가능</span>";
                        } else {
                            boxClass = "disabled";
                            statusHtml = "<span class='status-text text-inuse'>사용중</span>";
                        }
            %>
                <div class="locker-box <%= boxClass %>" 
                     onclick="<%= canSelect ? "selectLocker("+lId+", '"+lNum+"')" : "" %>">
                    
                    <span class="locker-num"><%= lNum %></span>
                    <span class="locker-size"><%= lSize %> 사이즈</span>
                    <%= statusHtml %>
                    
                </div>
            <%
                    }
                } catch(Exception e) { e.printStackTrace(); } 
                finally { if(conn!=null) conn.close(); }
            %>
        </div>
        
        <button class="btn-back" onclick="history.back()">뒤로가기</button>
    </div>
</body>
</html>