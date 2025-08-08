import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://bitglhtesgqflxojoamq.supabase.co'
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || ''

if (!supabaseKey) {
  console.warn('Missing VITE_SUPABASE_ANON_KEY environment variable')
}

export const supabase = createClient(supabaseUrl, supabaseKey)

// Database types for TypeScript
export interface User {
  id: string
  email: string
  phone?: string
  full_name: string
  points: number
  member_level: 'bronze' | 'silver' | 'gold' | 'platinum'
  created_at: string
  updated_at: string
}

export interface PointTransaction {
  id: string
  user_id: string
  points: number
  transaction_type: 'earn' | 'redeem' | 'bonus'
  description: string
  reference_id?: string
  created_at: string
}

export interface Reward {
  id: string
  name: string
  description: string
  points_required: number
  category: 'discount' | 'product' | 'voucher'
  image_url?: string
  is_active: boolean
  created_at: string
}

export interface RedemptionHistory {
  id: string
  user_id: string
  reward_id: string
  points_used: number
  status: 'pending' | 'approved' | 'completed' | 'cancelled'
  created_at: string
  completed_at?: string
}

export interface Milestone {
  id: string
  points_required: number
  reward_title: string
  reward_description: string
  is_active: boolean
  created_at: string
}
