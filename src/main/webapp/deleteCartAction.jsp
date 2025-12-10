<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String reservationId = request.getParameter("id");
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null || reservationId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // DB 연결
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "your_password";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        
        // 내 장바구니(InCart)에 있는 것만 삭제 가능 (남의 건 삭제 못하게 member_id 체크)
        String sql = "DELETE FROM Reservation WHERE reservation_id = ? AND member_id = ? AND status = 'InCart'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, reservationId);
        pstmt.setInt(2, userId);
        
        pstmt.executeUpdate();
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(pstmt!=null) pstmt.close();
        if(conn!=null) conn.close();
    }
    
    // 삭제 후 다시 장바구니 목록으로 이동
    response.sendRedirect("cartList.jsp");

%>
