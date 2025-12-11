package test;
import java.sql.Connection;
import java.sql.DriverManager;

public class DBTest {
    public static void main(String[] args) {
        // 1. DB 접속 정보
        String url = "jdbc:mysql://localhost:3306/study_cafe?serverTimezone=UTC"; // DB 주소
        String id = "root"; 
        String pw = "your_passwd";

        // 2. 연결 시도
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
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
