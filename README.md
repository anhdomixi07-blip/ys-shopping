# YS Shopping — bản mã nguồn cửa hàng tiên hiệp

YS Shopping là ứng dụng cửa hàng vật phẩm số dùng Python tiêu chuẩn và SQLite. Giao diện lấy cảm hứng từ mẫu tiên hiệp cũ (xanh đêm, vàng ấm, đèn lồng/tiên cảnh), có bố cục thích ứng cho điện thoại và máy tính. Ảnh QR ZaloPay ní đã gửi trong cuộc trò chuyện được giữ nguyên ở `static/images/zalopay-qr.jpg`; Admin có thể thay ảnh khác trong phần Thiết lập cửa hàng.

## Chạy thử trên máy có Python 3.10+

Không cần cài package bên ngoài.

1. Giải nén ZIP vào một thư mục.
2. Mở Terminal/Command Prompt trong thư mục `YS_Shopping_Official`.
3. Chạy:

   ```bash
   python app.py
   ```

4. Lần chạy đầu, cửa sổ máy chủ in ra một đường dẫn `/setup?token=...`. Mở đường dẫn đó trên trình duyệt đang dùng cùng máy hoặc thay `127.0.0.1` bằng địa chỉ máy chủ đã triển khai. Mã thiết lập bí mật chỉ dùng để tạo Admin đầu tiên và bị xóa sau khi tạo xong.
5. Tạo tài khoản Admin bằng mật khẩu tối thiểu 12 ký tự. Sau đó mở mục **Quản trị → Thiết lập cửa hàng** để kiểm tra số điện thoại, tên chủ ví/ngân hàng và thông tin nhận tiền.
6. Vào **Sản phẩm & kho hàng** để tạo sản phẩm. Với hàng mã code/tài khoản, nhập từng mã trên một dòng; mỗi mã chỉ giao một lần. Không có sản phẩm giả được bật bán sẵn.

Địa chỉ chạy trên máy cục bộ mặc định là `http://127.0.0.1:8080`.

## Các chức năng được triển khai

- Trang chủ tiên hiệp, danh mục, tìm kiếm/lọc sản phẩm, thẻ sản phẩm, responsive mobile.
- Đăng ký, đăng nhập, đổi mật khẩu; mật khẩu được băm PBKDF2-HMAC-SHA256; session cookie `HttpOnly` và `SameSite=Lax`; token CSRF cho biểu mẫu; giới hạn thử đăng nhập.
- Ví số dư, tạo yêu cầu nạp, lịch sử nạp và lịch sử biến động số dư.
- Quy trình nạp tiền **xác minh thủ công**. Yêu cầu không tự cộng tiền khi khách chỉ tạo yêu cầu; Admin/nhân viên phải đối chiếu khoản tiền đã vào ví và nhập mã giao dịch thực tế. Mã giao dịch có ràng buộc duy nhất, yêu cầu chỉ chuyển trạng thái từ `pending` đúng một lần; ghi sổ số dư trong transaction SQLite.
- Mua sản phẩm bằng số dư; kiểm tra số dư/kho trong transaction; kho mã/tài khoản giao từng mã một lần; kho số lượng trừ theo số lượng; sản phẩm có thể đặt Flash Sale.
- Admin riêng: quản lý sản phẩm/giá/ảnh/kho, nạp tiền, đơn hàng, mã khuyến mãi, người dùng, tạo nhân viên, thay QR/thông tin nhận tiền/banner/thông báo, Discord webhook, nhật ký audit.
- Phân quyền phía máy chủ: nhân viên không thể thay QR, thông tin thanh toán, webhook, tạo nhân viên hoặc vào mục người dùng/nhật ký Admin. Các POST cần CSRF token.
- Hoàn tiền chỉ dành cho đơn đang `processing`; đơn giao mã số thành công chuyển `completed` và không có nút hoàn tự động để tránh hoàn tiền sau khi mã đã giao.
- Discord webhook chỉ được gửi từ máy chủ; không đưa webhook hay mật khẩu vào HTML/JavaScript. Thông báo có thể thất bại nếu máy chủ không kết nối được Discord, nhưng không làm giao dịch cơ sở dữ liệu bị đảo ngược.
- Dữ liệu lưu tại `data/` mặc định. Trên nền tảng hosting, đặt `YS_DATA_DIR` thành thư mục persistent volume để dữ liệu/QR ảnh tải lên không mất khi redeploy.

## Quan trọng về QR, nạp tiền và giao dịch thật

- Ảnh QR ní gửi đã được đưa vào giao diện, nhưng mã QR **chưa được xác minh bằng một giao dịch thanh toán thực tế**. Hãy thử quét bằng đúng ứng dụng nhận tiền và kiểm tra tên người nhận trước khi mở bán.
- Bản này không tự động đọc biến động ZaloPay/ngân hàng. Đây là lựa chọn có chủ đích để không cộng tiền nhầm: Admin cần mở lịch sử nhận tiền, xác minh khoản tiền vào và nhập mã giao dịch duy nhất.
- Không nhập mật khẩu ví, mật khẩu ngân hàng, OTP, PIN hoặc mã bí mật vào cửa hàng. Không đăng ảnh có thông tin nhạy cảm của khách vào Discord.
- Nếu muốn tự động nạp tiền, cần API/webhook chính thức từ nhà cung cấp thanh toán, thông tin xác thực được lưu ở biến môi trường phía máy chủ, xác minh chữ ký webhook, chống phát lại và kiểm thử bằng tài khoản merchant. Không thể suy ra tự động từ một ảnh QR.
- Website này là mã nguồn để triển khai; ZIP không có nghĩa là website đã được xuất bản công khai hoặc đã được Google lập chỉ mục.

## Triển khai công khai

Có thể chạy trên nền tảng hỗ trợ Python process. Cài biến môi trường và lưu dữ liệu lâu dài:

- `HOST=0.0.0.0`
- `PORT` — cổng do hosting cung cấp (ứng dụng đọc tự động, mặc định `8080`)
- `YS_DATA_DIR=/data` — ví dụ nếu hosting gắn persistent disk tại `/data`
- `YS_COOKIE_SECURE=1` — khi truy cập qua HTTPS
- `YS_PUBLIC_URL=https://ten-mien-cua-ban` — tùy chọn, dùng tạo sitemap tuyệt đối

Phải bật HTTPS. Không dùng SQLite trên filesystem không bền vững cho cửa hàng đang có giao dịch thật. Giữ một bản backup `ys_shopping.sqlite3` và thư mục `uploads/` ở nơi an toàn; không đưa dữ liệu/database lên kho mã nguồn công khai. Trước khi mở bán thật nên có người lớn/chủ tài khoản thanh toán xác nhận các điều kiện của nhà cung cấp ví và các quy định liên quan.

Sau khi có website công khai và tên miền, cấu hình Search Console để xác minh quyền sở hữu, gửi sitemap và theo dõi index. Google không đảm bảo lập chỉ mục ngay hoặc chắc chắn lập chỉ mục mọi URL.

## Kiểm tra

Chạy kiểm tra cú pháp và smoke tests:

```bash
python -m py_compile app.py
python -m unittest discover -s tests -v
```

Các smoke tests kiểm tra đăng nhập, quyền Admin/nhân viên, tạo yêu cầu nạp, chống duyệt trùng, mua hàng và giao mã. Chúng không thể thay thế việc thử QR với ví thật, đánh giá bảo mật độc lập, hoặc kiểm thử trên mọi trình duyệt/thiết bị.

## Thư mục

- `app.py` — máy chủ, routes, quyền, SQLite, giao dịch và logic cửa hàng.
- `static/style.css` — giao diện responsive.
- `static/app.js` — menu di động và lọc danh mục/tìm kiếm.
- `static/images/hero-art.jpg` — crop cảnh tiên hiệp từ mẫu ní đưa.
- `static/images/zalopay-qr.jpg` — ảnh QR ban đầu ní gửi.
- `tests/` — kiểm tra tích hợp qua HTTP.
