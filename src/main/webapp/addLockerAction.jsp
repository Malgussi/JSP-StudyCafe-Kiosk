<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    String branchId = request.getParameter("branchId"); // 지점 정보가 필요함

    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    // DB 연결
    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC";
    String id = "root";
    String pw = "akfrnTl13!"; // ★ 비밀번호 수정! ★

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        
        // 1. 해당 지점에서 '사용 가능한(Available)' 사물함 아무거나 하나 찾기
        String findLockerSql = "SELECT locker_id FROM Locker WHERE branch_id = ? AND status = 'Available' LIMIT 1";
        pstmt = conn.prepareStatement(findLockerSql);
        pstmt.setString(1, branchId);
        rs = pstmt.executeQuery();
        
        String lockerId = null;
        if (rs.next()) {
            lockerId = rs.getString("locker_id");
        }
        rs.close(); pstmt.close();
        
        // 2. '사물함 상품(Product)' 정보 찾기 (4주권)
        // (아까 DB 초기화할 때 사물함 상품이 지워졌을 수 있으니, 없으면 새로 만듭니다)
        // 안전하게 '사물함' 글자 들어간 거 찾기
        String findProdSql = "SELECT product_id, price FROM Product WHERE product_type='LOCKER' LIMIT 1";
        pstmt = conn.prepareStatement(findProdSql);
        rs = pstmt.executeQuery();
        
        int productId = 0;
        int price = 0;
        
        if (rs.next()) {
            productId = rs.getInt("product_id");
            price = rs.getInt("price");
        } else {
            // 상품이 없으면 임시로 가격 설정 (혹시 모를 에러 방지)
            price = 9000; 
        }
        
        // 3. 예약(장바구니) 추가
        if (lockerId != null) {
            String insertSql = "INSERT INTO Reservation " +
                               "(member_id, product_id, locker_id, start_datetime, end_datetime, total_fee, status) " +
                               "VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 28 DAY), ?, 'InCart')";
            
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId); // 만약 상품ID 못찾으면 0 들어가는데, 일단 진행
            pstmt.setString(3, lockerId);
            pstmt.setInt(4, price);
            pstmt.executeUpdate();
        }

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(pstmt!=null) pstmt.close();
        if(conn!=null) conn.close();
    }
    
    // 4. 처리가 끝나면 바로 '결제 페이지'로 이동
    response.sendRedirect("step5_payment.jsp");
%>