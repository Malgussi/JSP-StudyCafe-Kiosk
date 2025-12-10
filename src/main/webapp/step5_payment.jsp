<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }

    String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=Asia/Seoul";
    String id = "root";
    String pw = "your_password"; 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    int totalSum = 0;   
    int roomSum = 0;    
    int lockerSum = 0;  
    
    StringBuilder orderName = new StringBuilder();
    int count = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, id, pw);
        
        // 장바구니(InCart) 상품 조회
        String cartSql = "SELECT r.total_fee, p.product_name, p.product_type " +
                         "FROM Reservation r " +
                         "JOIN Product p ON r.product_id = p.product_id " +
                         "WHERE r.member_id = ? AND r.status = 'InCart'";
        pstmt = conn.prepareStatement(cartSql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            int fee = rs.getInt("total_fee");
            String type = rs.getString("product_type"); // ROOM, SEAT, LOCKER
            String pName = rs.getString("product_name");
            
            totalSum += fee;
            
            if ("LOCKER".equals(type)) lockerSum += fee;
            else if ("ROOM".equals(type)) roomSum += fee;

            if(count == 0) orderName.append(pName);
            count++;
        }
        if(count > 1) orderName.append(" 외 " + (count-1) + "건");
        
    } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html>
<head>
<title>결제하기</title>
<style>
    body { font-family: 'Noto Sans KR', sans-serif; background-color: #f0f2f5; padding: 30px; }
    .container { width: 500px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
    
    h2 { margin-top: 0; margin-bottom: 20px; color: #333; }
    h3 { font-size: 16px; color: #555; margin-bottom: 10px; margin-top: 25px; }
    
    .section { border-bottom: 1px solid #eee; padding-bottom: 20px; }
    .section:last-child { border-bottom: none; }
    
    /* 주문 내역 */
    .order-row { display: flex; justify-content: space-between; font-size: 16px; margin-bottom: 8px; font-weight: bold; }
    
    /* 쿠폰 선택 */
    select { width: 100%; padding: 12px; border-radius: 8px; border: 1px solid #ddd; font-size: 14px; background-color: #fff; }
    
    /* 할인 금액 표시 (숨김) */
    .discount-row { display: none; justify-content: space-between; font-size: 14px; color: #f44336; margin-top: 10px; }
    
    /* 최종 금액 */
    .final-row { display: flex; justify-content: space-between; align-items: center; margin-top: 15px; }
    .final-label { font-size: 18px; font-weight: bold; }
    .final-price { font-size: 24px; font-weight: bold; color: #1890ff; }
    
    /* 결제 수단 버튼 */
    .pay-methods { display: flex; gap: 10px; }
    .pay-btn { flex: 1; padding: 15px 0; border: 1px solid #ddd; border-radius: 8px; background: white; cursor: pointer; text-align:center; font-weight: bold; font-size: 14px; transition: 0.2s; }
    .pay-btn:hover { background-color: #f9f9f9; }
    .pay-btn.selected { border-color: #1890ff; color: #1890ff; background: #e6f7ff; }
    
    /* 결제하기 버튼 */
    .submit-btn { width: 100%; padding: 18px; background-color: #1890ff; color: white; font-size: 18px; border: none; border-radius: 8px; cursor: pointer; font-weight: bold; margin-top: 30px; transition: 0.2s; }
    .submit-btn:hover { background-color: #096dd9; }
</style>
<script>
    var totalSum = <%= totalSum %>;
    var roomSum = <%= roomSum %>;
    var lockerSum = <%= lockerSum %>;

    function updatePrice() {
        var select = document.getElementById("couponSelect");
        var option = select.options[select.selectedIndex];
        
        var discountVal = parseInt(option.getAttribute("data-val"));
        var discountType = option.getAttribute("data-type");
        var targetType = option.getAttribute("data-target"); // ROOM, LOCKER, ALL
        
        var basePrice = 0;
        
        // 쿠폰 적용 대상 금액 판별
        if (targetType === 'LOCKER') basePrice = lockerSum;
        else if (targetType === 'ROOM') basePrice = roomSum;
        else basePrice = totalSum;

        // 적용 대상 상품이 없는 경우
        if (discountVal > 0 && basePrice === 0) {
            alert("⚠️ 이 쿠폰은 장바구니에 해당 상품이 없어 적용할 수 없습니다.\n(" + targetType + " 전용)");
            select.selectedIndex = 0; // 선택 초기화
            updatePrice(); // 재계산
            return;
        }

        // 할인액 계산
        var discountAmount = 0;
        if(discountType === 'Fixed') discountAmount = discountVal;
        else if(discountType === 'Percentage') discountAmount = basePrice * (discountVal / 100.0);
        
        // 할인액이 결제금액보다 크면 안됨
        if (discountAmount > basePrice) discountAmount = basePrice;
        // 퍼센트 할인의 경우 소수점 버림
        discountAmount = Math.floor(discountAmount);

        var finalPrice = totalSum - discountAmount;
        
        // 화면 갱신
        document.getElementById("finalPrice").innerText = finalPrice.toLocaleString() + "원";
        
        if(discountAmount > 0) {
            document.getElementById("discountRow").style.display = "flex";
            document.getElementById("discountText").innerText = option.text.split('(')[0] + " 할인";
            document.getElementById("discountPrice").innerText = "-" + discountAmount.toLocaleString() + "원";
        } else {
            document.getElementById("discountRow").style.display = "none";
        }
    }

    function selectMethod(method) {
        document.querySelectorAll('.pay-btn').forEach(btn => btn.classList.remove('selected'));
        document.getElementById('btn-' + method).classList.add('selected');
        document.getElementById('payMethod').value = method;
    }
</script>
</head>
<body>
    <div class="container">
        <h2>결제하기</h2>
        
        <form action="step6_finish.jsp" method="post">
            <input type="hidden" name="payMethod" id="payMethod" value="CreditCard">
            
            <div class="section">
                <h3>주문 내역</h3>
                <div class="order-row">
                    <span><%= orderName %></span>
                    <span><%= String.format("%,d", totalSum) %>원</span>
                </div>
            </div>
            
            <div class="section">
                <h3>쿠폰 할인</h3>
                <select name="couponId" id="couponSelect" onchange="updatePrice()">
                    <option value="0" data-val="0" data-type="None" data-target="ALL">사용 안 함</option>
                    <%
                        try {
                            // 사용 가능한 쿠폰 조회
                            String couponSql = "SELECT mc.member_coupon_id, c.coupon_name, c.discount_type, c.discount_value " +
                                               "FROM Member_Coupon mc " +
                                               "JOIN Coupon c ON mc.coupon_id = c.coupon_id " +
                                               "WHERE mc.member_id = ? AND mc.status = 'Available'";
                            pstmt = conn.prepareStatement(couponSql);
                            pstmt.setInt(1, userId);
                            rs = pstmt.executeQuery();
                            
                            while(rs.next()) {
                                String cName = rs.getString("coupon_name");
                                String dType = rs.getString("discount_type");
                                int dVal = rs.getInt("discount_value");
                                String mcId = rs.getString("member_coupon_id");
                                
                                // 쿠폰 타입(타겟) 분석
                                String target = "ALL";
                                if (cName.contains("사물함")) target = "LOCKER";
                                else if (cName.contains("스터디룸")) target = "ROOM";
                                
                                String label = cName + " (" + (dType.equals("Fixed") ? dVal + "원" : dVal + "%") + " 할인)";
                    %>
                        <option value="<%= mcId %>" 
                                data-val="<%= dVal %>" 
                                data-type="<%= dType %>" 
                                data-target="<%= target %>">
                            <%= label %>
                        </option>
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
                
                <div class="discount-row" id="discountRow">
                    <span id="discountText">할인</span>
                    <span id="discountPrice">-0원</span>
                </div>
                
                <div class="final-row">
                    <span class="final-label">최종 결제 금액</span>
                    <span class="final-price" id="finalPrice">
                        <%= String.format("%,d", totalSum) %>원
                    </span>
                </div>
            </div>
            
            <div class="section">
                <h3>결제 수단</h3>
                <div class="pay-methods">
                    <div id="btn-CreditCard" class="pay-btn selected" onclick="selectMethod('CreditCard')">신용카드</div>
                    <div id="btn-SamsungPay" class="pay-btn" onclick="selectMethod('SamsungPay')">삼성페이</div>
                    <div id="btn-KakaoPay" class="pay-btn" onclick="selectMethod('KakaoPay')">카카오페이</div>
                </div>
            </div>
            
            <button type="submit" class="submit-btn">결제하기</button>
        </form>
    </div>
</body>

</html>
