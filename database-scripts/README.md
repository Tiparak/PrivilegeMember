# Privilege Member Database Scripts

## 📋 Overview

Complete database setup scripts for the Privilege Member loyalty points system. These scripts create a production-ready PostgreSQL/Supabase database with all necessary tables, functions, and security configurations.

## 🗂️ Script Files

### `00-deploy-all.sql` - Master Deployment Script
- **Purpose**: Deploys the complete system in one go
- **Usage**: Run this for initial setup or full deployment
- **Includes**: All other scripts in sequence
- **Time**: ~2-5 minutes

### `01-setup-tables.sql` - Core Database Structure
- **Purpose**: Creates all tables, indexes, triggers, and functions
- **Tables**: users, point_transactions, rewards, redemption_history, milestones, user_milestones, system_settings
- **Features**: Auto-point calculation, member level updates, milestone tracking
- **Security**: RLS disabled by default for easier testing

### `02-sample-data.sql` - Test Data
- **Purpose**: Populates database with realistic sample data
- **Includes**: 7 sample users, transactions, rewards, milestones, redemptions
- **Test Accounts**: Admin, regular users, and premium members
- **Points Range**: 500 - 55,000 points across different member levels

### `03-security-rls.sql` - Row Level Security
- **Purpose**: Enables production-grade security with RLS policies
- **Features**: User data protection, admin role management, audit logging
- **WARNING**: Only run after authentication is properly configured
- **Policies**: Users can only access their own data, admins have full access

### `04-maintenance-utils.sql` - Utility Functions
- **Purpose**: Provides helper functions and maintenance procedures
- **Features**: Statistics, points management, cleanup routines
- **Functions**: `get_user_stats()`, `award_points()`, `daily_maintenance()`

## 🚀 Quick Start

### 1. For Development/Testing (Recommended)
```sql
-- Run in Supabase SQL Editor or psql
\i database-scripts/00-deploy-all.sql
```

### 2. For Production (Step by Step)
```sql
-- Step 1: Create core structure
\i database-scripts/01-setup-tables.sql

-- Step 2: Add sample data (optional for production)
-- \i database-scripts/02-sample-data.sql

-- Step 3: Enable security (after authentication setup)
\i database-scripts/03-security-rls.sql

-- Step 4: Add utilities
\i database-scripts/04-maintenance-utils.sql
```

## 📊 Database Schema

### Core Tables

#### `users` - User Profiles
- **Primary Key**: `id` (UUID)
- **Unique**: `email`
- **Points**: Automatically calculated from transactions
- **Levels**: bronze, silver, gold, platinum (auto-updated)
- **Status**: active, inactive, suspended

#### `point_transactions` - All Point Activities
- **Types**: earn, redeem, bonus, penalty, adjustment
- **Auto-triggers**: Updates user points and member levels
- **References**: Links to POS systems, merchants, locations

#### `rewards` - Available Rewards
- **Categories**: discount, product, voucher, service, experience
- **Validation**: Points required, stock quantity, validity dates
- **Status**: Active/inactive with sort ordering

#### `redemption_history` - Reward Redemptions
- **Workflow**: pending → approved → completed/cancelled/expired
- **Codes**: Auto-generated unique redemption codes
- **Tracking**: Full audit trail with timestamps

#### `milestones` - Achievement Levels
- **Triggers**: Auto-achievement detection when points increase
- **Types**: badge, points, discount, product, tier_upgrade
- **Repeatable**: Can be achieved multiple times if configured

#### `user_milestones` - Achievement Records
- **Unique**: One achievement per user per milestone (unless repeatable)
- **Tracking**: Points at time of achievement

#### `system_settings` - Configuration
- **JSON**: Flexible configuration storage
- **Public/Private**: Controls visibility to non-admin users
- **Examples**: Point exchange rates, member thresholds, system flags

## 🔧 Key Features

### Automatic Point Management
- **Real-time Updates**: Points automatically recalculated on every transaction
- **Member Level Updates**: Automatic tier upgrades based on point thresholds
- **Milestone Detection**: Auto-achievement detection and recording

### Business Logic Functions
```sql
-- Award points to user
SELECT public.award_points(
    user_uuid := '123e4567-e89b-12d3-a456-426614174000',
    points_amount := 500,
    transaction_description := 'Purchase at Store A',
    reference_id := 'POS-001',
    merchant_name := 'Store A',
    location := 'Mall ABC'
);

-- Process reward redemption
SELECT public.create_reward_redemption(
    user_uuid := '123e4567-e89b-12d3-a456-426614174000',
    reward_uuid := 'reward-uuid-here'
);
```

### Statistics and Reporting
```sql
-- Get user statistics
SELECT * FROM public.get_user_stats('user-uuid-here');

-- Get system-wide statistics
SELECT * FROM public.get_system_stats();

-- Get points summary for date range
SELECT * FROM public.get_points_summary('2024-01-01', '2024-01-31');
```

### Maintenance Functions
```sql
-- Daily maintenance (expire redemptions, update levels)
SELECT public.daily_maintenance();

-- Recalculate points for all users
SELECT * FROM public.recalculate_user_points();

-- Cleanup old audit logs
SELECT public.cleanup_audit_logs(90); -- Keep 90 days
```

## 🔒 Security Configuration

### Row Level Security (RLS)
- **Default**: Disabled for easier development
- **Production**: Enable with `03-security-rls.sql`
- **Policies**: Users access own data only, admins have full access

### Admin Role Detection
```sql
-- Checks if current user email contains 'admin'
SELECT public.is_admin();

-- Function to set admin status
SELECT public.set_admin_role('user@example.com');
```

### Audit Logging (Optional)
- **Table**: `audit_log` for tracking all changes
- **Triggers**: Commented out by default (enable if needed)
- **Cleanup**: Automatic cleanup with maintenance functions

## 🧪 Sample Test Accounts

| Email | Name | Points | Level | Purpose |
|-------|------|--------|-------|---------|
| `admin@privilegemember.co.th` | ผู้ดูแลระบบ | 0 | platinum | Admin testing |
| `premium.user1@example.com` | Premium User1 | 12,500 | gold | Premium user |
| `somchai@example.com` | สมชาย ใจดี | 7,850 | silver | Regular user |
| `jane.smith@example.com` | Jane Smith | 55,000 | platinum | High-value user |
| `malee@example.com` | นางสาวมาลี มีเงิน | 3,200 | bronze | New user |

## 📈 Performance Optimizations

### Indexes
- **Users**: email, phone, member_level, status, created_at
- **Transactions**: user_id, type, created_at, reference_id
- **Rewards**: category, is_active, points_required, valid_dates
- **Redemptions**: user_id, reward_id, status, created_at, code

### Triggers
- **Efficient**: Only fire when relevant data changes
- **Batched**: Designed to handle bulk operations
- **Fail-safe**: Won't break if data is inconsistent

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Errors**
   ```sql
   -- Grant necessary permissions
   GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
   GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
   GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
   ```

2. **RLS Blocking Access**
   ```sql
   -- Temporarily disable RLS for testing
   ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
   ```

3. **Point Calculation Errors**
   ```sql
   -- Recalculate all user points
   SELECT * FROM public.recalculate_user_points();
   ```

4. **Trigger Not Firing**
   ```sql
   -- Check trigger status
   SELECT * FROM information_schema.triggers WHERE trigger_name LIKE '%update_user_points%';
   ```

### Verification Queries
```sql
-- Check all tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'point_transactions', 'rewards', 'redemption_history', 'milestones');

-- Verify sample data
SELECT COUNT(*) as user_count FROM public.users;
SELECT COUNT(*) as transaction_count FROM public.point_transactions;
SELECT COUNT(*) as reward_count FROM public.rewards;

-- Test point calculation
SELECT id, email, points, 
       (SELECT SUM(points) FROM public.point_transactions WHERE user_id = u.id) as calculated_points
FROM public.users u;
```

## 🔄 Migration and Updates

### Adding New Features
1. **New Tables**: Add to `01-setup-tables.sql`
2. **New Functions**: Add to `04-maintenance-utils.sql`
3. **New Policies**: Add to `03-security-rls.sql`
4. **Sample Data**: Add to `02-sample-data.sql`

### Version Control
- Keep scripts in version control
- Use separate migration files for updates
- Test migrations on sample data first

## 📚 Additional Resources

### Supabase Specific
- **Environment Variables**: Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
- **RLS**: Enable when authentication is configured
- **Functions**: Can be called via Supabase client

### PostgreSQL Compatibility
- **Version**: PostgreSQL 12+ required
- **Extensions**: uuid-ossp (auto-installed in Supabase)
- **Timezone**: Configured for Asia/Bangkok

### Best Practices
- **Testing**: Always test on sample data first
- **Backups**: Create backups before running scripts
- **Security**: Enable RLS only after authentication is working
- **Monitoring**: Use utility functions to monitor system health

---

## 🎉 Ready to Deploy!

Your Privilege Member database system is now ready for deployment. The scripts provide:

- ✅ **Complete Database Structure**
- ✅ **Realistic Sample Data**
- ✅ **Production-Ready Security**
- ✅ **Maintenance and Utilities**
- ✅ **Performance Optimizations**
- ✅ **Comprehensive Documentation**

**Next Steps:**
1. Run `00-deploy-all.sql` in your Supabase project
2. Test with the sample accounts
3. Connect your frontend application
4. Enable RLS when ready for production

Happy coding! 🚀
