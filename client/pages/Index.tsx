import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { SupabaseStatus } from "@/components/SupabaseStatus";
import {
  Star,
  Gift,
  TrendingUp,
  Users,
  Smartphone,
  Shield,
  Award,
  CreditCard,
  BarChart3,
  ArrowRight,
  Crown,
  Sparkles,
} from "lucide-react";

export default function Index() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-purple-50">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <div className="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-primary to-purple-600 rounded-lg">
                <Crown className="w-6 h-6 text-white" />
              </div>
              <span className="text-2xl font-bold bg-gradient-to-r from-primary to-purple-600 bg-clip-text text-transparent">
                Privilege Member
              </span>
            </div>
            <div className="flex items-center space-x-4">
              <Link to="/login">
                <Button variant="outline">เข้าสู่ระบบ</Button>
              </Link>
              <Link to="/register">
                <Button>สมัครสมาชิก</Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-20 px-4">
        <div className="container mx-auto text-center">
          <Badge variant="secondary" className="mb-6 px-4 py-2 text-sm">
            <Sparkles className="w-4 h-4 mr-2" />
            ระบบสะสมคะแนนที่ทันสมัย
          </Badge>
          <h1 className="text-5xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-primary via-purple-600 to-pink-600 bg-clip-text text-transparent">
            Privilege Member
          </h1>
          <p className="text-xl md:text-2xl text-muted-foreground mb-8 max-w-3xl mx-auto">
            ระบบสมาชิกและสะสมคะแนนที่จะมอบประสบการณ์พิเศษให้กับลูกค้าของคุณ
            <br />
            สะสมคะแนน แลกรางวัล และรับสิทธิพิเศษมากมาย
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Link to="/register">
              <Button size="lg" className="px-8 py-3 text-lg">
                เริ่มต้นใช้งาน
                <ArrowRight className="w-5 h-5 ml-2" />
              </Button>
            </Link>
            <Link to="/dashboard">
              <Button size="lg" variant="outline" className="px-8 py-3 text-lg">
                ดูตัวอย่างระบบ
              </Button>
            </Link>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl mx-auto">
            <Card className="text-center bg-gradient-to-br from-blue-50 to-blue-100 border-blue-200">
              <CardContent className="p-6">
                <div className="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center mx-auto mb-4">
                  <Users className="w-6 h-6 text-white" />
                </div>
                <div className="text-3xl font-bold text-blue-700 mb-2">
                  50,000+
                </div>
                <div className="text-blue-600">สมาชิกที่ใช้งาน</div>
              </CardContent>
            </Card>
            <Card className="text-center bg-gradient-to-br from-purple-50 to-purple-100 border-purple-200">
              <CardContent className="p-6">
                <div className="w-12 h-12 bg-primary rounded-lg flex items-center justify-center mx-auto mb-4">
                  <Star className="w-6 h-6 text-white" />
                </div>
                <div className="text-3xl font-bold text-primary mb-2">1M+</div>
                <div className="text-primary">คะแนนที่แลกแล้ว</div>
              </CardContent>
            </Card>
            <Card className="text-center bg-gradient-to-br from-amber-50 to-amber-100 border-amber-200">
              <CardContent className="p-6">
                <div className="w-12 h-12 bg-amber-500 rounded-lg flex items-center justify-center mx-auto mb-4">
                  <Gift className="w-6 h-6 text-white" />
                </div>
                <div className="text-3xl font-bold text-amber-700 mb-2">
                  5,000+
                </div>
                <div className="text-amber-600">รางวัลให้เลือก</div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4 bg-white">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4">ฟีเจอร์ครบครัน</h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              ระบบที่ออกแบบมาเพื่อตอบสนองทุกความต้องการของธุรกิจและลูกค้า
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {/* Feature 1 */}
            <Card className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <CreditCard className="w-6 h-6 text-primary" />
                </div>
                <CardTitle>ระบบสะสมคะแนน</CardTitle>
                <CardDescription>
                  เชื่อมต่อกับ POS และรับคะแนนอัตโนมัติ พร้อมระบบ Blue Code
                </CardDescription>
              </CardHeader>
            </Card>

            {/* Feature 2 */}
            <Card className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-gold/10 rounded-lg flex items-center justify-center mb-4">
                  <Award className="w-6 h-6 text-gold" />
                </div>
                <CardTitle>Milestone Rewards</CardTitle>
                <CardDescription>
                  ตั้งค่าระดับคะแนนและรางวัลพิเศษ พร้อมแจ้งเตือนอัตโนมัติ
                </CardDescription>
              </CardHeader>
            </Card>

            {/* Feature 3 */}
            <Card className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-success/10 rounded-lg flex items-center justify-center mb-4">
                  <Gift className="w-6 h-6 text-success" />
                </div>
                <CardTitle>ระบบแลกรางวัล</CardTitle>
                <CardDescription>
                  แลกคะแนนเป็นส่วนลด สินค้า หรือสิทธิพิเศษได้ง่ายๆ
                </CardDescription>
              </CardHeader>
            </Card>

            {/* Feature 4 */}
            <Card className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-blue-500/10 rounded-lg flex items-center justify-center mb-4">
                  <BarChart3 className="w-6 h-6 text-blue-500" />
                </div>
                <CardTitle>Admin Dashboard</CardTitle>
                <CardDescription>
                  จัดการสมาชิก รางวัล และดูรายงานสถิติแบบ Real-time
                </CardDescription>
              </CardHeader>
            </Card>

            {/* Feature 5 */}
            <Card className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-green-500/10 rounded-lg flex items-center justify-center mb-4">
                  <Smartphone className="w-6 h-6 text-green-500" />
                </div>
                <CardTitle>Multi-Platform</CardTitle>
                <CardDescription>
                  รองรับเว็บ แอปมือถือ และ LINE Official Account
                </CardDescription>
              </CardHeader>
            </Card>

            {/* Feature 6 */}
            <Card className="hover:shadow-lg transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-red-500/10 rounded-lg flex items-center justify-center mb-4">
                  <Shield className="w-6 h-6 text-red-500" />
                </div>
                <CardTitle>ความปลอดภัย</CardTitle>
                <CardDescription>
                  ระบบรักษาความปลอดภัยระดับสูง พร้อมการยืนยันตัวตน
                </CardDescription>
              </CardHeader>
            </Card>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 bg-gradient-to-r from-primary to-purple-600 text-white">
        <div className="container mx-auto text-center">
          <h2 className="text-4xl font-bold mb-6">
            พร้อมเริ่มต้นการเดินทางสู่ความสำเร็จแล้วหรือยัง?
          </h2>
          <p className="text-xl mb-8 opacity-90">
            สมัครสมาชิกวันนี้และเริ่มสะสมคะแนนเพื่อรับสิทธิพิเศษมากมาย
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to="/register">
              <Button
                size="lg"
                variant="secondary"
                className="px-8 py-3 text-lg"
              >
                สมัครสมาชิกฟรี
                <ArrowRight className="w-5 h-5 ml-2" />
              </Button>
            </Link>
            <Link to="/contact">
              <Button
                size="lg"
                variant="outline"
                className="px-8 py-3 text-lg border-white text-white hover:bg-white hover:text-primary"
              >
                ติดต่อขอข้อมูลเพิ่มเติม
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12 px-4">
        <div className="container mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <div className="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-primary to-purple-600 rounded-lg">
                  <Crown className="w-6 h-6 text-white" />
                </div>
                <span className="text-xl font-bold">Privilege Member</span>
              </div>
              <p className="text-gray-400">
                ระบบสมาชิกและสะสมคะแนนที่ทันสมัย เพื่อประสบการณ์ที่ดีที่สุด
              </p>
            </div>
            <div>
              <h3 className="font-semibold mb-4">ลิงก์ด่วน</h3>
              <ul className="space-y-2 text-gray-400">
                <li>
                  <Link to="/about" className="hover:text-white">
                    เกี่ยวกับเรา
                  </Link>
                </li>
                <li>
                  <Link to="/features" className="hover:text-white">
                    ฟีเจอร์
                  </Link>
                </li>
                <li>
                  <Link to="/pricing" className="hover:text-white">
                    แผนและราคา
                  </Link>
                </li>
                <li>
                  <Link to="/contact" className="hover:text-white">
                    ติดต่อเรา
                  </Link>
                </li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold mb-4">สำหรับสมาชิก</h3>
              <ul className="space-y-2 text-gray-400">
                <li>
                  <Link to="/login" className="hover:text-white">
                    เข้าสู่ระบบ
                  </Link>
                </li>
                <li>
                  <Link to="/register" className="hover:text-white">
                    สมัครสมาชิก
                  </Link>
                </li>
                <li>
                  <Link to="/dashboard" className="hover:text-white">
                    แดชบอร์ด
                  </Link>
                </li>
                <li>
                  <Link to="/help" className="hover:text-white">
                    ศูนย์ช่วยเหลือ
                  </Link>
                </li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold mb-4">ติดต่อ</h3>
              <ul className="space-y-2 text-gray-400">
                <li>อีเมล: info@privilegemember.co.th</li>
                <li>โทรศัพท์: 02-123-4567</li>
                <li>LINE: @privilegemember</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2024 Privilege Member. สงวนลิขสิทธิ์ทุกประการ</p>
          </div>
        </div>
      </footer>
    </div>
  );
}