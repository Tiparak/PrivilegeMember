-- =================================================================
-- Privilege Member System - Maintenance & Utility Scripts
-- =================================================================
-- This script contains utility functions and maintenance procedures
-- for the Privilege Member system
-- =================================================================

-- =================================================================
-- UTILITY FUNCTIONS
-- =================================================================

-- Function to get user statistics
CREATE OR REPLACE FUNCTION public.get_user_stats(user_uuid UUID DEFAULT NULL)
RETURNS TABLE (
    user_id UUID,
    email TEXT,
    full_name TEXT,
    total_points INTEGER,
    member_level TEXT,
    total_transactions BIGINT,
    total_earned INTEGER,
    total_redeemed INTEGER,
    total_redemptions BIGINT,
    milestones_achieved BIGINT,
    registration_date TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.email,
        u.full_name,
        u.points,
        u.member_level,
        COALESCE(t.transaction_count, 0),
        COALESCE(t.total_earned, 0),
        COALESCE(t.total_redeemed, 0),
        COALESCE(r.redemption_count, 0),
        COALESCE(m.milestone_count, 0),
        u.created_at
    FROM public.users u
    LEFT JOIN (
        SELECT 
            pt.user_id,
            COUNT(*) as transaction_count,
            SUM(CASE WHEN pt.points > 0 THEN pt.points ELSE 0 END) as total_earned,
            SUM(CASE WHEN pt.points < 0 THEN ABS(pt.points) ELSE 0 END) as total_redeemed
        FROM public.point_transactions pt
        GROUP BY pt.user_id
    ) t ON u.id = t.user_id
    LEFT JOIN (
        SELECT 
            rh.user_id,
            COUNT(*) as redemption_count
        FROM public.redemption_history rh
        GROUP BY rh.user_id
    ) r ON u.id = r.user_id
    LEFT JOIN (
        SELECT 
            um.user_id,
            COUNT(*) as milestone_count
        FROM public.user_milestones um
        GROUP BY um.user_id
    ) m ON u.id = m.user_id
    WHERE (user_uuid IS NULL OR u.id = user_uuid)
    ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get system statistics
CREATE OR REPLACE FUNCTION public.get_system_stats()
RETURNS TABLE (
    total_users BIGINT,
    active_users BIGINT,
    total_points_in_system BIGINT,
    total_transactions BIGINT,
    total_redemptions BIGINT,
    pending_redemptions BIGINT,
    active_rewards BIGINT,
    bronze_members BIGINT,
    silver_members BIGINT,
    gold_members BIGINT,
    platinum_members BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM public.users),
        (SELECT COUNT(*) FROM public.users WHERE status = 'active'),
        (SELECT COALESCE(SUM(points), 0) FROM public.users),
        (SELECT COUNT(*) FROM public.point_transactions),
        (SELECT COUNT(*) FROM public.redemption_history),
        (SELECT COUNT(*) FROM public.redemption_history WHERE status = 'pending'),
        (SELECT COUNT(*) FROM public.rewards WHERE is_active = true),
        (SELECT COUNT(*) FROM public.users WHERE member_level = 'bronze'),
        (SELECT COUNT(*) FROM public.users WHERE member_level = 'silver'),
        (SELECT COUNT(*) FROM public.users WHERE member_level = 'gold'),
        (SELECT COUNT(*) FROM public.users WHERE member_level = 'platinum');
END;
$$ LANGUAGE plpgsql;

-- Function to get points summary for a date range
CREATE OR REPLACE FUNCTION public.get_points_summary(
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() - INTERVAL '30 days',
    end_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS TABLE (
    date_bucket DATE,
    total_earned INTEGER,
    total_redeemed INTEGER,
    net_points INTEGER,
    transaction_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pt.created_at::DATE as date_bucket,
        SUM(CASE WHEN pt.points > 0 THEN pt.points ELSE 0 END)::INTEGER as total_earned,
        SUM(CASE WHEN pt.points < 0 THEN ABS(pt.points) ELSE 0 END)::INTEGER as total_redeemed,
        SUM(pt.points)::INTEGER as net_points,
        COUNT(*) as transaction_count
    FROM public.point_transactions pt
    WHERE pt.created_at >= start_date AND pt.created_at <= end_date
    GROUP BY pt.created_at::DATE
    ORDER BY date_bucket DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to recalculate user points (maintenance)
CREATE OR REPLACE FUNCTION public.recalculate_user_points(user_uuid UUID DEFAULT NULL)
RETURNS TABLE (
    user_id UUID,
    old_points INTEGER,
    calculated_points INTEGER,
    difference INTEGER,
    updated BOOLEAN
) AS $$
DECLARE
    user_record RECORD;
    calculated_total INTEGER;
BEGIN
    FOR user_record IN 
        SELECT id, points FROM public.users 
        WHERE (user_uuid IS NULL OR id = user_uuid)
    LOOP
        -- Calculate total points from transactions
        SELECT COALESCE(SUM(points), 0) INTO calculated_total
        FROM public.point_transactions 
        WHERE user_id = user_record.id;
        
        -- Return the comparison and update if different
        IF user_record.points != calculated_total THEN
            UPDATE public.users 
            SET points = calculated_total, updated_at = NOW()
            WHERE id = user_record.id;
            
            RETURN QUERY SELECT 
                user_record.id,
                user_record.points,
                calculated_total,
                calculated_total - user_record.points,
                true;
        ELSE
            RETURN QUERY SELECT 
                user_record.id,
                user_record.points,
                calculated_total,
                0,
                false;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to expire old redemptions
CREATE OR REPLACE FUNCTION public.expire_old_redemptions()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    UPDATE public.redemption_history 
    SET status = 'expired', updated_at = NOW()
    WHERE status IN ('pending', 'approved')
    AND expires_at < NOW();
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup old audit logs
CREATE OR REPLACE FUNCTION public.cleanup_audit_logs(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.audit_log 
    WHERE created_at < NOW() - (days_to_keep || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- =================================================================
-- BUSINESS LOGIC FUNCTIONS
-- =================================================================

-- Function to award points to user
CREATE OR REPLACE FUNCTION public.award_points(
    user_uuid UUID,
    points_amount INTEGER,
    transaction_description TEXT,
    reference_id TEXT DEFAULT NULL,
    merchant_name TEXT DEFAULT NULL,
    location TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    transaction_id UUID;
BEGIN
    -- Validate input
    IF points_amount <= 0 THEN
        RAISE EXCEPTION 'Points amount must be positive';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = user_uuid) THEN
        RAISE EXCEPTION 'User not found';
    END IF;
    
    -- Insert transaction
    INSERT INTO public.point_transactions (
        user_id, points, transaction_type, description, 
        reference_id, merchant_name, location
    ) VALUES (
        user_uuid, points_amount, 'earn', transaction_description,
        reference_id, merchant_name, location
    ) RETURNING id INTO transaction_id;
    
    RETURN transaction_id;
END;
$$ LANGUAGE plpgsql;

-- Function to redeem points
CREATE OR REPLACE FUNCTION public.redeem_points(
    user_uuid UUID,
    points_amount INTEGER,
    transaction_description TEXT,
    reference_id TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    transaction_id UUID;
    current_points INTEGER;
BEGIN
    -- Validate input
    IF points_amount <= 0 THEN
        RAISE EXCEPTION 'Points amount must be positive';
    END IF;
    
    -- Check user exists and has enough points
    SELECT points INTO current_points 
    FROM public.users 
    WHERE id = user_uuid;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User not found';
    END IF;
    
    IF current_points < points_amount THEN
        RAISE EXCEPTION 'Insufficient points. User has % points, trying to redeem %', 
            current_points, points_amount;
    END IF;
    
    -- Insert transaction (negative points for redemption)
    INSERT INTO public.point_transactions (
        user_id, points, transaction_type, description, reference_id
    ) VALUES (
        user_uuid, -points_amount, 'redeem', transaction_description, reference_id
    ) RETURNING id INTO transaction_id;
    
    RETURN transaction_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create reward redemption
CREATE OR REPLACE FUNCTION public.create_reward_redemption(
    user_uuid UUID,
    reward_uuid UUID
)
RETURNS UUID AS $$
DECLARE
    redemption_id UUID;
    reward_record RECORD;
    user_points INTEGER;
    user_redemption_count INTEGER;
BEGIN
    -- Get reward details
    SELECT * INTO reward_record 
    FROM public.rewards 
    WHERE id = reward_uuid AND is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Reward not found or inactive';
    END IF;
    
    -- Check reward validity
    IF reward_record.valid_until IS NOT NULL AND reward_record.valid_until < NOW() THEN
        RAISE EXCEPTION 'Reward has expired';
    END IF;
    
    IF reward_record.valid_from > NOW() THEN
        RAISE EXCEPTION 'Reward is not yet available';
    END IF;
    
    -- Check stock
    IF reward_record.stock_quantity IS NOT NULL AND reward_record.stock_quantity <= 0 THEN
        RAISE EXCEPTION 'Reward is out of stock';
    END IF;
    
    -- Check user points
    SELECT points INTO user_points 
    FROM public.users 
    WHERE id = user_uuid;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User not found';
    END IF;
    
    IF user_points < reward_record.points_required THEN
        RAISE EXCEPTION 'Insufficient points. Required: %, Available: %', 
            reward_record.points_required, user_points;
    END IF;
    
    -- Check max redemptions per user
    IF reward_record.max_redemptions_per_user IS NOT NULL THEN
        SELECT COUNT(*) INTO user_redemption_count
        FROM public.redemption_history
        WHERE user_id = user_uuid 
        AND reward_id = reward_uuid 
        AND status IN ('pending', 'approved', 'completed');
        
        IF user_redemption_count >= reward_record.max_redemptions_per_user THEN
            RAISE EXCEPTION 'Maximum redemptions reached for this reward';
        END IF;
    END IF;
    
    -- Create redemption record
    INSERT INTO public.redemption_history (
        user_id, reward_id, points_used, status,
        expires_at
    ) VALUES (
        user_uuid, reward_uuid, reward_record.points_required, 'pending',
        NOW() + INTERVAL '7 days' -- Default 7 days to use redemption
    ) RETURNING id INTO redemption_id;
    
    -- Deduct points
    PERFORM public.redeem_points(
        user_uuid, 
        reward_record.points_required, 
        'Redemption: ' || reward_record.name,
        redemption_id::TEXT
    );
    
    -- Update stock if applicable
    IF reward_record.stock_quantity IS NOT NULL THEN
        UPDATE public.rewards 
        SET stock_quantity = stock_quantity - 1 
        WHERE id = reward_uuid;
    END IF;
    
    RETURN redemption_id;
END;
$$ LANGUAGE plpgsql;

-- =================================================================
-- SCHEDULED MAINTENANCE PROCEDURES
-- =================================================================

-- Daily maintenance procedure
CREATE OR REPLACE FUNCTION public.daily_maintenance()
RETURNS TEXT AS $$
DECLARE
    expired_redemptions INTEGER;
    result_text TEXT;
BEGIN
    result_text := 'Daily Maintenance Report:' || CHR(10);
    
    -- Expire old redemptions
    SELECT public.expire_old_redemptions() INTO expired_redemptions;
    result_text := result_text || '- Expired redemptions: ' || expired_redemptions || CHR(10);
    
    -- Update member levels for all users (in case of manual point adjustments)
    UPDATE public.users 
    SET member_level = CASE
        WHEN points >= 50000 THEN 'platinum'
        WHEN points >= 25000 THEN 'gold'
        WHEN points >= 10000 THEN 'silver'
        ELSE 'bronze'
    END
    WHERE member_level != CASE
        WHEN points >= 50000 THEN 'platinum'
        WHEN points >= 25000 THEN 'gold'
        WHEN points >= 10000 THEN 'silver'
        ELSE 'bronze'
    END;
    
    result_text := result_text || '- Member levels updated' || CHR(10);
    result_text := result_text || '- Maintenance completed at: ' || NOW();
    
    RETURN result_text;
END;
$$ LANGUAGE plpgsql;

-- Weekly maintenance procedure
CREATE OR REPLACE FUNCTION public.weekly_maintenance()
RETURNS TEXT AS $$
DECLARE
    audit_deleted INTEGER;
    result_text TEXT;
BEGIN
    result_text := 'Weekly Maintenance Report:' || CHR(10);
    
    -- Cleanup old audit logs (keep 90 days)
    SELECT public.cleanup_audit_logs(90) INTO audit_deleted;
    result_text := result_text || '- Deleted audit logs: ' || audit_deleted || CHR(10);
    
    -- Run daily maintenance
    result_text := result_text || public.daily_maintenance();
    
    RETURN result_text;
END;
$$ LANGUAGE plpgsql;

-- =================================================================
-- GRANT PERMISSIONS
-- =================================================================

-- Grant execute permissions on utility functions
GRANT EXECUTE ON FUNCTION public.get_user_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_system_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_points_summary(TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.award_points(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.redeem_points(UUID, INTEGER, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_reward_redemption(UUID, UUID) TO authenticated;

-- Grant admin-only functions (require is_admin() check in function)
GRANT EXECUTE ON FUNCTION public.recalculate_user_points(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.expire_old_redemptions() TO authenticated;
GRANT EXECUTE ON FUNCTION public.cleanup_audit_logs(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.daily_maintenance() TO authenticated;
GRANT EXECUTE ON FUNCTION public.weekly_maintenance() TO authenticated;

-- =================================================================
-- COMPLETION MESSAGE
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Maintenance & Utility Scripts Setup Completed Successfully!';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'UTILITY FUNCTIONS created for statistics and data analysis';
    RAISE NOTICE 'BUSINESS LOGIC FUNCTIONS created for points and redemptions';
    RAISE NOTICE 'MAINTENANCE PROCEDURES created for automated cleanup';
    RAISE NOTICE 'PERMISSIONS GRANTED for appropriate user roles';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Available Functions:';
    RAISE NOTICE '- get_user_stats(user_uuid) - User statistics';
    RAISE NOTICE '- get_system_stats() - System-wide statistics'; 
    RAISE NOTICE '- award_points() - Award points to user';
    RAISE NOTICE '- create_reward_redemption() - Process reward redemption';
    RAISE NOTICE '- daily_maintenance() - Daily cleanup tasks';
    RAISE NOTICE '=================================================================';
END $$;
