<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    // branchId는 이제 필요 없지만, 혹시 나중에 쓸 수 있으니 받아는 둡니다.
    String branchId = request.getParameter("branchId"); 

    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    // DB 연결
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "your_passwd";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        
        // 1. 사물함 미리 찾기 로직 삭제 
        // (구매 시점에는 사물함을 지정하지 않음 -> 나중에 '사용하기' 누를 때 선택)
        
        // 2. '사물함 상품(Product)' 정보 찾기 (가격 정보 필요)
        String findProdSql = "SELECT product_id, price FROM Product WHERE product_type='LOCKER' LIMIT 1";
        pstmt = conn.prepareStatement(findProdSql);
        rs = pstmt.executeQuery();
        
        int productId = 0;
        int price = 0;
        
        if (rs.next()) {
            productId = rs.getInt("product_id");
            price = rs.getInt("price");
        } else {
            // 상품이 없으면 임시로 가격 설정 (예외 방지)
            price = 9000; 
        }
        rs.close(); // ResultSet 닫기
        pstmt.close(); // PreparedStatement 재사용을 위해 닫기
        
        // 3. 예약(장바구니) 추가
        String insertSql = "INSERT INTO Reservation " +
                           "(member_id, product_id, locker_id, start_datetime, end_datetime, total_fee, status) " +
                           "VALUES (?, ?, NULL, NOW(), DATE_ADD(NOW(), INTERVAL 28 DAY), ?, 'InCart')";
            
        pstmt = conn.prepareStatement(insertSql);
        pstmt.setInt(1, userId);
        pstmt.setInt(2, productId);
        // pstmt.setString(3, lockerId); 
        pstmt.setInt(3, price);          // <--- 3번째 물음표가 바로 가격(total_fee)이 됩니다.
        
        pstmt.executeUpdate();

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs!=null) try { rs.close(); } catch(SQLException ex) {}
        if(pstmt!=null) try { pstmt.close(); } catch(SQLException ex) {}
        if(conn!=null) try { conn.close(); } catch(SQLException ex) {}
    }
    
    // 4. 처리가 끝나면 '결제 페이지'로 이동
    response.sendRedirect("step5_payment.jsp");
%>
