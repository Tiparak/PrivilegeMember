-- =================================================================
-- Privilege Member System - Master Deployment Script
-- =================================================================
-- This script deploys the complete Privilege Member database system
-- including tables, sample data, security, and utilities
-- 
-- IMPORTANT: Review each section before running in production!
-- =================================================================

-- Set session variables for consistent deployment
SET timezone = 'Asia/Bangkok';
SET statement_timeout = '5min';

-- =================================================================
-- DEPLOYMENT INFORMATION
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'PRIVILEGE MEMBER SYSTEM - COMPLETE DATABASE DEPLOYMENT';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Deployment started at: %', NOW();
    RAISE NOTICE 'Timezone: %', current_setting('timezone');
    RAISE NOTICE 'PostgreSQL Version: %', version();
    RAISE NOTICE '=================================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'This deployment will:';
    RAISE NOTICE '1. Create all database tables and indexes';
    RAISE NOTICE '2. Set up triggers and functions';
    RAISE NOTICE '3. Insert sample data for testing';
    RAISE NOTICE '4. Configure security (RLS disabled by default)';
    RAISE NOTICE '5. Add utility and maintenance functions';
    RAISE NOTICE '';
    RAISE NOTICE 'Estimated time: 2-5 minutes';
    RAISE NOTICE '=================================================================';
END $$;

-- =================================================================
-- STEP 1: CREATE TABLES AND BASIC STRUCTURE
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '>>> STEP 1: Creating tables and indexes...';
END $$;

-- Run the table creation script
\i database-scripts/01-setup-tables.sql

-- =================================================================
-- STEP 2: INSERT SAMPLE DATA
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '>>> STEP 2: Inserting sample data...';
END $$;

-- Run the sample data script
\i database-scripts/02-sample-data.sql

-- =================================================================
-- STEP 3: SETUP SECURITY (OPTIONAL - COMMENTED OUT BY DEFAULT)
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '>>> STEP 3: Security setup (SKIPPED - enable manually if needed)';
    RAISE NOTICE 'To enable Row Level Security, run: database-scripts/03-security-rls.sql';
END $$;

-- Uncomment the next line to enable RLS security (NOT recommended for initial testing)
-- \i database-scripts/03-security-rls.sql

-- =================================================================
-- STEP 4: ADD UTILITY FUNCTIONS
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '>>> STEP 4: Adding utility and maintenance functions...';
END $$;

-- Run the utility functions script
\i database-scripts/04-maintenance-utils.sql

-- =================================================================
-- STEP 5: VERIFY DEPLOYMENT
-- =================================================================

DO $$
DECLARE
    table_count INTEGER;
    user_count INTEGER;
    function_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '>>> STEP 5: Verifying deployment...';
    
    -- Count tables
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('users', 'point_transactions', 'rewards', 'redemption_history', 'milestones', 'user_milestones', 'system_settings');
    
    -- Count sample users
    SELECT COUNT(*) INTO user_count FROM public.users;
    
    -- Count custom functions
    SELECT COUNT(*) INTO function_count
    FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name LIKE '%user%' OR routine_name LIKE '%points%' OR routine_name LIKE '%maintenance%';
    
    RAISE NOTICE 'Tables created: % of 7 expected', table_count;
    RAISE NOTICE 'Sample users: %', user_count;
    RAISE NOTICE 'Custom functions: %', function_count;
    
    IF table_count = 7 THEN
        RAISE NOTICE '✓ All core tables created successfully';
    ELSE
        RAISE WARNING '⚠ Some tables may be missing!';
    END IF;
    
    IF user_count >= 6 THEN
        RAISE NOTICE '✓ Sample data loaded successfully';
    ELSE
        RAISE WARNING '⚠ Sample data may be incomplete!';
    END IF;
END $$;

-- =================================================================
-- STEP 6: DISPLAY SAMPLE ACCOUNTS
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '>>> STEP 6: Sample accounts for testing...';
END $$;

SELECT 
    'SAMPLE ACCOUNTS' as "Account Type",
    email as "Email",
    full_name as "Name", 
    points as "Points",
    member_level as "Level"
FROM public.users 
ORDER BY points DESC;

-- =================================================================
-- STEP 7: SHOW SYSTEM STATISTICS
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '>>> STEP 7: System statistics...';
END $$;

SELECT * FROM public.get_system_stats();

-- =================================================================
-- DEPLOYMENT COMPLETION
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'PRIVILEGE MEMBER SYSTEM DEPLOYMENT COMPLETED!';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Deployment finished at: %', NOW();
    RAISE NOTICE '';
    RAISE NOTICE 'NEXT STEPS:';
    RAISE NOTICE '1. Update your Supabase environment variables';
    RAISE NOTICE '2. Test the application with sample accounts';
    RAISE NOTICE '3. Configure authentication in your frontend';
    RAISE NOTICE '4. Review and enable RLS when ready for production';
    RAISE NOTICE '';
    RAISE NOTICE 'SAMPLE ACCOUNTS (for testing):';
    RAISE NOTICE '- Admin: admin@privilegemember.co.th';
    RAISE NOTICE '- Premium User: premium.user1@example.com (12,500 points)';
    RAISE NOTICE '- Regular User: somchai@example.com (7,850 points)';
    RAISE NOTICE '- Platinum User: jane.smith@example.com (55,000 points)';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANT SECURITY NOTES:';
    RAISE NOTICE '- RLS is DISABLED by default for easier testing';
    RAISE NOTICE '- Run 03-security-rls.sql when ready for production';
    RAISE NOTICE '- Change default passwords and remove test accounts';
    RAISE NOTICE '- Review all permissions before going live';
    RAISE NOTICE '';
    RAISE NOTICE 'MAINTENANCE:';
    RAISE NOTICE '- Run daily_maintenance() function daily';
    RAISE NOTICE '- Run weekly_maintenance() function weekly';
    RAISE NOTICE '- Monitor system_stats() for performance';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENTATION:';
    RAISE NOTICE '- See database-scripts/ folder for individual scripts';
    RAISE NOTICE '- Check function documentation for usage examples';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Happy coding! 🚀';
    RAISE NOTICE '=================================================================';
END $$;
