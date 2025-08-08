import { supabase, User, PointTransaction, Reward, RedemptionHistory, Milestone } from './supabase'

// User management functions
export const userService = {
  // Get user by ID
  async getUser(userId: string): Promise<User | null> {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single()

    if (error) {
      console.error('Error fetching user:', error)
      return null
    }
    return data
  },

  // Get user by email or phone
  async getUserByEmailOrPhone(emailOrPhone: string): Promise<User | null> {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .or(`email.eq.${emailOrPhone},phone.eq.${emailOrPhone}`)
      .single()

    if (error) {
      console.error('Error fetching user:', error)
      return null
    }
    return data
  },

  // Update user points
  async updateUserPoints(userId: string, newPoints: number): Promise<boolean> {
    const { error } = await supabase
      .from('users')
      .update({ points: newPoints, updated_at: new Date().toISOString() })
      .eq('id', userId)

    if (error) {
      console.error('Error updating user points:', error)
      return false
    }
    return true
  },

  // Create new user with direct insert
  async createUser(userData: Omit<User, 'id' | 'created_at' | 'updated_at'>, authUserId?: string): Promise<User | null> {
    console.log('Creating user with data:', userData, 'Auth User ID:', authUserId)

    if (!authUserId) {
      console.error('Auth User ID is required for user creation')
      return null
    }

    try {
      // Create user record with specific ID
      const userRecord = {
        id: authUserId,
        email: userData.email,
        full_name: userData.full_name,
        phone: userData.phone || null,
        points: 1000, // Welcome bonus
        member_level: 'bronze' as const,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }

      console.log('Inserting user record:', userRecord)

      const { data, error } = await supabase
        .from('users')
        .insert([userRecord])
        .select()
        .single()

      if (error) {
        console.error('Error creating user - Full error:', JSON.stringify(error, null, 2))
        console.error('Error details:', error.message, error.details, error.hint)
        return null
      }

      console.log('User created successfully:', data)

      // Add welcome bonus transaction
      await this.addWelcomeBonus(authUserId)

      return data
    } catch (err) {
      console.error('Exception during user creation:', err)
      return null
    }
  },

  // Helper method to add welcome bonus
  async addWelcomeBonus(userId: string): Promise<void> {
    try {
      await pointsService.addTransaction({
        user_id: userId,
        points: 1000,
        transaction_type: 'bonus',
        description: 'โบนัสสมาชิกใหม่'
      })
      console.log('Welcome bonus added successfully')
    } catch (err) {
      console.error('Failed to add welcome bonus:', err)
    }
  }
}

// Points transaction functions
export const pointsService = {
  // Get user's transaction history
  async getUserTransactions(userId: string, limit = 20): Promise<PointTransaction[]> {
    const { data, error } = await supabase
      .from('point_transactions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) {
      console.error('Error fetching transactions:', error)
      return []
    }
    return data || []
  },

  // Add points transaction
  async addTransaction(transaction: Omit<PointTransaction, 'id' | 'created_at'>): Promise<PointTransaction | null> {
    const { data, error } = await supabase
      .from('point_transactions')
      .insert([{
        ...transaction,
        created_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) {
      console.error('Error adding transaction:', error)
      return null
    }
    return data
  },

  // Get user's total points from transactions
  async getUserTotalPoints(userId: string): Promise<number> {
    const { data, error } = await supabase
      .from('point_transactions')
      .select('points')
      .eq('user_id', userId)

    if (error) {
      console.error('Error calculating total points:', error)
      return 0
    }

    return data?.reduce((total, transaction) => total + transaction.points, 0) || 0
  }
}

// Rewards management
export const rewardsService = {
  // Get all active rewards
  async getActiveRewards(): Promise<Reward[]> {
    const { data, error } = await supabase
      .from('rewards')
      .select('*')
      .eq('is_active', true)
      .order('points_required', { ascending: true })

    if (error) {
      console.error('Error fetching rewards:', error)
      return []
    }
    return data || []
  },

  // Get reward by ID
  async getReward(rewardId: string): Promise<Reward | null> {
    const { data, error } = await supabase
      .from('rewards')
      .select('*')
      .eq('id', rewardId)
      .single()

    if (error) {
      console.error('Error fetching reward:', error)
      return null
    }
    return data
  }
}

// Redemption management
export const redemptionService = {
  // Create redemption request
  async createRedemption(redemption: Omit<RedemptionHistory, 'id' | 'created_at'>): Promise<RedemptionHistory | null> {
    const { data, error } = await supabase
      .from('redemption_history')
      .insert([{
        ...redemption,
        created_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) {
      console.error('Error creating redemption:', error)
      return null
    }
    return data
  },

  // Get user's redemption history
  async getUserRedemptions(userId: string): Promise<RedemptionHistory[]> {
    const { data, error } = await supabase
      .from('redemption_history')
      .select(`
        *,
        rewards (name, description, category)
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching redemptions:', error)
      return []
    }
    return data || []
  },

  // Update redemption status
  async updateRedemptionStatus(redemptionId: string, status: RedemptionHistory['status']): Promise<boolean> {
    const updateData: any = { status }
    if (status === 'completed') {
      updateData.completed_at = new Date().toISOString()
    }

    const { error } = await supabase
      .from('redemption_history')
      .update(updateData)
      .eq('id', redemptionId)

    if (error) {
      console.error('Error updating redemption status:', error)
      return false
    }
    return true
  }
}

// Milestone management
export const milestoneService = {
  // Get all active milestones
  async getActiveMilestones(): Promise<Milestone[]> {
    const { data, error } = await supabase
      .from('milestones')
      .select('*')
      .eq('is_active', true)
      .order('points_required', { ascending: true })

    if (error) {
      console.error('Error fetching milestones:', error)
      return []
    }
    return data || []
  },

  // Check if user achieved new milestones
  async checkUserMilestones(userId: string, currentPoints: number): Promise<Milestone[]> {
    const milestones = await this.getActiveMilestones()
    const achievedMilestones = milestones.filter(milestone => 
      currentPoints >= milestone.points_required
    )
    return achievedMilestones
  }
}

// Authentication helpers
export const authService = {
  // Sign up with email
  async signUp(email: string, password: string, userData: { full_name: string, phone?: string }) {
    try {
      console.log('Starting signup process for:', email)

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: userData
        }
      })

      if (error) {
        console.error('Auth signup error:', error)
        return { user: null, error }
      }

      // Create user record in users table
      if (data.user) {
        console.log('Auth user created, now creating user profile for user ID:', data.user.id)

        try {
          const newUser = await userService.createUser({
            email: data.user.email!,
            full_name: userData.full_name,
            phone: userData.phone,
            points: 1000, // Welcome bonus
            member_level: 'bronze'
          }, data.user.id) // Pass the auth user ID

          if (!newUser) {
            console.error('Failed to create user profile - createUser returned null')
            // Don't throw error, just log it - auth was successful
            console.warn('User auth created but profile creation failed - user can still login')
          } else {
            console.log('User profile created successfully with welcome bonus:', newUser)
          }
        } catch (profileError) {
          console.error('Exception during profile creation:', profileError)
          // Don't throw error - auth was successful, profile creation can be retried later
          console.warn('User auth created but profile creation failed - user can still login')
        }
      }

      return { user: data.user, error: null }
    } catch (err) {
      console.error('Signup process error:', err)
      return { user: null, error: err as any }
    }
  },

  // Sign in with email
  async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    })
    
    if (error) {
      console.error('Error signing in:', error)
      return { user: null, error }
    }
    
    return { user: data.user, error: null }
  },

  // Sign in with Google
  async signInWithGoogle() {
    try {
      console.log('Starting Google OAuth sign in...')

      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/dashboard`,
          queryParams: {
            access_type: 'offline',
            prompt: 'consent',
          }
        }
      })

      if (error) {
        console.error('Google OAuth error:', error)
        return { user: null, error }
      }

      return { user: data, error: null }
    } catch (err) {
      console.error('Google sign in exception:', err)
      return { user: null, error: err as any }
    }
  },

  // Handle OAuth callback and create user profile if needed
  async handleOAuthCallback(user: any) {
    if (!user) return { success: false, error: 'No user provided' }

    try {
      console.log('Handling OAuth callback for user:', user.id)

      // Check if user profile already exists
      const existingUser = await userService.getUser(user.id)

      if (!existingUser) {
        console.log('Creating new user profile for OAuth user')

        // Extract user info from OAuth data
        const fullName = user.user_metadata?.full_name ||
                        user.user_metadata?.name ||
                        `${user.user_metadata?.first_name || ''} ${user.user_metadata?.last_name || ''}`.trim() ||
                        user.email?.split('@')[0] || 'ผู้ใช้ Google'

        const newUser = await userService.createUser({
          email: user.email!,
          full_name: fullName,
          phone: user.user_metadata?.phone || null,
          points: 1000, // Welcome bonus
          member_level: 'bronze'
        }, user.id)

        if (newUser) {
          console.log('OAuth user profile created successfully:', newUser)
          return { success: true, user: newUser }
        } else {
          console.error('Failed to create OAuth user profile')
          return { success: false, error: 'Failed to create user profile' }
        }
      } else {
        console.log('OAuth user profile already exists:', existingUser)
        return { success: true, user: existingUser }
      }
    } catch (err) {
      console.error('OAuth callback error:', err)
      return { success: false, error: err }
    }
  },

  // Sign out
  async signOut() {
    const { error } = await supabase.auth.signOut()
    if (error) {
      console.error('Error signing out:', error)
    }
    return { error }
  },

  // Get current user session
  async getCurrentUser() {
    const { data: { user } } = await supabase.auth.getUser()
    return user
  }
}

// Admin management functions
export const adminService = {
  // User Management
  async getAllUsers(limit = 100, offset = 0): Promise<User[]> {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (error) {
      console.error('Error fetching all users:', error)
      return []
    }
    return data || []
  },

  async updateUser(userId: string, userData: Partial<User>): Promise<boolean> {
    const { error } = await supabase
      .from('users')
      .update({ ...userData, updated_at: new Date().toISOString() })
      .eq('id', userId)

    if (error) {
      console.error('Error updating user:', error)
      return false
    }
    return true
  },

  async deleteUser(userId: string): Promise<boolean> {
    const { error } = await supabase
      .from('users')
      .delete()
      .eq('id', userId)

    if (error) {
      console.error('Error deleting user:', error)
      return false
    }
    return true
  },

  // Rewards Management
  async createReward(rewardData: Omit<Reward, 'id' | 'created_at'>): Promise<Reward | null> {
    const { data, error } = await supabase
      .from('rewards')
      .insert([{
        ...rewardData,
        created_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) {
      console.error('Error creating reward:', error)
      return null
    }
    return data
  },

  async updateReward(rewardId: string, rewardData: Partial<Reward>): Promise<boolean> {
    const { error } = await supabase
      .from('rewards')
      .update(rewardData)
      .eq('id', rewardId)

    if (error) {
      console.error('Error updating reward:', error)
      return false
    }
    return true
  },

  async deleteReward(rewardId: string): Promise<boolean> {
    const { error } = await supabase
      .from('rewards')
      .delete()
      .eq('id', rewardId)

    if (error) {
      console.error('Error deleting reward:', error)
      return false
    }
    return true
  },

  // Milestones Management
  async createMilestone(milestoneData: Omit<Milestone, 'id' | 'created_at'>): Promise<Milestone | null> {
    const { data, error } = await supabase
      .from('milestones')
      .insert([{
        ...milestoneData,
        created_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) {
      console.error('Error creating milestone:', error)
      return null
    }
    return data
  },

  async updateMilestone(milestoneId: string, milestoneData: Partial<Milestone>): Promise<boolean> {
    const { error } = await supabase
      .from('milestones')
      .update(milestoneData)
      .eq('id', milestoneId)

    if (error) {
      console.error('Error updating milestone:', error)
      return false
    }
    return true
  },

  async deleteMilestone(milestoneId: string): Promise<boolean> {
    const { error } = await supabase
      .from('milestones')
      .delete()
      .eq('id', milestoneId)

    if (error) {
      console.error('Error deleting milestone:', error)
      return false
    }
    return true
  },

  // Points Transaction Management
  async getAllTransactions(limit = 100, offset = 0): Promise<PointTransaction[]> {
    const { data, error } = await supabase
      .from('point_transactions')
      .select(`
        *,
        users!inner(full_name, email)
      `)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (error) {
      console.error('Error fetching all transactions:', error)
      return []
    }
    return data || []
  },

  async addPointsToUser(userId: string, points: number, description: string): Promise<boolean> {
    const transaction = await pointsService.addTransaction({
      user_id: userId,
      points: points,
      transaction_type: points > 0 ? 'earn' : 'redeem',
      description: description
    })

    return transaction !== null
  },

  // Redemption Management
  async getAllRedemptions(limit = 100, offset = 0): Promise<RedemptionHistory[]> {
    const { data, error } = await supabase
      .from('redemption_history')
      .select(`
        *,
        users!inner(full_name, email),
        rewards!inner(name, description)
      `)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (error) {
      console.error('Error fetching all redemptions:', error)
      return []
    }
    return data || []
  },

  async updateRedemptionStatus(redemptionId: string, status: RedemptionHistory['status']): Promise<boolean> {
    return await redemptionService.updateRedemptionStatus(redemptionId, status)
  },

  // Dashboard Statistics
  async getDashboardStats(): Promise<any> {
    try {
      // Get total users
      const { count: totalUsers } = await supabase
        .from('users')
        .select('*', { count: 'exact', head: true })

      // Get total points
      const { data: pointsData } = await supabase
        .from('users')
        .select('points')

      const totalPoints = pointsData?.reduce((sum, user) => sum + (user.points || 0), 0) || 0

      // Get total redemptions
      const { count: totalRedemptions } = await supabase
        .from('redemption_history')
        .select('*', { count: 'exact', head: true })

      // Get active rewards
      const { count: activeRewards } = await supabase
        .from('rewards')
        .select('*', { count: 'exact', head: true })
        .eq('is_active', true)

      // Get new users today
      const today = new Date().toISOString().split('T')[0]
      const { count: newUsersToday } = await supabase
        .from('users')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', `${today}T00:00:00.000Z`)
        .lt('created_at', `${today}T23:59:59.999Z`)

      // Get points issued today
      const { data: todayTransactions } = await supabase
        .from('point_transactions')
        .select('points')
        .gte('created_at', `${today}T00:00:00.000Z`)
        .lt('created_at', `${today}T23:59:59.999Z`)
        .gt('points', 0)

      const pointsIssuedToday = todayTransactions?.reduce((sum, tx) => sum + tx.points, 0) || 0

      return {
        totalUsers: totalUsers || 0,
        totalPoints,
        totalRedemptions: totalRedemptions || 0,
        activeRewards: activeRewards || 0,
        newUsersToday: newUsersToday || 0,
        pointsIssuedToday
      }
    } catch (error) {
      console.error('Error fetching dashboard stats:', error)
      return {
        totalUsers: 0,
        totalPoints: 0,
        totalRedemptions: 0,
        activeRewards: 0,
        newUsersToday: 0,
        pointsIssuedToday: 0
      }
    }
  }
}
