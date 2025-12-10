package test;
import java.sql.Connection;
import java.sql.DriverManager;

public class DBTest {
    public static void main(String[] args) {
        // 1. DB 접속 정보 (본인 환경에 맞게 수정 필수!)
        String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC"; // DB 주소
        String id = "root"; // MySQL 아이디 (보통 root)
        String pw = "akfrnTl13!"; // ★ 중요: MySQL 설치할 때 설정한 비밀번호 넣기!

        // 2. 연결 시도
        try {
            // 통역사 부르기
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // 전화를 겁니다 (연결)
            Connection conn = DriverManager.getConnection(url, id, pw);
            
            if(conn != null) {
                System.out.println("--------------------------------------");
                System.out.println("🎉 대박! DB 연결 성공했습니다!");
                System.out.println("이제 웹사이트를 만들 수 있습니다.");
                System.out.println("--------------------------------------");
            }
            
        } catch (Exception e) {
            System.out.println("ㅠㅠ 연결 실패... 원인은 아래와 같습니다.");
            e.printStackTrace(); // 에러 내용을 빨간 글씨로 보여줌
        }
    }
}