import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  Star, 
  Gift, 
  TrendingUp, 
  Award,
  History,
  Crown,
  Sparkles,
  Calendar,
  ArrowRight,
  Trophy,
  Target
} from "lucide-react";

export default function Dashboard() {
  // Mock data
  const userPoints = 7850;
  const nextMilestone = 10000;
  const progressPercentage = (userPoints / nextMilestone) * 100;

  const milestones = [
    { points: 1000, reward: "ส่วนลด 5%", achieved: true },
    { points: 5000, reward: "ของพรีเมียม", achieved: true },
    { points: 10000, reward: "ส่วนลด 15%", achieved: false },
    { points: 25000, reward: "สิทธิ VIP", achieved: false },
  ];

  const recentTransactions = [
    { date: "2024-01-15", description: "ซื้อสินค้า - Central Plaza", points: "+150", type: "earn" },
    { date: "2024-01-12", description: "แลกคูปองส่วนลด 10%", points: "-500", type: "redeem" },
    { date: "2024-01-10", description: "ซื้อสินค้า - Terminal 21", points: "+220", type: "earn" },
    { date: "2024-01-08", description: "โบนัสสมาชิกใหม่", points: "+1000", type: "bonus" },
  ];

  const availableRewards = [
    { id: 1, name: "คูปองส่วนลด 10%", points: 500, description: "ใช้ได้กับสินค้าทุกประเภท", category: "discount" },
    { id: 2, name: "กระเป๋าผ้า Premium", points: 1200, description: "ของพรีเมียมคุณภาพสูง", category: "product" },
    { id: 3, name: "ส่วนลด 20%", points: 2000, description: "ส่วนลดพิเศษสำหรับสมาชิก", category: "discount" },
    { id: 4, name: "บัตรกำนัล 1,000 บาท", points: 5000, description: "บัตรกำนัลช้อปปิ้ง", category: "voucher" },
  ];

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
              <span className="text-sm text-muted-foreground">สวัสดี, สมชาย ใจดี</span>
              <Button variant="outline" size="sm">ออกจากระบบ</Button>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Welcome Section */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-2">ยินดีต้อนรับ, สมชาย! 👋</h1>
          <p className="text-muted-foreground">ตรวจสอบคะแนนสะสมและรางวัลของคุณได้ที่นี่</p>
        </div>

        {/* Points Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card className="bg-gradient-to-br from-primary to-purple-600 text-white">
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardTitle className="text-lg">คะแนนสะสมทั้งหมด</CardTitle>
                <Star className="w-6 h-6" />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold mb-2">{userPoints.toLocaleString()}</div>
              <div className="text-white/80 text-sm">คะแนน</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardTitle className="text-lg">เป้าหมายถ���ดไป</CardTitle>
                <Target className="w-6 h-6 text-primary" />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold mb-2 text-primary">{(nextMilestone - userPoints).toLocaleString()}</div>
              <div className="text-muted-foreground text-sm">คะแนนที่เหลือ</div>
              <Progress value={progressPercentage} className="mt-3" />
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardTitle className="text-lg">ระดับสมาชิก</CardTitle>
                <Trophy className="w-6 h-6 text-gold" />
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex items-center space-x-2 mb-2">
                <Badge variant="secondary" className="bg-gold/10 text-gold border-gold/20">
                  <Crown className="w-4 h-4 mr-1" />
                  Gold Member
                </Badge>
              </div>
              <div className="text-muted-foreground text-sm">สิทธิพิเศษระดับทอง</div>
            </CardContent>
          </Card>
        </div>

        {/* Main Content */}
        <Tabs defaultValue="milestones" className="space-y-6">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="milestones">Milestones</TabsTrigger>
            <TabsTrigger value="rewards">รางวัล</TabsTrigger>
            <TabsTrigger value="history">ประวัติ</TabsTrigger>
            <TabsTrigger value="profile">โปรไฟล์</TabsTrigger>
          </TabsList>

          {/* Milestones Tab */}
          <TabsContent value="milestones" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Award className="w-5 h-5 mr-2 text-primary" />
                  Milestone Rewards
                </CardTitle>
                <CardDescription>
                  เป้าหมายคะแนนและรางวัลที่รอคุณอยู่
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {milestones.map((milestone, index) => (
                    <div key={index} className={`flex items-center justify-between p-4 rounded-lg border ${
                      milestone.achieved ? 'bg-success/5 border-success/20' : 'bg-gray-50 border-gray-200'
                    }`}>
                      <div className="flex items-center space-x-4">
                        <div className={`w-12 h-12 rounded-full flex items-center justify-center ${
                          milestone.achieved 
                            ? 'bg-success text-white' 
                            : userPoints >= milestone.points * 0.8 
                              ? 'bg-warning text-white' 
                              : 'bg-gray-200 text-gray-600'
                        }`}>
                          {milestone.achieved ? (
                            <Trophy className="w-6 h-6" />
                          ) : (
                            <Target className="w-6 h-6" />
                          )}
                        </div>
                        <div>
                          <div className="font-semibold">{milestone.points.toLocaleString()} คะแนน</div>
                          <div className="text-sm text-muted-foreground">{milestone.reward}</div>
                        </div>
                      </div>
                      <div>
                        {milestone.achieved ? (
                          <Badge variant="secondary" className="bg-success/10 text-success border-success/20">
                            สำเร็จแล้ว
                          </Badge>
                        ) : userPoints >= milestone.points * 0.8 ? (
                          <Badge variant="secondary" className="bg-warning/10 text-warning border-warning/20">
                            ใกล้ถึงแล้ว
                          </Badge>
                        ) : (
                          <Badge variant="outline">ยังไม่ถึง</Badge>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Rewards Tab */}
          <TabsContent value="rewards" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Gift className="w-5 h-5 mr-2 text-primary" />
                  รางวัลที่แลกได้
                </CardTitle>
                <CardDescription>
                  เลือกรางวัลที่คุณต้องการด้วยคะแนนสะสม
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {availableRewards.map((reward) => (
                    <Card key={reward.id} className="hover:shadow-md transition-shadow">
                      <CardHeader className="pb-3">
                        <div className="flex items-center justify-between">
                          <CardTitle className="text-lg">{reward.name}</CardTitle>
                          <Badge variant={reward.category === 'discount' ? 'default' : reward.category === 'product' ? 'secondary' : 'outline'}>
                            {reward.category === 'discount' ? 'ส่วนลด' : reward.category === 'product' ? 'สินค้า' : 'บัตรกำนัล'}
                          </Badge>
                        </div>
                      </CardHeader>
                      <CardContent>
                        <p className="text-sm text-muted-foreground mb-4">{reward.description}</p>
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-2">
                            <Star className="w-4 h-4 text-primary" />
                            <span className="font-semibold text-primary">{reward.points.toLocaleString()} คะแนน</span>
                          </div>
                          <Button 
                            size="sm" 
                            disabled={userPoints < reward.points}
                            className="px-4"
                          >
                            {userPoints >= reward.points ? 'แลกเลย' : 'คะแนนไม่พอ'}
                            <ArrowRight className="w-4 h-4 ml-1" />
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* History Tab */}
          <TabsContent value="history" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <History className="w-5 h-5 mr-2 text-primary" />
                  ประวัติการทำธุรกรรม
                </CardTitle>
                <CardDescription>
                  ตรวจสอบประวัติการรับและใช้คะแนนของคุณ
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {recentTransactions.map((transaction, index) => (
                    <div key={index} className="flex items-center justify-between p-4 rounded-lg border bg-white">
                      <div className="flex items-center space-x-4">
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                          transaction.type === 'earn' 
                            ? 'bg-success/10 text-success' 
                            : transaction.type === 'redeem'
                              ? 'bg-destructive/10 text-destructive'
                              : 'bg-gold/10 text-gold'
                        }`}>
                          {transaction.type === 'earn' ? (
                            <TrendingUp className="w-5 h-5" />
                          ) : transaction.type === 'redeem' ? (
                            <Gift className="w-5 h-5" />
                          ) : (
                            <Sparkles className="w-5 h-5" />
                          )}
                        </div>
                        <div>
                          <div className="font-medium">{transaction.description}</div>
                          <div className="text-sm text-muted-foreground flex items-center">
                            <Calendar className="w-4 h-4 mr-1" />
                            {transaction.date}
                          </div>
                        </div>
                      </div>
                      <div className={`font-bold text-lg ${
                        transaction.points.startsWith('+') ? 'text-success' : 'text-destructive'
                      }`}>
                        {transaction.points}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Profile Tab */}
          <TabsContent value="profile" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>ข้อมูลส่วนตัว</CardTitle>
                <CardDescription>
                  จัดการข้อมูลบัญชีและการตั้งค่าของคุณ
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="text-sm font-medium">ชื่อ-นามสกุล</label>
                      <div className="mt-1 p-3 bg-gray-50 rounded-lg">สมชาย ใจ��ี</div>
                    </div>
                    <div>
                      <label className="text-sm font-medium">อีเมล</label>
                      <div className="mt-1 p-3 bg-gray-50 rounded-lg">somchai@email.com</div>
                    </div>
                    <div>
                      <label className="text-sm font-medium">เบอร์โทรศัพท์</label>
                      <div className="mt-1 p-3 bg-gray-50 rounded-lg">089-123-4567</div>
                    </div>
                    <div>
                      <label className="text-sm font-medium">วันที่สมัครสมาชิก</label>
                      <div className="mt-1 p-3 bg-gray-50 rounded-lg">15 มกราคม 2024</div>
                    </div>
                  </div>
                  <div className="flex space-x-4">
                    <Button>แก้ไขข้อมูล</Button>
                    <Button variant="outline">เปลี่ยนรหัสผ่าน</Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
