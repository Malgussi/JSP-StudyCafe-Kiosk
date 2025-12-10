<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<title>1단계: 날짜 및 지점 선택</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; text-align: center; padding: 50px; }
    .container { width: 600px; margin: 0 auto; border: 1px solid #ddd; padding: 30px; border-radius: 15px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    h2 { color: #333; }
    select, input[type="date"] { width: 100%; padding: 12px; margin: 10px 0; font-size: 16px; border-radius: 5px; border: 1px solid #ccc; }
    button { width: 100%; padding: 15px; background-color: #4CAF50; color: white; font-size: 18px; border: none; border-radius: 5px; cursor: pointer; margin-top: 20px; }
    button:hover { background-color: #45a049; }
</style>
</head>
<body>
    <div class="container">
        <h2>📅 날짜 및 지점 선택</h2>
        <p>이용하실 날짜와 지점을 먼저 선택해주세요.</p>
        <hr>
        
        <form action="step2_category.jsp" method="get"> <h3>📍 지점 선택</h3>
            <select name="branchId" required>
                <option value="">-- 지점을 선택하세요 --</option>
                <%
                    // DB 연결 설정 (비밀번호 수정하세요!)
                    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
                    String id = "root";
                    String pw = "your_password"; // ★ 본인 비밀번호로 수정!

                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(url, id, pw);
                        
                        String sql = "SELECT branch_id, branch_name FROM Branch ORDER BY branch_id";
                        pstmt = conn.prepareStatement(sql);
                        rs = pstmt.executeQuery();

                        while(rs.next()) {
                %>
                    <option value="<%= rs.getString("branch_id") %>"><%= rs.getString("branch_name") %></option>
                <%
                        }
                    } catch(Exception e) { e.printStackTrace(); }
                    finally {
                        if(rs!=null) rs.close();
                        if(pstmt!=null) pstmt.close();
                        if(conn!=null) conn.close();
                    }
                %>
            </select>

            <h3>📅 이용 날짜 선택</h3>
            <input type="date" name="selectedDate" id="datePicker" required>

            <button type="submit">다음 단계 (상품군 선택) ➡️</button>
        </form>
    </div>

    <script>
        // 오늘 날짜 구하기 (과거 날짜 선택 방지)
        var today = new Date().toISOString().split('T')[0];
        document.getElementById("datePicker").setAttribute('min', today);
        document.getElementById("datePicker").value = today; // 기본값 오늘
    </script>
</body>

</html>
