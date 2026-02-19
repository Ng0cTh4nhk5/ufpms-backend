# Hướng Dẫn Setup CI/CD với GitHub Actions - UFPMS V1.0

> 📅 **Ngày cập nhật**: 19/02/2026
> 🎯 **Mục tiêu**: Tự động Build, Test và Check Quality mỗi khi có code mới.
> 🛠️ **Công cụ**: GitHub Actions.

---

## 1. Giới Thiệu
Chúng ta sẽ thiết lập **2 Pipelines** riêng biệt cho Backend và Frontend.
Mỗi pipeline sẽ tự động chạy khi:
- Có code push lên nhánh `main` hoặc `develop`.
- Có Pull Request (PR) trỏ vào `main` hoặc `develop`.

---

## 2. Backend Pipeline (Spring Boot)

Tạo file `.github/workflows/backend-ci.yml` trong repo **`ufpms-backend`**.

### Nội dung file `backend-ci.yml`:

```yaml
name: Backend CI Pipeline

on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main", "develop" ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
    # 1. Checkout code
    - name: Checkout code
      uses: actions/checkout@v4

    # 2. Setup Java 17
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: 'maven' # Cache maven dependencies để build nhanh hơn

    # 3. Build & Test
    - name: Build with Maven
      run: mvn clean verify
      # 'verify' chạy cả unit tests và integration tests

    # 4. (Optional) Check Code Quality (SonarCloud/SonarQube)
    # Nếu chưa có server Sonar, có thể bỏ qua bước này tạm thời
    # - name: Cache SonarCloud packages
    #   uses: actions/cache@v3
    #   with:
    #     path: ~/.sonar/cache
    #     key: ${{ runner.os }}-sonar
    #     restore-keys: ${{ runner.os }}-sonar
    
    # - name: Build and analyze
    #   env:
    #     GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # Needed to get PR information, if any
    #     SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    #   run: mvn -B verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=ufpms-backend

    # 5. Archive Test Results (Optional)
    # Lưu kết quả test lại để xem trên GitHub UI
    - name: Publish Test Report
      if: always() # Chạy ngay cả khi test fail
      uses: mikepenz/action-junit-report@v3
      with:
        report_paths: '**/target/surefire-reports/TEST-*.xml'
```

---

## 3. Frontend Pipeline (React + Vite)

Tạo file `.github/workflows/frontend-ci.yml` trong repo **`ufpms-frontend`**.

### Nội dung file `frontend-ci.yml`:

```yaml
name: Frontend CI Pipeline

on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main", "develop" ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
    # 1. Checkout code
    - name: Checkout code
      uses: actions/checkout@v4

    # 2. Setup Node.js
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm' # Cache npm modules

    # 3. Install Dependencies
    - name: Install dependencies
      run: npm ci
      # 'npm ci' nhanh hơn và sạch hơn 'npm install' cho CI/CD

    # 4. Lint Code (Check syntax & style)
    - name: Lint
      run: npm run lint
      # Cần đảm bảo script "lint" đã được định nghĩa trong package.json

    # 5. Run Tests
    - name: Run Tests
      run: npm test -- --watch=false --browsers=ChromeHeadless
      # Flag tùy thuộc vào test runner (Vitest/Jest)

    # 6. Build Project
    - name: Build
      run: npm run build
      # Kiểm tra xem build có thành công không
```

---

## 4. Cách Thực Hiện

### Bước 1: Tạo thư mục `.github/workflows`
Trong mỗi repo (Backend & Frontend), tạo thư mục `.github` và bên trong đó tạo thư mục `workflows`.

### Bước 2: Tạo file YAML
Tạo các file `.yml` tương ứng với nội dung ở trên.

### Bước 3: Commit & Push
Commit và push lên nhánh `develop` (hoặc tạo nhánh `chore/setup-ci` rồi merge vào).

### Bước 4: Kiểm tra trên GitHub
1. Vào tab **Actions** trên GitHub repo.
2. Bạn sẽ thấy workflow đang chạy (màu vàng 🟡).
3. Nếu thành công (màu xanh ✅), click vào để xem chi tiết các bước.
4. Nếu thất bại (màu đỏ 🔴), click vào xem log lỗi để fix.

---

## 5. Kết Nối Với Branch Protection Rule

Sau khi CI/CD chạy thành công lần đầu tiên:

1. Vào **Settings** → **Branches** → **Edit rule** của `main` hoặc `develop`.
2. Tìm mục **Require status checks to pass**.
3. Tìm kiếm tên job trong file YAML (ví dụ: `build-and-test`).
4. Tích chọn nó.
5. Save changes.

👉 **Kết quả**: Từ giờ, không ai có thể merge code vào `main`/`develop` nếu CI bị lỗi (test fail hoặc build fail).
