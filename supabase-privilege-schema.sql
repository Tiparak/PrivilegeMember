-- Create privilege schema
CREATE SCHEMA IF NOT EXISTS privilege;

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set search path to privilege schema
SET search_path TO privilege, public;

-- Create users table in privilege schema
CREATE TABLE privilege.users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(255) NOT NULL,
    points INTEGER DEFAULT 0,
    member_level VARCHAR(20) DEFAULT 'bronze' CHECK (member_level IN ('bronze', 'silver', 'gold', 'platinum')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create point_transactions table in privilege schema
CREATE TABLE privilege.point_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES privilege.users(id) ON DELETE CASCADE,
    points INTEGER NOT NULL,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('earn', 'redeem', 'bonus')),
    description TEXT NOT NULL,
    reference_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create rewards table in privilege schema
CREATE TABLE privilege.rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL,
    category VARCHAR(20) NOT NULL CHECK (category IN ('discount', 'product', 'voucher')),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create redemption_history table in privilege schema
CREATE TABLE privilege.redemption_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES privilege.users(id) ON DELETE CASCADE,
    reward_id UUID REFERENCES privilege.rewards(id) ON DELETE CASCADE,
    points_used INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create milestones table in privilege schema
CREATE TABLE privilege.milestones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    points_required INTEGER NOT NULL,
    reward_title VARCHAR(255) NOT NULL,
    reward_description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_privilege_users_email ON privilege.users(email);
CREATE INDEX idx_privilege_users_phone ON privilege.users(phone);
CREATE INDEX idx_privilege_point_transactions_user_id ON privilege.point_transactions(user_id);
CREATE INDEX idx_privilege_point_transactions_created_at ON privilege.point_transactions(created_at);
CREATE INDEX idx_privilege_redemption_history_user_id ON privilege.redemption_history(user_id);
CREATE INDEX idx_privilege_rewards_is_active ON privilege.rewards(is_active);
CREATE INDEX idx_privilege_milestones_is_active ON privilege.milestones(is_active);

-- Insert sample data for rewards
INSERT INTO privilege.rewards (name, description, points_required, category, is_active) VALUES
('คูปองส่วนลด 10%', 'ใช้ได้กับสินค้าทุกประเภท', 500, 'discount', true),
('กระเป๋าผ้า Premium', 'ของพรีเมียมคุณภาพสูง', 1200, 'product', true),
('ส่วนลด 20%', 'ส่วนลดพิเศษสำหรับสมาชิก', 2000, 'discount', true),
('บัตรกำนัล 1,000 บาท', 'บัตรกำนัลช้อปปิ้ง', 5000, 'voucher', true),
('แก้วน้ำสแตนเลส', 'แก้วน้ำคุณภาพสูง', 800, 'product', true),
('ส่วนลด 30%', 'ส่วนลดสูงสุดสำหรับสมาชิก VIP', 3000, 'discount', true),
('��ูฟังบลูทูธ', 'หูฟังไร้สายคุณภาพสูง', 3500, 'product', true),
('คูปองส่วนลด 50%', 'ส่วนลดสูงสุดสำหรับสมาชิก Platinum', 7500, 'discount', true);

-- Insert sample data for milestones
INSERT INTO privilege.milestones (points_required, reward_title, reward_description, is_active) VALUES
(1000, 'ส่วนลด 5%', 'รับส่วนลด 5% สำหรับการซื้อครั้งถัดไป', true),
(5000, 'ของพรีเมียม', 'รับของพรีเมียมพิเศษจากร้าน', true),
(10000, 'ส่วนลด 15%', 'รับส่วนลด 15% และสิทธิพิเศษ', true),
(25000, 'สิทธิ VIP', 'รับสิทธิ VIP และผลประโยชน์พิเศษ', true),
(50000, 'สมาชิกแพลทินั่ม', 'เลื่อนขั้นเป็นสมาชิกแพลทินั่ม', true);

-- Insert sample user data
INSERT INTO privilege.users (email, phone, full_name, points, member_level) VALUES
('somchai@example.com', '089-123-4567', 'สมชาย ใจดี', 7850, 'gold'),
('premium.user1@example.com', '081-234-5678', 'Premium User1', 12500, 'gold');

-- Insert sample transaction data for Premium User1
DO $$
DECLARE
    user_uuid UUID;
BEGIN
    -- Get Premium User1's UUID
    SELECT id INTO user_uuid FROM privilege.users WHERE email = 'premium.user1@example.com';
    
    -- Insert sample transactions
    INSERT INTO privilege.point_transactions (user_id, points, transaction_type, description, created_at) VALUES
    (user_uuid, 1000, 'bonus', 'โบนัสสมาชิกใหม่', '2024-01-08 10:00:00+07'),
    (user_uuid, 220, 'earn', 'ซื้อสินค้า - Terminal 21', '2024-01-10 14:30:00+07'),
    (user_uuid, -500, 'redeem', 'แลกคูปองส่วนลด 10%', '2024-01-12 16:45:00+07'),
    (user_uuid, 150, 'earn', 'ซื้อสินค้า - Central Plaza', '2024-01-15 11:20:00+07'),
    (user_uuid, 300, 'earn', 'ซื้อสินค้า - Siam Paragon', '2024-01-18 15:10:00+07'),
    (user_uuid, 180, 'earn', 'ซื้อสินค้า - EmQuartier', '2024-01-20 13:25:00+07'),
    (user_uuid, 250, 'earn', 'ซื้อสินค้า - ICONSIAM', '2024-01-22 17:30:00+07');
END $$;

-- Insert sample transaction data for สมชาย ใจดี
DO $$
DECLARE
    user_uuid UUID;
BEGIN
    -- Get สมชาย ใจดี's UUID
    SELECT id INTO user_uuid FROM privilege.users WHERE email = 'somchai@example.com';
    
    -- Insert sample transactions
    INSERT INTO privilege.point_transactions (user_id, points, transaction_type, description, created_at) VALUES
    (user_uuid, 1000, 'bonus', 'โบนัสสมาชิกใหม่', '2024-01-05 09:00:00+07'),
    (user_uuid, 300, 'earn', 'ซื้อสินค้า - Central World', '2024-01-07 12:15:00+07'),
    (user_uuid, 450, 'earn', 'ซื้อสินค้า - MBK Center', '2024-01-09 14:20:00+07'),
    (user_uuid, -200, 'redeem', 'แลกของพรีเมียม', '2024-01-11 10:30:00+07'),
    (user_uuid, 200, 'earn', 'ซื้อสินค้า - Chatuchak', '2024-01-14 16:45:00+07'),
    (user_uuid, 350, 'earn', 'ซื้อสินค้า - Gateway', '2024-01-16 11:00:00+07'),
    (user_uuid, 180, 'earn', 'ซื้อสินค้า - Future Park', '2024-01-19 15:30:00+07');
END $$;

-- Create a function to update user points automatically
CREATE OR REPLACE FUNCTION privilege.update_user_points_from_transactions()
RETURNS TRIGGER AS $$
BEGIN
    -- Update user's total points based on all transactions
    UPDATE privilege.users 
    SET points = (
        SELECT COALESCE(SUM(points), 0) 
        FROM privilege.point_transactions 
        WHERE user_id = NEW.user_id
    ),
    updated_at = NOW()
    WHERE id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update user points when transactions are added
DROP TRIGGER IF EXISTS trigger_update_user_points ON privilege.point_transactions;
CREATE TRIGGER trigger_update_user_points
    AFTER INSERT ON privilege.point_transactions
    FOR EACH ROW
    EXECUTE FUNCTION privilege.update_user_points_from_transactions();

-- Create a function to update member levels based on points
CREATE OR REPLACE FUNCTION privilege.update_member_level()
RETURNS TRIGGER AS $$
BEGIN
    -- Update member level based on points
    UPDATE privilege.users
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
DROP TRIGGER IF EXISTS trigger_update_member_level ON privilege.users;
CREATE TRIGGER trigger_update_member_level
    AFTER UPDATE OF points ON privilege.users
    FOR EACH ROW
    WHEN (OLD.points IS DISTINCT FROM NEW.points)
    EXECUTE FUNCTION privilege.update_member_level();

-- Row Level Security (RLS) policies
ALTER TABLE privilege.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE privilege.point_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE privilege.redemption_history ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own data
CREATE POLICY "Users can view own profile" ON privilege.users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" ON privilege.users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Policy: Users can only see their own transactions
CREATE POLICY "Users can view own transactions" ON privilege.point_transactions
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- Policy: Users can only see their own redemption history
CREATE POLICY "Users can view own redemptions" ON privilege.redemption_history
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- Policy: Anyone can view rewards and milestones (public data)
CREATE POLICY "Anyone can view rewards" ON privilege.rewards
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view milestones" ON privilege.milestones
    FOR SELECT USING (true);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA privilege TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA privilege TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA privilege TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA privilege TO anon, authenticated;

-- Final message
SELECT 'Database schema "privilege" created successfully with sample data!' as message;
