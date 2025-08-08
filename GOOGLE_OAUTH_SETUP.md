# Google OAuth Setup for Privilege Member

## การตั้งค่า Google OAuth ใน Supabase

### 1. เปิดใช้งาน Google Provider

1. ไปที่ **Supabase Dashboard**: https://supabase.com/dashboard/project/bitglhtesgqflxojoamq
2. เลือก **Authentication** > **Providers** 
3. ค้นหา **Google** และเปิดใช้งาน (Enable)

### 2. สร้าง Google OAuth Application

1. ไปที่ **Google Cloud Console**: https://console.cloud.google.com/
2. สร้างโปรเจค��ใหม่หรือเลือกโปรเจคที่มีอยู่
3. เปิดใช้ **Google+ API** หรือ **Google Identity Services**

#### สร้าง OAuth 2.0 Credentials:
1. ไปที่ **APIs & Services** > **Credentials**
2. คลิก **Create Credentials** > **OAuth 2.0 Client ID**
3. เลือก **Application type**: Web application
4. ตั้งชื่อ: `Privilege Member App`

#### ตั้งค่า Authorized URLs:
**Authorized JavaScript origins:**
```
https://bitglhtesgqflxojoamq.supabase.co
https://b09b1d25df31422ea93baf6535a3c0f3-5972547b418740fd94cb31720.projects.builder.codes
http://localhost:8080
```

**Authorized redirect URIs:**
```
https://bitglhtesgqflxojoamq.supabase.co/auth/v1/callback
https://b09b1d25df31422ea93baf6535a3c0f3-5972547b418740fd94cb31720.projects.builder.codes/auth/callback
http://localhost:8080/auth/callback
```

### 3. กำหนดค่าใน Supabase

1. กลับไปที่ **Supabase Authentication** > **Providers** > **Google**
2. ใส่ **Client ID** และ **Client Secret** จาก Google Cloud Console
3. เปิดใช้งาน **Enable Google provider**
4. **Save** การตั้งค่า

### 4. ข้อมูลที่ต้องใส่

**Client ID Example:**
```
123456789-abc123def456ghi789jkl012mno345pqr.apps.googleusercontent.com
```

**Client Secret Example:**
```
GOCSPX-abcdefghijklmnopqrstuvwxyz123456
```

### 5. การทดสอบ

1. ไปที่หน้า Register หรือ Login
2. คลิกปุ่ม "ลงทะเบียนด้วย Google" หรือ "เข้าสู่ระบบด้วย Google"
3. ระบบจะ redirect ไป Google OAuth
4. หลังจาก authorize แล้วจะกลับมาที่ Dashboard

### 6. Troubleshooting

**หาก Error "redirect_uri_mismatch":**
- ตรวจสอบ Authorized redirect URIs ใน Google Cloud Console
- ตรวจสอบ Site URL ใน Supabase Authentication Settings

**หาก Error "origin_mismatch":**
- ตรวจสอบ Authorized JavaScript origins
- ตรวจสอบ domain ที่ใช้งาน

**หาก Error "access_denied":**
- ตรวจสอบ Client ID และ Client Secret
- ตรวจสอบว่า Google+ API หรือ Google Identity Services เปิดใช้งานแล้ว

### 7. Additional Settings (Optional)

**OAuth Consent Screen:**
- App name: `Privilege Member`
- User support email: `info@privilegemember.co.th`
- App domain: `privilegemember.co.th`
- Privacy Policy: `https://privilegemember.co.th/privacy`
- Terms of Service: `https://privilegemember.co.th/terms`

## สิ่งที่ระบบจะทำอัตโนมัติ

1. **สร้างบัญชี Auth** ใน Supabase
2. **สร้าง User Profile** ในตาราง users
3. **ให้คะแนนโบนัส** 1,000 คะแนนสำหรับสมาชิกใหม่
4. **Redirect** ไปยัง Dashboard

## ข้อมูลที่ได้จาก Google OAuth

- **Email**: อีเมลจาก Google Account
- **Full Name**: ชื่อจาก Google Account
- **Profile Picture**: รูปโปรไฟล์ (optional)
- **Google ID**: Unique ID จาก Google

ระบบจะใช้ข้อมูลเหล่านี้ในการสร้างโปรไฟล์สมาชิกใหม่โดยอัตโนมัติ
