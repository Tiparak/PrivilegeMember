import { supabase, User, PointTransaction, Reward, RedemptionHistory, Milestone } from './supabase'

// User management functions
export const userService = {
  // Get user by ID
  async getUser(userId: string): Promise<User | null> {
    const { data, error } = await supabase
      .from('privilege.users')
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
      .from('privilege.users')
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
      .from('privilege.users')
      .update({ points: newPoints, updated_at: new Date().toISOString() })
      .eq('id', userId)

    if (error) {
      console.error('Error updating user points:', error)
      return false
    }
    return true
  },

  // Create new user
  async createUser(userData: Omit<User, 'id' | 'created_at' | 'updated_at'>): Promise<User | null> {
    console.log('Creating user with data:', userData)

    const { data, error } = await supabase
      .from('privilege.users')
      .insert([{
        ...userData,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) {
      console.error('Error creating user - Full error:', JSON.stringify(error, null, 2))
      console.error('Error details:', error.message, error.details, error.hint)
      return null
    }
    return data
  }
}

// Points transaction functions
export const pointsService = {
  // Get user's transaction history
  async getUserTransactions(userId: string, limit = 20): Promise<PointTransaction[]> {
    const { data, error } = await supabase
      .from('privilege.point_transactions')
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
      .from('privilege.point_transactions')
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
      .from('privilege.point_transactions')
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
      .from('privilege.rewards')
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
      .from('privilege.rewards')
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
      .from('privilege.redemption_history')
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
      .from('privilege.redemption_history')
      .select(`
        *,
        privilege.rewards (name, description, category)
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
      .from('privilege.redemption_history')
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
      .from('privilege.milestones')
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
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: userData
      }
    })
    
    if (error) {
      console.error('Error signing up:', error)
      return { user: null, error }
    }
    
    // Create user record in users table
    if (data.user) {
      const newUser = await userService.createUser({
        email: data.user.email!,
        full_name: userData.full_name,
        phone: userData.phone,
        points: 0,
        member_level: 'bronze'
      })
    }
    
    return { user: data.user, error: null }
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
