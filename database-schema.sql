-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(255) NOT NULL,
    points INTEGER DEFAULT 0,
    member_level VARCHAR(20) DEFAULT 'bronze' CHECK (member_level IN ('bronze', 'silver', 'gold', 'platinum')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create point_transactions table
CREATE TABLE IF NOT EXISTS point_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    points INTEGER NOT NULL,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('earn', 'redeem', 'bonus')),
    description TEXT NOT NULL,
    reference_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create rewards table
CREATE TABLE IF NOT EXISTS rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (category IN ('discount', 'product', 'voucher')),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create redemption_history table
CREATE TABLE IF NOT EXISTS redemption_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reward_id UUID REFERENCES rewards(id) ON DELETE CASCADE,
    points_used INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create milestones table
CREATE TABLE IF NOT EXISTS milestones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    points_required INTEGER NOT NULL,
    reward_title VARCHAR(255) NOT NULL,
    reward_description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_point_transactions_user_id ON point_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_point_transactions_created_at ON point_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_redemption_history_user_id ON redemption_history(user_id);
CREATE INDEX IF NOT EXISTS idx_rewards_is_active ON rewards(is_active);
CREATE INDEX IF NOT EXISTS idx_milestones_is_active ON milestones(is_active);

-- Insert sample data for rewards
INSERT INTO rewards (name, description, points_required, category, is_active) VALUES
('คูปองส่วนลด 10%', 'ใช้ได้กับสินค้าทุกประเภท', 500, 'discount', true),
('กระเป๋าผ้า Premium', 'ของพรีเมียมคุณภาพสูง', 1200, 'product', true),
('ส่วนลด 20%', 'ส่วนลดพิเศษสำหรับสมาชิก', 2000, 'discount', true),
('บัตรกำนัล 1,000 บาท', 'บัตรกำนัลช้อปปิ้ง', 5000, 'voucher', true),
('แก้วน้ำสแตนเลส', 'แก้วน้ำคุณภาพสูง', 800, 'product', true),
('ส่วนลด 30%', 'ส่วนลดส��งสุดสำหรับสมาชิก VIP', 3000, 'discount', true);

-- Insert sample data for milestones
INSERT INTO milestones (points_required, reward_title, reward_description, is_active) VALUES
(1000, 'ส่วนลด 5%', 'รับส่วนลด 5% สำหรับการซื้อครั้งถัดไป', true),
(5000, 'ของพรีเมียม', 'รับของพรีเมียมพิเศษจากร้าน', true),
(10000, 'ส่วนลด 15%', 'รับส่วนลด 15% และสิทธิพิเศษ', true),
(25000, 'สิทธิ VIP', 'รับสิทธิ VIP และผลประโยชน์พิเศษ', true),
(50000, 'สมาชิกแพลทินั่ม', 'เลื่อนขั้นเป็นสมาชิกแพลทินั่ม', true);

-- Create a function to update user points automatically
CREATE OR REPLACE FUNCTION update_user_points_from_transactions()
RETURNS TRIGGER AS $$
BEGIN
    -- Update user's total points based on all transactions
    UPDATE users 
    SET points = (
        SELECT COALESCE(SUM(points), 0) 
        FROM point_transactions 
        WHERE user_id = NEW.user_id
    ),
    updated_at = NOW()
    WHERE id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update user points when transactions are added
DROP TRIGGER IF EXISTS trigger_update_user_points ON point_transactions;
CREATE TRIGGER trigger_update_user_points
    AFTER INSERT ON point_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_points_from_transactions();

-- Create a function to update member levels based on points
CREATE OR REPLACE FUNCTION update_member_level()
RETURNS TRIGGER AS $$
BEGIN
    -- Update member level based on points
    UPDATE users
    SET member_level = CASE
        WHEN NEW.points >= 50000 THEN 'platinum'
        WHEN NEW.points >= 25000 THEN 'gold'
        WHEN NEW.points >= 10000 THEN 'silver'
        ELSE 'bronze'
    END
    WHERE id = NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update member level when points change
DROP TRIGGER IF EXISTS trigger_update_member_level ON users;
CREATE TRIGGER trigger_update_member_level
    AFTER UPDATE OF points ON users
    FOR EACH ROW
    WHEN (OLD.points IS DISTINCT FROM NEW.points)
    EXECUTE FUNCTION update_member_level();

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE point_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE redemption_history ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own data
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Policy: Users can only see their own transactions
CREATE POLICY "Users can view own transactions" ON point_transactions
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- Policy: Users can only see their own redemption history
CREATE POLICY "Users can view own redemptions" ON redemption_history
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- Policy: Anyone can view rewards and milestones (public data)
CREATE POLICY "Anyone can view rewards" ON rewards
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view milestones" ON milestones
    FOR SELECT USING (true);
