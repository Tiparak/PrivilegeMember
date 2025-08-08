import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Alert, AlertDescription } from "@/components/ui/alert";
import {
  Crown,
  Users,
  Gift,
  Target,
  CreditCard,
  BarChart3,
  Plus,
  Edit,
  Trash2,
  CheckCircle,
  XCircle,
  TrendingUp,
  Award,
  Calendar,
  DollarSign,
  Eye,
  Settings,
  User,
  Mail,
  Phone,
  Save,
  X
} from "lucide-react";

export default function Admin() {
  const [activeTab, setActiveTab] = useState("dashboard");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // Mock data - ในระบบจริงจะดึงจาก API
  const [dashboardStats, setDashboardStats] = useState({
    totalUsers: 1250,
    totalPoints: 2500000,
    totalRedemptions: 450,
    activeRewards: 8,
    newUsersToday: 15,
    pointsIssuedToday: 25000
  });

  const [users, setUsers] = useState([
    { id: 1, email: "premium.user1@example.com", fullName: "Premium User1", phone: "081-234-5678", points: 12500, memberLevel: "gold", createdAt: "2024-01-01", status: "active" },
    { id: 2, email: "somchai@example.com", fullName: "สมชาย ใจดี", phone: "089-123-4567", points: 7850, memberLevel: "gold", createdAt: "2024-01-05", status: "active" },
    { id: 3, email: "user3@example.com", fullName: "นางสาวมานี มีเงิน", phone: "092-345-6789", points: 3200, memberLevel: "silver", createdAt: "2024-01-10", status: "active" }
  ]);

  const [rewards, setRewards] = useState([
    { id: 1, name: "คูปองส่วนลด 10%", description: "ใช้ได้กับสินค้าทุกประเภท", pointsRequired: 500, category: "discount", isActive: true },
    { id: 2, name: "กระเป๋าผ้า Premium", description: "ของพรีเมียมคุณภาพสูง", pointsRequired: 1200, category: "product", isActive: true },
    { id: 3, name: "บัตรกำนัล 1,000 บาท", description: "บัตรกำนัลช้อปปิ้ง", pointsRequired: 5000, category: "voucher", isActive: true }
  ]);

  const [milestones, setMilestones] = useState([
    { id: 1, pointsRequired: 1000, rewardTitle: "ส่วนลด 5%", rewardDescription: "รับส่ว��ลด 5% สำหรับการซื้อครั้งถัดไป", isActive: true },
    { id: 2, pointsRequired: 5000, rewardTitle: "ของพรีเมียม", rewardDescription: "รับของพรีเมียมพิเศษจากร้าน", isActive: true },
    { id: 3, pointsRequired: 10000, rewardTitle: "ส่วนลด 15%", rewardDescription: "รับส่วนลด 15% และสิทธิพิเศษ", isActive: true }
  ]);

  const [redemptions, setRedemptions] = useState([
    { id: 1, userId: 1, userName: "Premium User1", rewardName: "คูปองส่วนลด 10%", pointsUsed: 500, status: "pending", createdAt: "2024-01-20" },
    { id: 2, userId: 2, userName: "สมชาย ใจดี", rewardName: "บัตรกำนัล 1,000 บาท", pointsUsed: 5000, status: "approved", createdAt: "2024-01-19" },
    { id: 3, userId: 3, userName: "นางสาวมานี มีเงิน", rewardName: "กระเป๋าผ้า Premium", pointsUsed: 1200, status: "completed", createdAt: "2024-01-18" }
  ]);

  const [editingUser, setEditingUser] = useState(null);
  const [editingReward, setEditingReward] = useState(null);
  const [editingMilestone, setEditingMilestone] = useState(null);
  const [showUserDialog, setShowUserDialog] = useState(false);
  const [showRewardDialog, setShowRewardDialog] = useState(false);
  const [showMilestoneDialog, setShowMilestoneDialog] = useState(false);

  // Form states
  const [userForm, setUserForm] = useState({
    email: "",
    fullName: "",
    phone: "",
    points: "",
    memberLevel: "bronze"
  });

  const [rewardForm, setRewardForm] = useState({
    name: "",
    description: "",
    pointsRequired: "",
    category: "discount",
    isActive: true
  });

  const [milestoneForm, setMilestoneForm] = useState({
    pointsRequired: "",
    rewardTitle: "",
    rewardDescription: "",
    isActive: true
  });

  const resetForms = () => {
    setUserForm({ email: "", fullName: "", phone: "", points: "", memberLevel: "bronze" });
    setRewardForm({ name: "", description: "", pointsRequired: "", category: "discount", isActive: true });
    setMilestoneForm({ pointsRequired: "", rewardTitle: "", rewardDescription: "", isActive: true });
    setEditingUser(null);
    setEditingReward(null);
    setEditingMilestone(null);
  };

  const handleError = (message) => {
    setError(message);
    setTimeout(() => setError(""), 5000);
  };

  const handleSuccess = (message) => {
    setSuccess(message);
    setTimeout(() => setSuccess(""), 3000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-purple-50">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Link to="/" className="flex items-center space-x-2">
                <div className="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-primary to-purple-600 rounded-lg">
                  <Crown className="w-6 h-6 text-white" />
                </div>
                <span className="text-2xl font-bold bg-gradient-to-r from-primary to-purple-600 bg-clip-text text-transparent">
                  Privilege Member
                </span>
              </Link>
              <Badge variant="secondary" className="bg-primary/10 text-primary border-primary/20">
                <Settings className="w-3 h-3 mr-1" />
                Admin Panel
              </Badge>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-muted-foreground">ผ��้ดูแลระบบ</span>
              <Link to="/">
                <Button variant="outline">กลับหน้าหลัก</Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Page Title */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-2">ระบบจัดการ Privilege Member</h1>
          <p className="text-muted-foreground">จัดการสมาชิก รางวัล และระบบคะแนนทั้งหมด</p>
        </div>

        {/* Success/Error Messages */}
        {error && (
          <Alert variant="destructive" className="mb-6">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}
        {success && (
          <Alert className="mb-6 border-success bg-success/10">
            <CheckCircle className="w-4 h-4 text-success" />
            <AlertDescription className="text-success">{success}</AlertDescription>
          </Alert>
        )}

        {/* Main Content */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
          <TabsList className="grid w-full grid-cols-7">
            <TabsTrigger value="dashboard">Dashboard</TabsTrigger>
            <TabsTrigger value="users">สมาชิก</TabsTrigger>
            <TabsTrigger value="rewards">รางวัล</TabsTrigger>
            <TabsTrigger value="milestones">Milestones</TabsTrigger>
            <TabsTrigger value="transactions">ธุรกรรม</TabsTrigger>
            <TabsTrigger value="redemptions">การแลก</TabsTrigger>
            <TabsTrigger value="reports">รายงาน</TabsTrigger>
          </TabsList>

          {/* Dashboard Tab */}
          <TabsContent value="dashboard" className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">สมาชิกทั้งหมด</CardTitle>
                  <Users className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{dashboardStats.totalUsers.toLocaleString()}</div>
                  <p className="text-xs text-muted-foreground">
                    +{dashboardStats.newUsersToday} สมาชิกใหม่วันนี้
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">คะแนนรวม</CardTitle>
                  <CreditCard className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{dashboardStats.totalPoints.toLocaleString()}</div>
                  <p className="text-xs text-muted-foreground">
                    +{dashboardStats.pointsIssuedToday.toLocaleString()} คะแนนวันนี้
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">การแลกรางวัล</CardTitle>
                  <Gift className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{dashboardStats.totalRedemptions}</div>
                  <p className="text-xs text-muted-foreground">
                    รางวัลที่แลกทั้งหมด
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">รางวัลที่เปิดใช้งาน</CardTitle>
                  <Award className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{dashboardStats.activeRewards}</div>
                  <p className="text-xs text-muted-foreground">
                    รางวัลที่สามารถแลกได้
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">อัตราการเติบโต</CardTitle>
                  <TrendingUp className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-success">+12%</div>
                  <p className="text-xs text-muted-foreground">
                    เปรียบเทียบเดือนที่แล้ว
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">ระดับความพึงพอใจ</CardTitle>
                  <BarChart3 className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-primary">4.8/5</div>
                  <p className="text-xs text-muted-foreground">
                    คะแนนความพึงพอใจ
                  </p>
                </CardContent>
              </Card>
            </div>

            {/* Recent Activities */}
            <Card>
              <CardHeader>
                <CardTitle>กิจกรรมล่าสุด</CardTitle>
                <CardDescription>รายการธุรกรรมและกิจกรรมที่เกิดขึ้นล่าสุด</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center space-x-4">
                    <div className="w-2 h-2 bg-success rounded-full"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Premium User1 แลกรางวัลคูปองส่วนลด 10%</p>
                      <p className="text-xs text-muted-foreground">5 นาทีที่แล้ว</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-4">
                    <div className="w-2 h-2 bg-primary rounded-full"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">สมาชิกใหม่ 3 คน สมัครเข้าร่วม</p>
                      <p className="text-xs text-muted-foreground">15 นาทีที่แล้ว</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-4">
                    <div className="w-2 h-2 bg-warning rounded-full"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">มีการออกคะแนนใหม่ 1,500 คะแนน</p>
                      <p className="text-xs text-muted-foreground">30 นาทีที่แล้ว</p>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Users Management Tab - will continue in next part */}
          <TabsContent value="users" className="space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold">จัดการสมาชิก</h2>
                <p className="text-muted-foreground">เพิ่ม แก้ไข หรือลบข้อมูลสมาชิก</p>
              </div>
              <Dialog open={showUserDialog} onOpenChange={setShowUserDialog}>
                <DialogTrigger asChild>
                  <Button onClick={() => { resetForms(); setShowUserDialog(true); }}>
                    <Plus className="w-4 h-4 mr-2" />
                    เพิ่มสมาชิก
                  </Button>
                </DialogTrigger>
                <DialogContent className="max-w-md">
                  <DialogHeader>
                    <DialogTitle>{editingUser ? 'แก้ไขสมาชิก' : 'เพิ่มสมาชิกใหม่'}</DialogTitle>
                    <DialogDescription>
                      กรอกข้อมูลสมาชิก{editingUser ? 'ที่ต้องการแก้ไข' : 'ใหม่'}
                    </DialogDescription>
                  </DialogHeader>
                  <div className="space-y-4">
                    <div>
                      <Label htmlFor="email">อีเมล</Label>
                      <Input
                        id="email"
                        type="email"
                        value={userForm.email}
                        onChange={(e) => setUserForm({...userForm, email: e.target.value})}
                        placeholder="user@example.com"
                      />
                    </div>
                    <div>
                      <Label htmlFor="fullName">ชื่อ-นามสกุล</Label>
                      <Input
                        id="fullName"
                        value={userForm.fullName}
                        onChange={(e) => setUserForm({...userForm, fullName: e.target.value})}
                        placeholder="ชื่อ นามสกุล"
                      />
                    </div>
                    <div>
                      <Label htmlFor="phone">เบอร์โทรศัพท์</Label>
                      <Input
                        id="phone"
                        value={userForm.phone}
                        onChange={(e) => setUserForm({...userForm, phone: e.target.value})}
                        placeholder="089-123-4567"
                      />
                    </div>
                    <div>
                      <Label htmlFor="points">คะแนน</Label>
                      <Input
                        id="points"
                        type="number"
                        value={userForm.points}
                        onChange={(e) => setUserForm({...userForm, points: e.target.value})}
                        placeholder="0"
                      />
                    </div>
                    <div>
                      <Label htmlFor="memberLevel">ระดับสมาชิก</Label>
                      <Select value={userForm.memberLevel} onValueChange={(value) => setUserForm({...userForm, memberLevel: value})}>
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="bronze">Bronze</SelectItem>
                          <SelectItem value="silver">Silver</SelectItem>
                          <SelectItem value="gold">Gold</SelectItem>
                          <SelectItem value="platinum">Platinum</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="flex space-x-2">
                      <Button className="flex-1" onClick={() => {
                        // Save user logic here
                        handleSuccess(editingUser ? 'แก้ไขสมาชิกสำเร็จ' : 'เพิ่มสมาชิกสำเร็จ');
                        setShowUserDialog(false);
                        resetForms();
                      }}>
                        <Save className="w-4 h-4 mr-2" />
                        บันทึก
                      </Button>
                      <Button variant="outline" onClick={() => {
                        setShowUserDialog(false);
                        resetForms();
                      }}>
                        <X className="w-4 h-4 mr-2" />
                        ยกเลิก
                      </Button>
                    </div>
                  </div>
                </DialogContent>
              </Dialog>
            </div>

            <Card>
              <CardContent>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>อ���เมล</TableHead>
                      <TableHead>ชื่อ-นามสกุล</TableHead>
                      <TableHead>โทรศัพท์</TableHead>
                      <TableHead>คะแนน</TableHead>
                      <TableHead>ระดับ</TableHead>
                      <TableHead>สถานะ</TableHead>
                      <TableHead>การจัดการ</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {users.map((user) => (
                      <TableRow key={user.id}>
                        <TableCell className="font-medium">{user.email}</TableCell>
                        <TableCell>{user.fullName}</TableCell>
                        <TableCell>{user.phone}</TableCell>
                        <TableCell>{user.points.toLocaleString()}</TableCell>
                        <TableCell>
                          <Badge variant={user.memberLevel === 'platinum' ? 'default' : user.memberLevel === 'gold' ? 'secondary' : 'outline'}>
                            {user.memberLevel}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge variant={user.status === 'active' ? 'default' : 'destructive'}>
                            {user.status === 'active' ? 'ใช้งาน' : 'ระงับ'}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            <Button size="sm" variant="outline" onClick={() => {
                              setEditingUser(user);
                              setUserForm({
                                email: user.email,
                                fullName: user.fullName,
                                phone: user.phone,
                                points: user.points.toString(),
                                memberLevel: user.memberLevel
                              });
                              setShowUserDialog(true);
                            }}>
                              <Edit className="w-3 h-3" />
                            </Button>
                            <Button size="sm" variant="outline">
                              <Eye className="w-3 h-3" />
                            </Button>
                            <Button size="sm" variant="destructive">
                              <Trash2 className="w-3 h-3" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Continue with other tabs... */}
        </Tabs>
      </div>
    </div>
  );
}
