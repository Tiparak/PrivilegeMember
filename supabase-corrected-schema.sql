-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables if they exist in privilege schema (cleanup)
DROP TABLE IF EXISTS privilege.redemption_history CASCADE;
DROP TABLE IF EXISTS privilege.point_transactions CASCADE;
DROP TABLE IF EXISTS privilege.rewards CASCADE;
DROP TABLE IF EXISTS privilege.milestones CASCADE;
DROP TABLE IF EXISTS privilege.users CASCADE;
DROP SCHEMA IF EXISTS privilege CASCADE;

-- Create tables in public schema (Supabase default)
-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
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
CREATE TABLE IF NOT EXISTS public.point_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    points INTEGER NOT NULL,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('earn', 'redeem', 'bonus')),
    description TEXT NOT NULL,
    reference_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create rewards table
CREATE TABLE IF NOT EXISTS public.rewards (
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
CREATE TABLE IF NOT EXISTS public.redemption_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE,
    points_used INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create milestones table
CREATE TABLE IF NOT EXISTS public.milestones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    points_required INTEGER NOT NULL,
    reward_title VARCHAR(255) NOT NULL,
    reward_description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_point_transactions_user_id ON public.point_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_point_transactions_created_at ON public.point_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_redemption_history_user_id ON public.redemption_history(user_id);
CREATE INDEX IF NOT EXISTS idx_rewards_is_active ON public.rewards(is_active);
CREATE INDEX IF NOT EXISTS idx_milestones_is_active ON public.milestones(is_active);

-- Clear existing data
TRUNCATE public.rewards, public.milestones, public.point_transactions, public.redemption_history, public.users CASCADE;

-- Insert sample data for rewards
INSERT INTO public.rewards (name, description, points_required, category, is_active) VALUES
('คูปองส่วนลด 10%', 'ใช้ได้กับสินค้าทุกประเภท', 500, 'discount', true),
('กระเป๋าผ้า Premium', 'ของพรีเมียมคุณภาพสูง', 1200, 'product', true),
('ส่วนลด 20%', 'ส่วนลดพิเศษสำหรับสมาชิก', 2000, 'discount', true),
('บัตรกำนัล 1,000 บาท', 'บัตรกำนัลช้อปปิ้ง', 5000, 'voucher', true),
('แก้วน้ำสแตนเลส', 'แก้วน้ำคุณภาพสูง', 800, 'product', true),
('ส่วนลด 30%', 'ส่วนลดสูงสุดสำหรับสมาชิก VIP', 3000, 'discount', true),
('หูฟังบลูทูธ', 'หูฟังไร้สายคุณภาพสูง', 3500, 'product', true),
('คูปองส่วนลด 50%', 'ส่วนลดสูงสุดสำหรับสมาชิก Platinum', 7500, 'discount', true);

-- Insert sample data for milestones
INSERT INTO public.milestones (points_required, reward_title, reward_description, is_active) VALUES
(1000, 'ส่วนลด 5%', 'รับส่วนลด 5% สำหรับการซื้อครั้งถัดไป', true),
(5000, 'ของพรีเมียม', 'รับของพรีเมียมพิเศษจากร้าน', true),
(10000, 'ส่วนลด 15%', 'รับส่วนลด 15% และสิทธิพิเศษ', true),
(25000, 'สิทธิ VIP', 'รับสิทธิ VIP และผลประโยชน์พิเศษ', true),
(50000, 'สมาชิกแพลทินั่ม', 'เลื่อนขั้นเป็นสมาชิกแพลทินั่ม', true);

-- Insert sample user data
INSERT INTO public.users (email, phone, full_name, points, member_level) VALUES
('somchai@example.com', '089-123-4567', 'สมชาย ใจดี', 7850, 'gold'),
('premium.user1@example.com', '081-234-5678', 'Premium User1', 12500, 'gold');

-- Insert sample transaction data for Premium User1
DO $$
DECLARE
    user_uuid UUID;
BEGIN
    -- Get Premium User1's UUID
    SELECT id INTO user_uuid FROM public.users WHERE email = 'premium.user1@example.com';
    
    -- Insert sample transactions
    INSERT INTO public.point_transactions (user_id, points, transaction_type, description, created_at) VALUES
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
    SELECT id INTO user_uuid FROM public.users WHERE email = 'somchai@example.com';
    
    -- Insert sample transactions
    INSERT INTO public.point_transactions (user_id, points, transaction_type, description, created_at) VALUES
    (user_uuid, 1000, 'bonus', 'โบนัสสมาชิกใหม่', '2024-01-05 09:00:00+07'),
    (user_uuid, 300, 'earn', 'ซื้อสินค้า - Central World', '2024-01-07 12:15:00+07'),
    (user_uuid, 450, 'earn', 'ซื้อสินค้า - MBK Center', '2024-01-09 14:20:00+07'),
    (user_uuid, -200, 'redeem', 'แลกของพรีเมียม', '2024-01-11 10:30:00+07'),
    (user_uuid, 200, 'earn', 'ซื้อสินค้า - Chatuchak', '2024-01-14 16:45:00+07'),
    (user_uuid, 350, 'earn', 'ซื้อสินค้า - Gateway', '2024-01-16 11:00:00+07'),
    (user_uuid, 180, 'earn', 'ซื้อสินค้า - Future Park', '2024-01-19 15:30:00+07');
END $$;

-- Create a function to update user points automatically
CREATE OR REPLACE FUNCTION public.update_user_points_from_transactions()
RETURNS TRIGGER AS $$
BEGIN
    -- Update user's total points based on all transactions
    UPDATE public.users 
    SET points = (
        SELECT COALESCE(SUM(points), 0) 
        FROM public.point_transactions 
        WHERE user_id = NEW.user_id
    ),
    updated_at = NOW()
    WHERE id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update user points when transactions are added
DROP TRIGGER IF EXISTS trigger_update_user_points ON public.point_transactions;
CREATE TRIGGER trigger_update_user_points
    AFTER INSERT ON public.point_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_points_from_transactions();

-- Create a function to update member levels based on points
CREATE OR REPLACE FUNCTION public.update_member_level()
RETURNS TRIGGER AS $$
BEGIN
    -- Update member level based on points
    UPDATE public.users
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
DROP TRIGGER IF EXISTS trigger_update_member_level ON public.users;
CREATE TRIGGER trigger_update_member_level
    AFTER UPDATE OF points ON public.users
    FOR EACH ROW
    WHEN (OLD.points IS DISTINCT FROM NEW.points)
    EXECUTE FUNCTION public.update_member_level();

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.point_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemption_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view own transactions" ON public.point_transactions;
DROP POLICY IF EXISTS "Users can view own redemptions" ON public.redemption_history;
DROP POLICY IF EXISTS "Anyone can view rewards" ON public.rewards;
DROP POLICY IF EXISTS "Anyone can view milestones" ON public.milestones;

-- Create RLS policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid()::text = id::text);

CREATE POLICY "Users can view own transactions" ON public.point_transactions
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can view own redemptions" ON public.redemption_history
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- Anyone can view rewards and milestones (public data)
CREATE POLICY "Anyone can view rewards" ON public.rewards
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view milestones" ON public.milestones
    FOR SELECT USING (true);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- Final message
SELECT 'Database schema corrected and created successfully in public schema!' as message;
