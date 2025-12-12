## 📚 스터디카페 예약 시스템 & 무인 키오스크 (JSP Project)
**JSP와 MySQL을 활용하여 구현한 웹 기반 예약 시스템 및 현장 무인 키오스크**입니다. 사용자는 웹사이트를 통해 원하는 좌석, 스터디룸, 사물함을 미리 예약/결제할 수 있으며, 매장 내 키오스크를 통해 입/퇴실 및 이용 시간 관리를 자동화할 수 있습니다.

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

## 💡 주요 기능 (Key Features)

### 1️⃣ 예약 및 결제 시스템
* **스마트 예약 로직:**
    * **스터디룸:** `start_time`과 `end_time`을 비교하여 중복 예약을 원천 차단하는 로직 구현.
    * **좌석/사물함:** 텍스트 목록이 아닌 **Visual Grid(배치도)**를 통해 직관적인 선택 가능.
* **트랜잭션(Transaction) 결제 처리:**
    * 결제 발생 시 `Reservation`(예약), `Payment`(결제), `Coupon`(쿠폰 사용), `Point`(포인트 적립) 테이블을 묶어 **원자성(Atomicity)** 보장. (하나라도 실패 시 전체 롤백)

### 2️⃣ 현장 무인 키오스크
* **실시간 상태 반영:**
    * 입실 버튼 클릭 시 `Reservation` 상태(`Scheduled` → `InUse`)와 자산 상태(`Available` → `InUse`) 동시 업데이트.
* **입/퇴실 로직 분리:**
    * **스터디룸:** 퇴실 시 즉시 `Completed` 처리 (재입장 불가).
    * **기간권(지정석/사물함):** 퇴실 시 `Scheduled` 상태로 복귀 (기간 내 재입장 가능).

## 💾 설치 및 실행 (DB 설정)
1. `studyCafe_db.sql` 파일을 MySQL에 import 하세요.
2. `src/main/webapp/` 내의 JSP 파일들에서 DB 연결 설정을 본인 환경에 맞게 변경하세요.
   - `serverTimezone=Asia/Seoul`
   - ID/PW 변경 필수
## 🚀 트러블 슈팅 (Troubleshooting)

* **Timezone 이슈:** 예약 시간이 DB에 9시간 밀려 저장되는 문제 발생.
    * 👉 JDBC URL에 `serverTimezone=Asia/Seoul` 옵션을 추가하여 해결.
* **NULL 데이터 처리:** 키오스크 퇴실 시 잔여 시간이 `NULL`일 경우 `Data truncation` 오류 발생.
    * 👉 SQL 쿼리 내 `IFNULL(remaining_minutes, 0)` 처리 및 Java 레벨에서 `Object` 타입 체크 로직 추가로 안정성 확보.
* **동시성 제어:** 결제 직전 좌석을 선점하는 문제를 해결하기 위해, 결제 완료 전까지는 `InCart` 상태로 관리하고 최종 승인 시 `Scheduled`로 변경하는 상태 머신 설계.
