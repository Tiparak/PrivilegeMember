import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Separator } from "@/components/ui/separator";
import { authService } from "@/lib/database";
import { supabase } from "@/lib/supabase";
import {
  Crown,
  ArrowLeft,
  Eye,
  EyeOff,
  Mail,
  Phone,
  User,
  Lock,
  Loader2,
  CheckCircle
} from "lucide-react";

export default function Register() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    phone: "",
    password: "",
    confirmPassword: ""
  });
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  // Handle OAuth callback
  useEffect(() => {
    const handleAuthStateChange = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (user && window.location.pathname === '/register') {
        console.log('OAuth user detected on register page:', user);

        // Handle the OAuth callback
        const result = await authService.handleOAuthCallback(user);
        if (result.success) {
          setSuccess(true);
          setTimeout(() => {
            navigate("/dashboard");
          }, 1500);
        } else {
          setError("เกิดข้อผิดพลาดในการสร้างโปรไฟล์ กรุณาลองใหม่อีกครั้ง");
        }
      }
    };

    handleAuthStateChange();

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN' && session?.user && window.location.pathname === '/register') {
        console.log('OAuth sign in detected:', session.user);
        const result = await authService.handleOAuthCallback(session.user);
        if (result.success) {
          setSuccess(true);
          setTimeout(() => {
            navigate("/dashboard");
          }, 1500);
        }
      }
    });

    return () => subscription.unsubscribe();
  }, [navigate]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Clear error when user starts typing
    if (error) setError("");
  };

  const validateForm = () => {
    if (!formData.fullName.trim()) {
      return "กรุณากรอกชื่อ-นามสกุล";
    }
    if (!formData.email.trim()) {
      return "กรุณากรอกอีเมล";
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      return "รูปแบบอีเมลไม่ถูกต้อง";
    }
    if (!formData.phone.trim()) {
      return "กรุณากรอกเบอร์โทรศัพท์";
    }
    if (!/^[0-9-]{10,12}$/.test(formData.phone.replace(/-/g, ""))) {
      return "รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง";
    }
    if (!formData.password) {
      return "กรุณากรอกร��ัสผ่าน";
    }
    if (formData.password.length < 6) {
      return "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
    }
    if (formData.password !== formData.confirmPassword) {
      return "รหัสผ่านไม่ตรงกัน";
    }
    return "";
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const validationError = validateForm();
    if (validationError) {
      setError(validationError);
      return;
    }

    setLoading(true);
    setError("");

    try {
      console.log('Starting registration process...');

      const { user, error: authError } = await authService.signUp(
        formData.email,
        formData.password,
        {
          full_name: formData.fullName,
          phone: formData.phone
        }
      );

      if (authError) {
        console.error('Auth error:', authError);
        throw new Error(authError.message);
      }

      if (user) {
        console.log('Registration successful for user:', user.id);
        setSuccess(true);
        // Navigate to dashboard after success
        setTimeout(() => {
          navigate("/dashboard");
        }, 2000);
      } else {
        throw new Error('Registration failed - no user returned');
      }
    } catch (err: any) {
      console.error("Registration error:", err);

      // Handle specific error types
      if (err.message.includes("already registered") || err.message.includes("already been registered")) {
        setError("อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่น");
      } else if (err.message.includes("invalid") || err.message.includes("format")) {
        setError("ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง");
      } else if (err.message.includes("password")) {
        setError("รหัสผ่านไม่ถูกต้องตามข้อกำหนด");
      } else if (err.message.includes("email")) {
        setError("รูปแบบอีเมลไม่ถูกต้อง");
      } else {
        setError("เกิดข้อผิดพลาดในการสมัครสมาชิก กรุณาลองใหม่อีกครั้ง");
      }
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    setGoogleLoading(true);
    setError("");

    try {
      console.log('Starting Google sign in...');
      const { user, error: googleError } = await authService.signInWithGoogle();

      if (googleError) {
        throw new Error(googleError.message);
      }

      // OAuth redirect will handle the rest
      console.log('Google OAuth initiated');
    } catch (err: any) {
      console.error("Google sign-in error:", err);
      setError("เกิดข้อผิดพลาดในการเข้าสู่ระบบด้วย Google กรุณาลองใหม่อีกครั้ง");
      setGoogleLoading(false);
    }
  };

  if (success) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-purple-50 flex items-center justify-center">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center">
            <div className="w-20 h-20 bg-success/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <CheckCircle className="w-10 h-10 text-success" />
            </div>
            <CardTitle className="text-2xl text-success">สมัครสมาชิกสำเร็จ!</CardTitle>
            <CardDescription>
              ยินดีต้อนรับเข้าสู่ Privilege Member<br />
              กำลังพาค��ณไปยังหน้าแดชบอร์ด...
            </CardDescription>
          </CardHeader>
          <CardContent className="text-center">
            <div className="flex items-center justify-center text-sm text-muted-foreground">
              <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              กำลังโหลด...
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-purple-50">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Link to="/" className="flex items-center space-x-2">
              <div className="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-primary to-purple-600 rounded-lg">
                <Crown className="w-6 h-6 text-white" />
              </div>
              <span className="text-2xl font-bold bg-gradient-to-r from-primary to-purple-600 bg-clip-text text-transparent">
                Privilege Member
              </span>
            </Link>
            <div className="flex items-center space-x-4">
              <Link to="/">
                <Button variant="outline">
                  <ArrowLeft className="w-4 h-4 mr-2" />
                  กลับหน้าหลัก
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8 flex items-center justify-center min-h-[calc(100vh-80px)]">
        <Card className="w-full max-w-lg">
          <CardHeader className="text-center">
            <CardTitle className="text-3xl mb-2">สมัครสมาชิก</CardTitle>
            <CardDescription className="text-lg">
              เริ่มต้นการเดินทางสู่สิทธิพิเศษกับ Privilege Member
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              {error && (
                <Alert variant="destructive">
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              {/* Full Name */}
              <div className="space-y-2">
                <Label htmlFor="fullName" className="flex items-center text-sm font-medium">
                  <User className="w-4 h-4 mr-2" />
                  ชื่อ-นามสกุล
                </Label>
                <Input
                  id="fullName"
                  name="fullName"
                  type="text"
                  placeholder="กรอกชื่อ-นามสกุลของคุณ"
                  value={formData.fullName}
                  onChange={handleInputChange}
                  className="h-12"
                  required
                />
              </div>

              {/* Email */}
              <div className="space-y-2">
                <Label htmlFor="email" className="flex items-center text-sm font-medium">
                  <Mail className="w-4 h-4 mr-2" />
                  อีเมล
                </Label>
                <Input
                  id="email"
                  name="email"
                  type="email"
                  placeholder="กรอกอีเมลของคุณ"
                  value={formData.email}
                  onChange={handleInputChange}
                  className="h-12"
                  required
                />
              </div>

              {/* Phone */}
              <div className="space-y-2">
                <Label htmlFor="phone" className="flex items-center text-sm font-medium">
                  <Phone className="w-4 h-4 mr-2" />
                  เบอร์โทรศัพท์
                </Label>
                <Input
                  id="phone"
                  name="phone"
                  type="tel"
                  placeholder="089-123-4567"
                  value={formData.phone}
                  onChange={handleInputChange}
                  className="h-12"
                  required
                />
              </div>

              {/* Password */}
              <div className="space-y-2">
                <Label htmlFor="password" className="flex items-center text-sm font-medium">
                  <Lock className="w-4 h-4 mr-2" />
                  รหัสผ่าน
                </Label>
                <div className="relative">
                  <Input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    placeholder="กรอกรหัสผ่าน (อย่างน้อย 6 ตัวอักษร)"
                    value={formData.password}
                    onChange={handleInputChange}
                    className="h-12 pr-12"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              {/* Confirm Password */}
              <div className="space-y-2">
                <Label htmlFor="confirmPassword" className="flex items-center text-sm font-medium">
                  <Lock className="w-4 h-4 mr-2" />
                  ยืนยันรหัสผ่าน
                </Label>
                <div className="relative">
                  <Input
                    id="confirmPassword"
                    name="confirmPassword"
                    type={showConfirmPassword ? "text" : "password"}
                    placeholder="กรอกรหัสผ่านอีกครั้ง"
                    value={formData.confirmPassword}
                    onChange={handleInputChange}
                    className="h-12 pr-12"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  >
                    {showConfirmPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              {/* Submit Button */}
              <Button
                type="submit"
                className="w-full h-12 text-lg"
                disabled={loading}
              >
                {loading ? (
                  <>
                    <Loader2 className="w-5 h-5 mr-2 animate-spin" />
                    กำลังสมัครสมาชิก...
                  </>
                ) : (
                  "สมัครสมาชิก"
                )}
              </Button>

              {/* Login Link */}
              <div className="text-center">
                <p className="text-sm text-muted-foreground">
                  มีบัญชีอยู่แล้ว?{" "}
                  <Link to="/login" className="text-primary hover:underline font-medium">
                    เข้าสู่ระบบ
                  </Link>
                </p>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
