-- =================================================================
-- Privilege Member System - Sample Data Script
-- =================================================================
-- This script populates the database with sample data for testing
-- and demonstration purposes
-- =================================================================

-- Clear existing data (in dependency order)
TRUNCATE public.user_milestones CASCADE;
TRUNCATE public.redemption_history CASCADE;
TRUNCATE public.point_transactions CASCADE;
TRUNCATE public.rewards CASCADE;
TRUNCATE public.milestones CASCADE;
TRUNCATE public.users CASCADE;
TRUNCATE public.system_settings CASCADE;

-- =================================================================
-- SYSTEM SETTINGS
-- =================================================================

INSERT INTO public.system_settings (setting_key, setting_value, description, is_public) VALUES
('app_name', '"Privilege Member"', 'Application name', true),
('point_exchange_rate', '{"thb_per_point": 0.01, "points_per_thb": 100}', 'Point to currency exchange rate', true),
('member_level_thresholds', '{"bronze": 0, "silver": 10000, "gold": 25000, "platinum": 50000}', 'Points required for each member level', true),
('welcome_bonus_points', '1000', 'Points awarded to new members', false),
('max_points_per_transaction', '10000', 'Maximum points that can be earned in a single transaction', false),
('point_expiry_months', '24', 'Number of months before points expire (0 = never expire)', true),
('redemption_approval_required', 'true', 'Whether redemptions require admin approval', false),
('maintenance_mode', 'false', 'Whether the system is in maintenance mode', true);

-- =================================================================
-- SAMPLE USERS
-- =================================================================

INSERT INTO public.users (id, email, phone, full_name, points, member_level, status, date_of_birth, gender, city) VALUES
-- Admin user
('11111111-1111-1111-1111-111111111111', 'admin@privilegemember.co.th', '02-123-4567', 'ผู้ดูแลระบบ', 0, 'platinum', 'active', '1990-01-01', 'other', 'กรุงเทพฯ'),

-- Regular users
('22222222-2222-2222-2222-222222222222', 'premium.user1@example.com', '081-234-5678', 'Premium User1', 12500, 'gold', 'active', '1985-05-15', 'male', 'กรุงเทพฯ'),
('33333333-3333-3333-3333-333333333333', 'somchai@example.com', '089-123-4567', 'สมชาย ใจดี', 7850, 'silver', 'active', '1992-08-20', 'male', 'เชียงใหม่'),
('44444444-4444-4444-4444-444444444444', 'malee@example.com', '092-345-6789', 'นางสาวมาลี มีเงิน', 3200, 'bronze', 'active', '1995-12-10', 'female', 'ภูเก็ต'),
('55555555-5555-5555-5555-555555555555', 'john.doe@example.com', '088-567-8901', 'John Doe', 28500, 'gold', 'active', '1988-03-25', 'male', 'กรุงเทพฯ'),
('66666666-6666-6666-6666-666666666666', 'jane.smith@example.com', '087-678-9012', 'Jane Smith', 55000, 'platinum', 'active', '1990-07-14', 'female', 'กรุงเทพฯ'),
('77777777-7777-7777-7777-777777777777', 'test.user@example.com', '086-789-0123', 'ทดสอบ ระบบ', 500, 'bronze', 'active', '2000-01-01', 'other', 'นนทบุรี');

-- =================================================================
-- MILESTONES
-- =================================================================

INSERT INTO public.milestones (id, points_required, reward_title, reward_description, reward_type, reward_value, is_active, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1000, 'สมาชิกใหม่', 'รับส่วนลด 5% สำหรับการซื้อครั้งถัดไป', 'discount', '{"discount_percentage": 5, "max_discount": 500}', true, 1),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 5000, 'สมาชิกเงิน', 'รับของพรีเมียมพิเศษจากร้าน + ส่วนลด 7%', 'product', '{"product_category": "premium", "discount_percentage": 7}', true, 2),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 10000, 'สมาชิกทอง', 'รับส่วนลด 15% และสิทธิพิเศษต่างๆ', 'discount', '{"discount_percentage": 15, "max_discount": 2000, "special_privileges": true}', true, 3),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 25000, 'สมาชิก VIP', 'รับสิทธิ VIP และผลประโยชน์พิเศษ + ส่วนลด 20%', 'tier_upgrade', '{"new_tier": "gold", "discount_percentage": 20, "vip_privileges": true}', true, 4),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 50000, 'สมาชิกแพลทินั่ม', 'เลื่อนขั้นเป็นสมาชิกแพลทินั่ม + สิท���ิพิเศษสูงสุด', 'tier_upgrade', '{"new_tier": "platinum", "discount_percentage": 25, "platinum_privileges": true}', true, 5),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 100000, 'ผู้สะสมชั้นยอด', 'รางวัลพิเศษสำหรับผู้สะสมคะแนนสูงสุด', 'product', '{"special_reward": true, "value": 10000}', true, 6);

-- =================================================================
-- REWARDS
-- =================================================================

INSERT INTO public.rewards (id, name, description, points_required, category, terms_and_conditions, stock_quantity, max_redemptions_per_user, valid_until, is_active, sort_order) VALUES
-- Discount rewards
('r1111111-1111-1111-1111-111111111111', 'คูปองส่วนลด 10%', 'ใช้ได้กับสินค้าทุกประเภท ยกเว้นสินค้าลดราคา', 500, 'discount', 'ใช้ได้ภายใน 30 วันหลังจากแลก | ใช้ได้ครั้งละ 1 รายการ | ไม่สามารถใช้ร่วมกับโปรโมชั่นอื่นได้', NULL, 3, NOW() + INTERVAL '1 year', true, 1),
('r2222222-2222-2222-2222-222222222222', 'ส่วนลด 20%', 'ส่วนลดพิเศษสำหรับสมาชิก สูงสุด 1,000 บาท', 2000, 'discount', 'ใช้ได้ภายใน 30 วันหลังจากแลก | ส่วนลดสูงสุด 1,000 บาท | ใช้ได้กับสินค้าราคาปกติเท่านั้น', NULL, 2, NOW() + INTERVAL '1 year', true, 2),
('r3333333-3333-3333-3333-333333333333', 'ส่วนลด 30%', 'ส่วนลดสูงสุดสำหรับสมาชิก VIP', 3000, 'discount', 'ใช้ได้ภายใน 45 วันหลังจากแลก | ส่วนลดสูงสุด 2,000 บาท | สำหรับสมาชิก Gold ขึ้นไป', NULL, 2, NOW() + INTERVAL '1 year', true, 3),

-- Product rewards
('r4444444-4444-4444-4444-444444444444', 'กระเป๋าผ้า Premium', 'กระเป๋าผ้าคุณภาพสูง ดีไซน์เก๋ไก๋', 1200, 'product', 'รับได้ที่หน้าร้าน | แสดงรหัสแลกรางวัลเพื่อรับของ | สินค้าอาจแตกต่างจากภาพ', 100, 1, NOW() + INTERVAL '6 months', true, 4),
('r5555555-5555-5555-5555-555555555555', 'แก้วน้ำสแตนเลส', 'แก้วน้ำสแตนเลส ความจุ 500ml ลาย Privilege Member', 800, 'product', 'รับได้ที่หน้าร้าน | แสดงรหัสแลกรางวัลเพื่อรับของ | รับประกันคุณภาพ 1 ปี', 200, 1, NOW() + INTERVAL '6 months', true, 5),
('r6666666-6666-6666-6666-666666666666', 'หูฟังบลูทูธ', 'หูฟังไร้สายคุณภาพสูง รองรับ Bluetooth 5.0', 3500, 'product', 'รับได้ที่หน้าร้าน | รับประกัน 6 เดือน | ตรวจสอบความเข้ากันได้ก่อนแลก', 50, 1, NOW() + INTERVAL '3 months', true, 6),

-- Voucher rewards
('r7777777-7777-7777-7777-777777777777', 'บัตรกำนัล 500 บาท', 'บัตรกำนัลช้อปปิ้ง มูลค่า 500 บาท', 2500, 'voucher', 'ใช้ได้ภายใน 90 วันหลังจากแลก | ใช้ได้กับสินค้าทุกประเภท | ไม่สามารถเปลี่ยนเป็นเงินสดได้', NULL, 5, NOW() + INTERVAL '1 year', true, 7),
('r8888888-8888-8888-8888-888888888888', 'บัตรกำนัล 1,000 บาท', 'บัตรกำนัลช้อปปิ้ง มูลค่า 1,000 บาท', 5000, 'voucher', 'ใช้ได้ภายใน 90 วันหลังจากแลก | ใช้ได้กับสินค้าทุกประเภท | ไม่สามารถเปลี่ยนเป็นเงินสดได้', NULL, 3, NOW() + INTERVAL '1 year', true, 8),
('r9999999-9999-9999-9999-999999999999', 'คูปองส่วนลด 50%', 'ส่วนลดสูงสุดสำหรับสมาชิก Platinum', 7500, 'discount', 'ใช้ได้ภายใน 60 วันหลังจากแลก | ส่วนลดสูงสุด 3,000 บาท | สำหรับสมาชิก Platinum เท่านั้น', NULL, 1, NOW() + INTERVAL '1 year', true, 9),

-- Service rewards
('ra111111-1111-1111-1111-111111111111', 'บริการจัดส่งฟรี', 'บริการจัดส่งสินค้าฟรี 3 ครั้ง', 1500, 'service', 'ใช้ได้ภายใน 6 เดือน | ส่งฟรีทั่วประเทศ | จำกัดน้ำหนักไม่เกิน 5 kg ต่���ครั้ง', NULL, 10, NOW() + INTERVAL '1 year', true, 10);

-- =================================================================
-- POINT TRANSACTIONS
-- =================================================================

-- Premium User1 transactions
INSERT INTO public.point_transactions (user_id, points, transaction_type, description, reference_id, merchant_name, location, created_at) VALUES
('22222222-2222-2222-2222-222222222222', 1000, 'bonus', 'โบนัสสมาชิกใหม่', 'WELCOME-001', 'Privilege Member', 'Online', '2024-01-08 10:00:00+07'),
('22222222-2222-2222-2222-222222222222', 220, 'earn', 'ซื้อสินค้า - Terminal 21', 'POS-T21-001', 'Shop A', 'Terminal 21', '2024-01-10 14:30:00+07'),
('22222222-2222-2222-2222-222222222222', -500, 'redeem', 'แลกคูปองส่วนลด 10%', 'RDM-001', 'Privilege Member', 'Online', '2024-01-12 16:45:00+07'),
('22222222-2222-2222-2222-222222222222', 150, 'earn', 'ซื้อสินค้า - Central Plaza', 'POS-CP-001', 'Shop B', 'Central Plaza', '2024-01-15 11:20:00+07'),
('22222222-2222-2222-2222-222222222222', 300, 'earn', 'ซื้อสินค้า - Siam Paragon', 'POS-SP-001', 'Shop C', 'Siam Paragon', '2024-01-18 15:10:00+07'),
('22222222-2222-2222-2222-222222222222', 180, 'earn', 'ซื้���สินค้า - EmQuartier', 'POS-EQ-001', 'Shop D', 'EmQuartier', '2024-01-20 13:25:00+07'),
('22222222-2222-2222-2222-222222222222', 250, 'earn', 'ซื้อสินค้า - ICONSIAM', 'POS-IC-001', 'Shop E', 'ICONSIAM', '2024-01-22 17:30:00+07'),
('22222222-2222-2222-2222-222222222222', 500, 'bonus', 'โบนัสวันเกิด', 'BIRTHDAY-001', 'Privilege Member', 'Online', '2024-01-25 09:00:00+07'),
('22222222-2222-2222-2222-222222222222', 11400, 'earn', 'ซื้อสินค้า - Big C', 'POS-BC-001', 'Big C Supercenter', 'Big C Rajdamri', '2024-01-28 20:15:00+07');

-- สมชาย ใจดี transactions
INSERT INTO public.point_transactions (user_id, points, transaction_type, description, reference_id, merchant_name, location, created_at) VALUES
('33333333-3333-3333-3333-333333333333', 1000, 'bonus', 'โบนัสสมาชิกใหม่', 'WELCOME-002', 'Privilege Member', 'Online', '2024-01-05 09:00:00+07'),
('33333333-3333-3333-3333-333333333333', 300, 'earn', 'ซื้อสินค้า - Central World', 'POS-CW-001', 'Shop F', 'Central World', '2024-01-07 12:15:00+07'),
('33333333-3333-3333-3333-333333333333', 450, 'earn', 'ซื้อสินค้า - MBK Center', 'POS-MBK-001', 'Shop G', 'MBK Center', '2024-01-09 14:20:00+07'),
('33333333-3333-3333-3333-333333333333', -800, 'redeem', 'แลกแก้วน้ำสแตนเลส', 'RDM-002', 'Privilege Member', 'Online', '2024-01-11 10:30:00+07'),
('33333333-3333-3333-3333-333333333333', 200, 'earn', 'ซื้อสินค้า - Chatuchak', 'POS-JJ-001', 'Shop H', 'Chatuchak Market', '2024-01-14 16:45:00+07'),
('33333333-3333-3333-3333-333333333333', 350, 'earn', 'ซื้อสินค้า - Gateway', 'POS-GW-001', 'Shop I', 'Gateway Ekkamai', '2024-01-16 11:00:00+07'),
('33333333-3333-3333-3333-333333333333', 180, 'earn', 'ซื้อสินค้า - Future Park', 'POS-FP-001', 'Shop J', 'Future Park', '2024-01-19 15:30:00+07'),
('33333333-3333-3333-3333-333333333333', 6970, 'earn', 'ซื้อสินค้า - Lotus', 'POS-LT-001', 'Lotus Supercenter', 'Lotus Bang Khae', '2024-01-25 18:20:00+07');

-- Other users' transactions
INSERT INTO public.point_transactions (user_id, points, transaction_type, description, reference_id, merchant_name, location, created_at) VALUES
-- มาลี มีเงิน
('44444444-4444-4444-4444-444444444444', 1000, 'bonus', 'โบนัสสมาชิกใหม่', 'WELCOME-003', 'Privilege Member', 'Online', '2024-01-10 10:00:00+07'),
('44444444-4444-4444-4444-444444444444', 800, 'earn', 'ซื้อสินค้า - Central Phuket', 'POS-CPK-001', 'Shop K', 'Central Phuket', '2024-01-12 15:30:00+07'),
('44444444-4444-4444-4444-444444444444', 1400, 'earn', 'ซื้อสินค้า - Jungceylon', 'POS-JC-001', 'Shop L', 'Jungceylon Patong', '2024-01-15 19:45:00+07'),

-- John Doe
('55555555-5555-5555-5555-555555555555', 1000, 'bonus', 'โบนัสสมาชิกใหม่', 'WELCOME-004', 'Privilege Member', 'Online', '2024-01-03 08:30:00+07'),
('55555555-5555-5555-5555-555555555555', 12000, 'earn', 'ซื้อสินค้า - Paragon Department Store', 'POS-PDS-001', 'Paragon Department Store', 'Siam Paragon', '2024-01-05 16:20:00+07'),
('55555555-5555-5555-5555-555555555555', 15500, 'earn', 'ซื้อสินค้า - EmQuartier Luxury', 'POS-EQL-001', 'Luxury Boutique', 'EmQuartier', '2024-01-20 14:10:00+07'),

-- Jane Smith
('66666666-6666-6666-6666-666666666666', 1000, 'bonus', 'โบนัสสมาชิกใหม่', 'WELCOME-005', 'Privilege Member', 'Online', '2024-01-01 12:00:00+07'),
('66666666-6666-6666-6666-666666666666', 25000, 'earn', 'ซื้อสินค้า - High-end Shopping', 'POS-HES-001', 'Premium Store', 'Central Embassy', '2024-01-15 17:30:00+07'),
('66666666-6666-6666-6666-666666666666', 29000, 'earn', 'ซื้อสินค้า - Luxury Purchase', 'POS-LP-001', 'Luxury Brand Store', 'Gaysorn Village', '2024-01-25 19:45:00+07');

-- =================================================================
-- REDEMPTION HISTORY
-- =================================================================

INSERT INTO public.redemption_history (id, user_id, reward_id, points_used, status, redemption_code, notes, approved_at, completed_at, created_at) VALUES
('rd111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'r1111111-1111-1111-1111-111111111111', 500, 'completed', 'RDM20240112-ABC123', 'ใช้แล้วเมื่อ 2024-01-15', '2024-01-12 17:00:00+07', '2024-01-15 14:30:00+07', '2024-01-12 16:45:00+07'),
('rd222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'r5555555-5555-5555-5555-555555555555', 800, 'completed', 'RDM20240111-DEF456', 'รับของแล้วเมื่อ 2024-01-12', '2024-01-11 11:00:00+07', '2024-01-12 15:20:00+07', '2024-01-11 10:30:00+07'),
('rd333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', 'r1111111-1111-1111-1111-111111111111', 500, 'pending', 'RDM20240125-GHI789', 'รออนุมัติ', NULL, NULL, '2024-01-25 16:20:00+07'),
('rd444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555555', 'r2222222-2222-2222-2222-222222222222', 2000, 'approved', 'RDM20240126-JKL012', 'อนุมัติแล้ว รอใช้งาน', '2024-01-26 10:30:00+07', NULL, '2024-01-26 09:15:00+07'),
('rd555555-5555-5555-5555-555555555555', '66666666-6666-6666-6666-666666666666', 'r8888888-8888-8888-8888-888888888888', 5000, 'completed', 'RDM20240120-MNO345', 'ใช้แล้วเมื่อ 2024-01-22', '2024-01-20 14:00:00+07', '2024-01-22 11:45:00+07', '2024-01-20 13:30:00+07');

-- =================================================================
-- USER MILESTONES ACHIEVEMENTS
-- =================================================================

INSERT INTO public.user_milestones (user_id, milestone_id, achieved_at, points_at_achievement) VALUES
-- Premium User1 achievements
('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2024-01-10 15:00:00+07', 1220),
('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2024-01-18 16:00:00+07', 5170),
('22222222-2222-2222-2222-222222222222', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '2024-01-28 21:00:00+07', 10420),

-- สมชาย ใจดี achievements  
('33333333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2024-01-09 15:00:00+07', 1750),
('33333333-3333-3333-3333-333333333333', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2024-01-25 19:00:00+07', 7850),

-- มาลี มีเงิน achievements
('44444444-4444-4444-4444-444444444444', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2024-01-12 16:00:00+07', 1800),

-- John Doe achievements
('55555555-5555-5555-5555-555555555555', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2024-01-05 17:00:00+07', 13000),
('55555555-5555-5555-5555-555555555555', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2024-01-05 17:00:00+07', 13000),
('55555555-5555-5555-5555-555555555555', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '2024-01-05 17:00:00+07', 13000),
('55555555-5555-5555-5555-555555555555', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '2024-01-20 15:00:00+07', 28500),

-- Jane Smith achievements
('66666666-6666-6666-6666-666666666666', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2024-01-15 18:00:00+07', 26000),
('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2024-01-15 18:00:00+07', 26000),
('66666666-6666-6666-6666-666666666666', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '2024-01-15 18:00:00+07', 26000),
('66666666-6666-6666-6666-666666666666', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '2024-01-15 18:00:00+07', 26000),
('66666666-6666-6666-6666-666666666666', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '2024-01-25 20:00:00+07', 55000);

-- =================================================================
-- COMPLETION MESSAGE
-- =================================================================

DO $$
DECLARE
    user_count INTEGER;
    transaction_count INTEGER;
    reward_count INTEGER;
    milestone_count INTEGER;
    redemption_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM public.users;
    SELECT COUNT(*) INTO transaction_count FROM public.point_transactions;
    SELECT COUNT(*) INTO reward_count FROM public.rewards;
    SELECT COUNT(*) INTO milestone_count FROM public.milestones;
    SELECT COUNT(*) INTO redemption_count FROM public.redemption_history;
    
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Sample Data Import Completed Successfully!';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Users created: % (including 1 admin)', user_count;
    RAISE NOTICE 'Point transactions: %', transaction_count;
    RAISE NOTICE 'Rewards available: %', reward_count;
    RAISE NOTICE 'Milestones configured: %', milestone_count;
    RAISE NOTICE 'Redemption records: %', redemption_count;
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Test Accounts:';
    RAISE NOTICE 'Admin: admin@privilegemember.co.th';
    RAISE NOTICE 'Premium User1: premium.user1@example.com (12,500 points, Gold)';
    RAISE NOTICE 'สมชาย ใจดี: somchai@example.com (7,850 points, Silver)';
    RAISE NOTICE 'Jane Smith: jane.smith@example.com (55,000 points, Platinum)';
    RAISE NOTICE '=================================================================';
END $$;
