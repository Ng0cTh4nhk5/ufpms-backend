# Hướng Dẫn Kiểm Thử (Validator Checklist) - Cấu Hình Repository & CI/CD

> 📅 **Ngày cập nhật**: 19/02/2026
> 🎯 **Mục tiêu**: Đảm bảo các Rule bảo vệ nhánh và Pipeline CI/CD hoạt động ĐÚNG như mong đợi.
> ⚠️ **Thực hiện trên**: Cả 2 repo `ufpms-backend` và `ufpms-frontend`.

---

## 1. Chuẩn Bị
- Đảm bảo bạn đang không dùng tài khoản Admin (hoặc đã tích chọn **"Include administrators"** trong Branch Protection Rule).
- Đã setup xong file CI/CD (`.yml`) và Branch Rules.

---

## 2. Kịch Bản Kiểm Thử (Test Scenarios)

### ✅ Test Case 1: Chặn Push Trực Tiếp vào `main`
**Mục đích**: Đảm bảo không ai được phép sửa code trực tiếp trên Production.

1.  Tại local, switch sang nhánh `main`:
    ```bash
    git checkout main
    git pull origin main
    ```
2.  Tạo một thay đổi nhỏ (ví dụ: thêm dòng trống vào `README.md`).
3.  Commit và thử Push:
    ```bash
    git add README.md
    git commit -m "test: try pushing directly to main"
    git push origin main
    ```
4.  **Kết quả mong đợi**:
    - Git báo lỗi: `remote: error: GH006: Protected branch update failed for refs/heads/main.`
    - Push bị từ chối.

---

### ✅ Test Case 2: Tạo Pull Request (PR) & CI/CD Trigger
**Mục đích**: Đảm bảo quy trình PR hoạt động và CI/CD tự động chạy.

1.  Từ nhánh `main`, tạo nhánh mới:
    ```bash
    git checkout -b feature/test-ci-cd
    ```
2.  Sửa file bất kỳ, commit và push lên:
    ```bash
    git add .
    git commit -m "chore: trigger ci cd"
    git push origin feature/test-ci-cd
    ```
3.  Vào GitHub, tạo Pull Request từ `feature/test-ci-cd` vào `develop` (hoặc `main`).
4.  **Kết quả mong đợi**:
    - GitHub hiện thông báo "Checks are running..." (hoặc chấm vàng 🟡).
    - Tab **Actions** hiển thị workflow đang chạy.

---

### ✅ Test Case 3: Chặn Merge khi CI/CD Thất Bại
**Mục đích**: Đảm bảo code lỗi không được merge. (Test này cần bạn cố tình làm sai code).

1.  Trong nhánh `feature/test-ci-cd`, sửa code để gây lỗi (Ví dụ: Viết sai cú pháp Java/React, hoặc xóa file quan trọng).
2.  Push lên branch đó:
    ```bash
    git add .
    git commit -m "test: make ci fail"
    git push origin feature/test-ci-cd
    ```
3.  Quay lại Pull Request trên GitHub.
4.  Chờ CI/CD chạy xong (sẽ báo đỏ 🔴).
5.  **Kết quả mong đợi**:
    - Nút **Merge pull request** bị mờ (disable) hoặc có cảnh báo đỏ `Required status checks failed`.
    - Bạn KHÔNG THỂ bấm merge được.

---

### ✅ Test Case 4: Chặn Merge khi Chưa Có Review (Approve)
**Mục đích**: Đảm bảo code phải được người khác xem qua.

1.  Dùng một tài khoản GitHub KHÁC (hoặc nhờ thành viên khác trong team).
2.  Vào Pull Request bạn vừa tạo (lúc này code cần phải đúng để CI xanh ✅).
3.  **Kết quả mong đợi**:
    - Nút **Merge pull request** vẫn bị mờ/disable.
    - Có thông báo `Review required`.
4.  Nhờ thành viên kia nhấn **Approve**.
5.  **Kết quả mong đợi**:
    - Nút **Merge pull request** chuyển sang màu xanh ✅.
    - Bạn có thể bấm Merge.

---

### ✅ Test Case 5: Chặn Force Push
**Mục đích**: Đảm bảo lịch sử commit không bị ghi đè/xóa mất.

1.  Thử Force Push lên `main`:
    ```bash
    git push origin main --force
    ```
2.  **Kết quả mong đợi**:
    - Bị từ chối ngay lập tức với lỗi `protected branch hook declined`.

---

## 3. Checklist Hoàn Thành

| STT | Kịch bản | Trạng thái | Ghi chú |
|-----|----------|------------|---------|
| 1 | Push thẳng vào `main` bị chặn | [ ] | |
| 2 | Push thẳng vào `develop` bị chặn | [ ] | |
| 3 | Tạo PR -> CI/CD tự động chạy | [ ] | |
| 4 | CI fail -> Không cho Merge | [ ] | |
| 5 | Chưa Approve -> Không cho Merge | [ ] | |
| 6 | Force push bị chặn | [ ] | |

👉 **Nếu tất cả đều [x] -> Setup của bạn đã CHUẨN 100%!** 🚀
