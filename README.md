# 📚 스터디카페 예약 시스템 (JSP Project)

JSP와 MySQL을 활용하여 구현한 **스터디카페 키오스크 & 예약 웹사이트**입니다.
사용자는 좌석/룸/사물함을 예약하고, 결제 및 입실 처리를 할 수 있습니다.

## 🖥️ 시연 화면
<img width="584" height="564" alt="image" src="https://github.com/user-attachments/assets/55faa9ce-c3b5-4d96-878f-898479b44a36" />
<img width="796" height="260" alt="image" src="https://github.com/user-attachments/assets/083f703e-dc3f-4407-92e9-230f03b44e1a" />
<img width="789" height="735" alt="image" src="https://github.com/user-attachments/assets/95c60e4d-bc50-4861-a686-a611e2aa262e" />
<img width="552" height="542" alt="image" src="https://github.com/user-attachments/assets/69558413-3f0d-4c0a-8015-ad58a8ed23f0" />

## 🛠️ 개발 환경
- **Language:** Java (JSP), HTML/CSS, JavaScript
- **Server:** Apache Tomcat 9.0
- **Database:** MySQL
- **Tool:** Eclipse IDE

## 💡 주요 기능
1. **회원가입/로그인:** 세션 기반 로그인 처리.
2. **예약 시스템:**
   - 날짜 및 지점 선택.
   - **스터디룸:** 시간표 기반 중복 예약 방지 로직.
   - **좌석/사물함:** 배치도를 통한 시각적 선택 및 배정.
3. **결제 및 쿠폰:**
   - 조건부 쿠폰 발급 (신규 회원, 특정 상품 전용 등).
   - 결제 시뮬레이션 및 영수증 처리.
4. **키오스크 (입실):**
   - 예약 시간 도래 시 입실 버튼 활성화.
   - 실시간 잔여 좌석/사물함 현황 반영.

## 💾 설치 및 실행 (DB 설정)
1. `database.sql` 파일을 MySQL에 import 하세요.
2. `src/main/webapp/` 내의 JSP 파일들에서 DB 연결 설정을 본인 환경에 맞게 변경하세요.
   - `serverTimezone=Asia/Seoul`
   - ID/PW 변경 필수
