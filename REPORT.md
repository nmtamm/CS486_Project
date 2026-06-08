# Báo cáo tiến độ

## Những gì đã làm

### 1. Cấu trúc lại pipeline skill
- Tổ chức lại `.opencode/skills/db-design-pipeline/` thành mỗi bước một thư mục con:
  - `step-01/INSTRUCTION.md`, `TEMPLATE.md`, `EXAMPLE.md`
  - `step-02/INSTRUCTION.md`
### 2. Bước 1 — Phân tích yêu cầu nghiệp vụ (hoàn thành, cần review)

Tài liệu gồm đúng 4 phần:

| Phần | Mô tả |
|------|-------|
| **1. Business Purpose** | Xác định vấn đề cốt lõi, mục tiêu chính và phạm vi của hệ thống. |
| **2. Actors** | Liệt kê các vai trò người dùng, trách nhiệm và tương tác với hệ thống. |
| **3. Business Data Entities & Attributes** | Xác định các thực thể chính, định danh, thuộc tính bắt buộc/không bắt buộc và các giá trị định sẵn (enum). |
| **4. Business Rules** | Trích xuất các ràng buộc, chính sách, quy tắc nghiệp vụ, lifecycle và state transition. |

### 3. Sử dụng vòng lặp tương tác
Trong quá trình sinh tài liệu, các điểm còn mơ hồ đã được giải quyết thông qua công cụ `question` trước khi hoàn thiện các quy tắc nghiệp vụ (business rules).

### 4. Thực thi workflow
Pipeline tuân theo quy trình 3 bước nghiêm ngặt:
1. **Quét sâu nội bộ** — xác định các điểm còn mơ hồ, thiếu sót.
2. **Làm rõ tương tác** — trao đổi với người dùng để giải quyết các điểm còn mơ hồ.
3. **Tổng hợp & xuất file** — tổng hợp và xuất tài liệu 4 phần.

### 5. Tham khảo
- **Prompt**: [INSTRUCTION.md](.opencode/skills/db-design-pipeline/step-01-business-requirement-analysis/INSTRUCTION.md)
- **Kết quả**: [01-business-requirement-analysis.md](outputs/01-business-requirement-analysis.md)
