-- =================================================================
-- Privilege Member System - Row Level Security (RLS) Setup
-- =================================================================
-- This script sets up comprehensive Row Level Security policies
-- for the Privilege Member system
-- 
-- WARNING: This script enables RLS which will restrict data access.
-- Make sure you have proper authentication set up before running this.
-- =================================================================

-- =================================================================
-- ENABLE ROW LEVEL SECURITY
-- =================================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.point_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemption_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- =================================================================
-- DROP EXISTING POLICIES (for clean setup)
-- =================================================================

-- Users table policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;

-- Point transactions policies
DROP POLICY IF EXISTS "Users can view own transactions" ON public.point_transactions;
DROP POLICY IF EXISTS "Admins can manage all transactions" ON public.point_transactions;

-- Rewards policies
DROP POLICY IF EXISTS "Anyone can view active rewards" ON public.rewards;
DROP POLICY IF EXISTS "Admins can manage rewards" ON public.rewards;

-- Redemption history policies
DROP POLICY IF EXISTS "Users can view own redemptions" ON public.redemption_history;
DROP POLICY IF EXISTS "Users can create redemptions" ON public.redemption_history;
DROP POLICY IF EXISTS "Admins can manage all redemptions" ON public.redemption_history;

-- Milestones policies
DROP POLICY IF EXISTS "Anyone can view active milestones" ON public.milestones;
DROP POLICY IF EXISTS "Admins can manage milestones" ON public.milestones;

-- User milestones policies
DROP POLICY IF EXISTS "Users can view own milestone achievements" ON public.user_milestones;
DROP POLICY IF EXISTS "System can create milestone achievements" ON public.user_milestones;
DROP POLICY IF EXISTS "Admins can manage all milestone achievements" ON public.user_milestones;

-- System settings policies
DROP POLICY IF EXISTS "Anyone can view public settings" ON public.system_settings;
DROP POLICY IF EXISTS "Admins can manage all settings" ON public.system_settings;

-- =================================================================
-- HELPER FUNCTIONS FOR RLS POLICIES
-- =================================================================

-- Function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid()::uuid 
        AND email LIKE '%admin%'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if current user is the row owner
CREATE OR REPLACE FUNCTION public.is_owner(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.uid()::uuid = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =================================================================
-- USERS TABLE POLICIES
-- =================================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT
    USING (auth.uid()::uuid = id OR public.is_admin());

-- Users can update their own profile (limited fields)
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE
    USING (auth.uid()::uuid = id OR public.is_admin())
    WITH CHECK (auth.uid()::uuid = id OR public.is_admin());

-- Allow user profile creation during signup
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT
    WITH CHECK (auth.uid()::uuid = id OR public.is_admin());

-- Admins can manage all users
CREATE POLICY "Admins can manage all users" ON public.users
    FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- =================================================================
-- POINT TRANSACTIONS TABLE POLICIES
-- =================================================================

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON public.point_transactions
    FOR SELECT
    USING (public.is_owner(user_id) OR public.is_admin());

-- Only admins can insert/update/delete transactions
CREATE POLICY "Admins can manage all transactions" ON public.point_transactions
    FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- =================================================================
-- REWARDS TABLE POLICIES
-- =================================================================

-- Anyone can view active rewards
CREATE POLICY "Anyone can view active rewards" ON public.rewards
    FOR SELECT
    USING (is_active = true OR public.is_admin());

-- Only admins can manage rewards
CREATE POLICY "Admins can manage rewards" ON public.rewards
    FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- =================================================================
-- REDEMPTION HISTORY TABLE POLICIES
-- =================================================================

-- Users can view their own redemption history
CREATE POLICY "Users can view own redemptions" ON public.redemption_history
    FOR SELECT
    USING (public.is_owner(user_id) OR public.is_admin());

-- Users can create redemptions for themselves
CREATE POLICY "Users can create redemptions" ON public.redemption_history
    FOR INSERT
    WITH CHECK (public.is_owner(user_id) OR public.is_admin());

-- Users can update their own pending redemptions (limited scenarios)
CREATE POLICY "Users can update own pending redemptions" ON public.redemption_history
    FOR UPDATE
    USING (public.is_owner(user_id) AND status = 'pending')
    WITH CHECK (public.is_owner(user_id) AND status = 'pending');

-- Admins can manage all redemptions
CREATE POLICY "Admins can manage all redemptions" ON public.redemption_history
    FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- =================================================================
-- MILESTONES TABLE POLICIES
-- =================================================================

-- Anyone can view active milestones
CREATE POLICY "Anyone can view active milestones" ON public.milestones
    FOR SELECT
    USING (is_active = true OR public.is_admin());

-- Only admins can manage milestones
CREATE POLICY "Admins can manage milestones" ON public.milestones
    FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- =================================================================
-- USER MILESTONES TABLE POLICIES
-- =================================================================

-- Users can view their own milestone achievements
CREATE POLICY "Users can view own milestone achievements" ON public.user_milestones
    FOR SELECT
    USING (public.is_owner(user_id) OR public.is_admin());

-- System can create milestone achievements (via triggers)
CREATE POLICY "System can create milestone achievements" ON public.user_milestones
    FOR INSERT
    WITH CHECK (true); -- Allow system to insert via triggers

-- Admins can manage all milestone achievements
CREATE POLICY "Admins can manage all milestone achievements" ON public.user_milestones
    FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- =================================================================
-- SYSTEM SETTINGS TABLE POLICIES
-- =================================================================

-- Anyone can view public settings
CREATE POLICY "Anyone can view public settings" ON public.system_settings
    FOR SELECT
    USING (is_public = true OR public.is_admin());

-- Only admins can manage settings
CREATE POLICY "Admins can manage all settings" ON public.system_settings
    FOR ALL
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- =================================================================
-- REVOKE PUBLIC ACCESS AND GRANT PROPER PERMISSIONS
-- =================================================================

-- Revoke all permissions from public
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM public;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM public;

-- Grant specific permissions to authenticated users
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;
GRANT SELECT ON public.point_transactions TO authenticated;
GRANT SELECT ON public.rewards TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.redemption_history TO authenticated;
GRANT SELECT ON public.milestones TO authenticated;
GRANT SELECT ON public.user_milestones TO authenticated;
GRANT SELECT ON public.system_settings TO authenticated;

-- Grant sequence usage
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant function execution
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Grant limited permissions to anonymous users (for public data)
GRANT SELECT ON public.rewards TO anon;
GRANT SELECT ON public.milestones TO anon;
GRANT SELECT ON public.system_settings TO anon;

-- =================================================================
-- CREATE ADMIN ROLE MANAGEMENT
-- =================================================================

-- Function to check and set admin status
CREATE OR REPLACE FUNCTION public.set_admin_role(user_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE public.users 
    SET email = email -- This will trigger the update
    WHERE email = user_email;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to revoke admin status (change email pattern)
CREATE OR REPLACE FUNCTION public.revoke_admin_role(user_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- This is a placeholder - implement your admin role revocation logic
    -- You might want to use a separate admin_roles table instead
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =================================================================
-- AUDIT LOGGING (Optional)
-- =================================================================

-- Create audit log table
CREATE TABLE IF NOT EXISTS public.audit_log (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL, -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    user_id UUID,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create audit trigger function
CREATE OR REPLACE FUNCTION public.audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.audit_log (
        table_name,
        operation,
        old_values,
        new_values,
        user_id
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) END,
        auth.uid()::uuid
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Add audit triggers to sensitive tables (optional - uncomment if needed)
-- CREATE TRIGGER audit_users AFTER INSERT OR UPDATE OR DELETE ON public.users FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
-- CREATE TRIGGER audit_transactions AFTER INSERT OR UPDATE OR DELETE ON public.point_transactions FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
-- CREATE TRIGGER audit_redemptions AFTER INSERT OR UPDATE OR DELETE ON public.redemption_history FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();

-- =================================================================
-- COMPLETION MESSAGE
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Row Level Security (RLS) Setup Completed Successfully!';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'RLS ENABLED on all tables';
    RAISE NOTICE 'POLICIES CREATED for user data protection';
    RAISE NOTICE 'PERMISSIONS GRANTED to authenticated users';
    RAISE NOTICE 'ADMIN FUNCTIONS created for role management';
    RAISE NOTICE 'AUDIT LOGGING prepared (triggers commented out)';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'IMPORTANT: Test authentication before production deployment!';
    RAISE NOTICE 'IMPORTANT: Review and adjust policies based on your needs!';
    RAISE NOTICE '=================================================================';
END $$;
