<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<title>2단계: 상품군 선택</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; text-align: center; padding: 50px; background-color: #f9f9f9; }
    .container { width: 700px; margin: 0 auto; background: white; padding: 40px; border-radius: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
    h2 { color: #333; margin-bottom: 10px; }
    .info-text { color: #666; margin-bottom: 30px; font-size: 18px; }
    
    /* 카드형 버튼 스타일 */
    .card-container { display: flex; justify-content: center; gap: 20px; }
    .card { 
        width: 280px; height: 350px; border: 2px solid #eee; border-radius: 15px; 
        display: flex; flex-direction: column; align-items: center; justify-content: center;
        cursor: pointer; transition: all 0.3s ease; text-decoration: none; color: #333;
    }
    .card:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0,0,0,0.2); border-color: #4CAF50; }
    .icon { font-size: 80px; margin-bottom: 20px; }
    .card-title { font-size: 24px; font-weight: bold; margin-bottom: 10px; }
    .card-desc { font-size: 14px; color: #888; padding: 0 20px; }
</style>
</head>
<body>
    <%
        request.setCharacterEncoding("UTF-8");
        // 1. 이전 단계(Step 1)에서 보낸 정보 받기
        String branchId = request.getParameter("branchId");
        String selectedDate = request.getParameter("selectedDate");
        String branchName = "";

        // 지점 이름 가져오기 (UX용)
        String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
        String id = "root";
        String pw = "akfrnTl13!"; // ★ 본인 비번으로 수정!

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, id, pw);
            String sql = "SELECT branch_name FROM Branch WHERE branch_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, branchId);
            ResultSet rs = pstmt.executeQuery();
            if(rs.next()) branchName = rs.getString("branch_name");
            rs.close(); pstmt.close(); conn.close();
        } catch(Exception e) { e.printStackTrace(); }
    %>

    <div class="container">
        <h2>🚩 어떤 공간을 이용하시겠습니까?</h2>
        <p class="info-text">
            <strong><%= branchName %></strong> <br> 
            선택일: <span style="color:#4CAF50"><%= selectedDate %></span>
        </p>
        <hr><br>

        <div class="card-container">
            <a href="step3_select.jsp?branchId=<%=branchId%>&selectedDate=<%=selectedDate%>&category=ROOM" class="card">
                <div class="icon">🚪</div>
                <div class="card-title">스터디룸 예약</div>
                <div class="card-desc">
                    팀플, 회의, 과외 등<br>
                    독립된 공간이 필요할 때<br>
                    (4인실, 6인실, 세미나룸)
                </div>
            </a>

            <a href="step3_select.jsp?branchId=<%=branchId%>&selectedDate=<%=selectedDate%>&category=SEAT" class="card">
                <div class="icon">🪑</div>
                <div class="card-title">좌석 이용권</div>
                <div class="card-desc">
                    혼자 집중해서 공부할 때<br>
                    원하는 시간만큼 자유롭게<br>
                    (지정석, 자유석, 1인실)
                </div>
            </a>
        </div>
        
        <br><br>
        <a href="step1_date.jsp" style="color: #999; text-decoration: none;">⬅️ 날짜 다시 선택하기</a>
    </div>
</body>
</html>