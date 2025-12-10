<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>메인 화면</title>
</head>
<body>
    <div align="center">
        <%
            String name = (String) session.getAttribute("userName");
            
            if (name == null) {
                response.sendRedirect("login.jsp");
            } else {
        %>
            <h1 style="margin-top:50px;">🎉 환영합니다! <%= name %> 님</h1>
            <h3>현재 보유하신 포인트: 5,000 P</h3> <hr>
            
            <button onclick="location.href='step1_date.jsp'" 
                    style="padding: 15px 30px; font-size: 18px; cursor: pointer;">
                좌석/룸 예약 시작하기
            </button>

            <br><br>
            <button onclick="location.href='checkin_list.jsp'" 
                    style="padding: 15px 40px; font-size: 20px; background-color: #673AB7; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: bold;">
                📱 키오스크 (입실/좌석배정)
            </button>
            <br><br>
            <button onclick="alert('아직 구현 중!')">마이페이지</button>
            <br><br>
            <a href="login.jsp">로그아웃</a>
        <%
            }
        %>
    </div>
</body>
</html>