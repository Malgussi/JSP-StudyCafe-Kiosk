<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>동국 스터디카페 로그인</title>
</head>
<body>
    <div align="center">
        <h2>📚 동국 스터디카페</h2>
        <hr>
        <h3>로그인 해주세요</h3>
        
        <form action="loginAction.jsp" method="post">
            <table border="1" cellpadding="10">
                <tr>
                    <td>이메일</td>
                    <td><input type="text" name="email" placeholder="이메일 입력"></td>
                </tr>
                <tr>
                    <td>비밀번호</td>
                    <td><input type="password" name="password" placeholder="비밀번호 입력"></td>
                </tr>
                <tr>
                    <td colspan="2" align="center">
                        <input type="submit" value="로그인 하기">
                    </td>
                </tr>
            </table>
        </form>
    </div>
</body>
</html>