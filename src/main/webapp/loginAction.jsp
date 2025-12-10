<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. 사용자가 입력한 정보 가져오기
    request.setCharacterEncoding("UTF-8");
    String inputEmail = request.getParameter("email");
    String inputPw = request.getParameter("password");

    // 2. DB 연결 준비 (아까 DBTest랑 똑같음)
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String dbId = "root";
    String dbPw = "akfrnTl13!"; // ★ 본인 DB 비밀번호로 꼭 바꾸세요!

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbId, dbPw);

        // 3. DB에 물어보기: "이 이메일이랑 비번 가진 사람 있어?"
        String sql = "SELECT member_id, member_name FROM Member WHERE email = ? AND password = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, inputEmail);
        pstmt.setString(2, inputPw);

        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 4. 로그인 성공! -> 세션(Session)에 정보 저장
            String name = rs.getString("member_name");
            int id = rs.getInt("member_id");
            
            session.setAttribute("userName", name); // 이름 기억
            session.setAttribute("userId", id);     // 번호 기억
            
            // 메인 페이지로 이동
            response.sendRedirect("main.jsp");
        } else {
            // 5. 로그인 실패
            out.println("<script>");
            out.println("alert('아이디 또는 비밀번호가 틀렸습니다.');");
            out.println("history.back();");
            out.println("</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) rs.close();
        if(pstmt != null) pstmt.close();
        if(conn != null) conn.close();
    }
%>