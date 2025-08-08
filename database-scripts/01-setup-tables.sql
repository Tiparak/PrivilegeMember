-- =================================================================
-- Privilege Member System - Database Setup Script
-- =================================================================
-- This script creates all tables, indexes, triggers, and sample data
-- for the Privilege Member loyalty points system
-- 
-- Prerequisites:
-- - PostgreSQL 12+ or Supabase
-- - UUID extension enabled
-- =================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =================================================================
-- DROP EXISTING OBJECTS (for clean setup)
-- =================================================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS public.redemption_history CASCADE;
DROP TABLE IF EXISTS public.point_transactions CASCADE;
DROP TABLE IF EXISTS public.rewards CASCADE;
DROP TABLE IF EXISTS public.milestones CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS public.update_user_points_from_transactions() CASCADE;
DROP FUNCTION IF EXISTS public.update_member_level() CASCADE;
DROP FUNCTION IF EXISTS public.create_user_profile(UUID, TEXT, TEXT, TEXT) CASCADE;

-- =================================================================
-- CREATE TABLES
-- =================================================================

-- Users table
CREATE TABLE public.users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(255) NOT NULL,
    points INTEGER DEFAULT 0 CHECK (points >= 0),
    member_level VARCHAR(20) DEFAULT 'bronze' CHECK (member_level IN ('bronze', 'silver', 'gold', 'platinum')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    profile_image_url TEXT,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Point transactions table
CREATE TABLE public.point_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    points INTEGER NOT NULL,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('earn', 'redeem', 'bonus', 'penalty', 'adjustment')),
    description TEXT NOT NULL,
    reference_id VARCHAR(255), -- For tracking external references (POS transactions, etc.)
    merchant_name VARCHAR(255),
    location VARCHAR(255),
    metadata JSONB, -- For storing additional transaction data
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id) -- Admin who created the transaction
);

-- Rewards table
CREATE TABLE public.rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL CHECK (points_required > 0),
    category VARCHAR(20) NOT NULL CHECK (category IN ('discount', 'product', 'voucher', 'service', 'experience')),
    image_url TEXT,
    terms_and_conditions TEXT,
    stock_quantity INTEGER, -- NULL means unlimited
    max_redemptions_per_user INTEGER DEFAULT 1,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id)
);

-- Redemption history table
CREATE TABLE public.redemption_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reward_id UUID NOT NULL REFERENCES public.rewards(id) ON DELETE CASCADE,
    points_used INTEGER NOT NULL CHECK (points_used > 0),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'completed', 'cancelled', 'expired')),
    redemption_code VARCHAR(50), -- Unique code for the redemption
    notes TEXT,
    approved_by UUID REFERENCES public.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Milestones table
CREATE TABLE public.milestones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    points_required INTEGER NOT NULL CHECK (points_required > 0),
    reward_title VARCHAR(255) NOT NULL,
    reward_description TEXT,
    reward_type VARCHAR(20) DEFAULT 'badge' CHECK (reward_type IN ('badge', 'points', 'discount', 'product', 'tier_upgrade')),
    reward_value JSONB, -- For storing reward-specific data
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    is_repeatable BOOLEAN DEFAULT false, -- Can be achieved multiple times
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id)
);

-- User milestone achievements table
CREATE TABLE public.user_milestones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    milestone_id UUID NOT NULL REFERENCES public.milestones(id) ON DELETE CASCADE,
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    points_at_achievement INTEGER,
    UNIQUE(user_id, milestone_id) -- Prevent duplicate achievements unless repeatable
);

-- System settings table
CREATE TABLE public.system_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false, -- Whether this setting can be read by non-admin users
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by UUID REFERENCES public.users(id)
);

-- =================================================================
-- CREATE INDEXES
-- =================================================================

-- Users table indexes
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_phone ON public.users(phone);
CREATE INDEX idx_users_member_level ON public.users(member_level);
CREATE INDEX idx_users_status ON public.users(status);
CREATE INDEX idx_users_created_at ON public.users(created_at);

-- Point transactions indexes
CREATE INDEX idx_point_transactions_user_id ON public.point_transactions(user_id);
CREATE INDEX idx_point_transactions_type ON public.point_transactions(transaction_type);
CREATE INDEX idx_point_transactions_created_at ON public.point_transactions(created_at);
CREATE INDEX idx_point_transactions_reference_id ON public.point_transactions(reference_id);

-- Rewards indexes
CREATE INDEX idx_rewards_category ON public.rewards(category);
CREATE INDEX idx_rewards_is_active ON public.rewards(is_active);
CREATE INDEX idx_rewards_points_required ON public.rewards(points_required);
CREATE INDEX idx_rewards_valid_dates ON public.rewards(valid_from, valid_until);

-- Redemption history indexes
CREATE INDEX idx_redemption_history_user_id ON public.redemption_history(user_id);
CREATE INDEX idx_redemption_history_reward_id ON public.redemption_history(reward_id);
CREATE INDEX idx_redemption_history_status ON public.redemption_history(status);
CREATE INDEX idx_redemption_history_created_at ON public.redemption_history(created_at);
CREATE INDEX idx_redemption_history_code ON public.redemption_history(redemption_code);

-- Milestones indexes
CREATE INDEX idx_milestones_points_required ON public.milestones(points_required);
CREATE INDEX idx_milestones_is_active ON public.milestones(is_active);
CREATE INDEX idx_milestones_sort_order ON public.milestones(sort_order);

-- User milestones indexes
CREATE INDEX idx_user_milestones_user_id ON public.user_milestones(user_id);
CREATE INDEX idx_user_milestones_milestone_id ON public.user_milestones(milestone_id);
CREATE INDEX idx_user_milestones_achieved_at ON public.user_milestones(achieved_at);

-- System settings indexes
CREATE INDEX idx_system_settings_key ON public.system_settings(setting_key);
CREATE INDEX idx_system_settings_public ON public.system_settings(is_public);

-- =================================================================
-- CREATE TRIGGERS AND FUNCTIONS
-- =================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_rewards_updated_at 
    BEFORE UPDATE ON public.rewards 
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_redemption_history_updated_at 
    BEFORE UPDATE ON public.redemption_history 
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_milestones_updated_at 
    BEFORE UPDATE ON public.milestones 
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Function to automatically update user points when transactions are added
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

-- Trigger to auto-update user points when transactions are added
CREATE TRIGGER trigger_update_user_points 
    AFTER INSERT ON public.point_transactions
    FOR EACH ROW 
    EXECUTE FUNCTION public.update_user_points_from_transactions();

-- Function to automatically update member levels based on points
CREATE OR REPLACE FUNCTION public.update_member_level()
RETURNS TRIGGER AS $$
BEGIN
    -- Update member level based on total points
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

-- Trigger to auto-update member level when points change
CREATE TRIGGER trigger_update_member_level
    AFTER UPDATE OF points ON public.users
    FOR EACH ROW
    WHEN (OLD.points IS DISTINCT FROM NEW.points)
    EXECUTE FUNCTION public.update_member_level();

-- Function to generate unique redemption codes
CREATE OR REPLACE FUNCTION public.generate_redemption_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.redemption_code IS NULL THEN
        NEW.redemption_code := 'RDM' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || UPPER(LEFT(MD5(NEW.id::TEXT), 6));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate redemption codes
CREATE TRIGGER trigger_generate_redemption_code
    BEFORE INSERT ON public.redemption_history
    FOR EACH ROW
    EXECUTE FUNCTION public.generate_redemption_code();

-- Function to check milestone achievements
CREATE OR REPLACE FUNCTION public.check_milestone_achievements()
RETURNS TRIGGER AS $$
DECLARE
    milestone_record RECORD;
BEGIN
    -- Check for new milestone achievements when user points increase
    IF TG_OP = 'UPDATE' AND NEW.points > OLD.points THEN
        FOR milestone_record IN 
            SELECT m.* 
            FROM public.milestones m
            WHERE m.is_active = true 
            AND NEW.points >= m.points_required
            AND NOT EXISTS (
                SELECT 1 FROM public.user_milestones um 
                WHERE um.user_id = NEW.id 
                AND um.milestone_id = m.id
            )
        LOOP
            -- Insert milestone achievement
            INSERT INTO public.user_milestones (user_id, milestone_id, points_at_achievement)
            VALUES (NEW.id, milestone_record.id, NEW.points);
            
            -- TODO: Add notification logic here
        END LOOP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to check milestone achievements when user points are updated
CREATE TRIGGER trigger_check_milestone_achievements
    AFTER UPDATE OF points ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.check_milestone_achievements();

-- =================================================================
-- SECURITY: ROW LEVEL SECURITY (RLS) SETUP
-- =================================================================

-- Disable RLS for now (enable in production with proper policies)
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.point_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemption_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.milestones DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_milestones DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings DISABLE ROW LEVEL SECURITY;

-- Grant permissions (adjust for your needs)
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO authenticated, anon;

-- =================================================================
-- COMPLETION MESSAGE
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Privilege Member System Database Setup Completed Successfully!';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Tables created: users, point_transactions, rewards, redemption_history, milestones, user_milestones, system_settings';
    RAISE NOTICE 'Indexes created: Performance-optimized indexes on all key columns';
    RAISE NOTICE 'Triggers created: Auto-update points, member levels, milestone achievements';
    RAISE NOTICE 'Functions created: Point calculation, level updates, milestone tracking';
    RAISE NOTICE 'Next step: Run 02-sample-data.sql to populate with sample data';
    RAISE NOTICE '=================================================================';
END $$;
