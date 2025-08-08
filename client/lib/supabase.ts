import { createClient } from "@supabase/supabase-js";

const supabaseUrl =
  import.meta.env.VITE_SUPABASE_URL ||
  "https://bitglhtesgqflxojoamq.supabase.co";
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "";

// Development mode detection
const isDevelopment = import.meta.env.DEV;

// Validate required environment variables
if (!supabaseKey) {
  const errorMessage = `
❌ Missing VITE_SUPABASE_ANON_KEY environment variable

To fix this:
1. Go to your Supabase dashboard: https://supabase.com/dashboard/project/bitglhtesgqflxojoamq
2. Navigate to Settings > API
3. Copy the "anon public" key
4. Set it as VITE_SUPABASE_ANON_KEY environment variable

Current environment:
- VITE_SUPABASE_URL: ${supabaseUrl}
- VITE_SUPABASE_ANON_KEY: ${supabaseKey ? "SET" : "MISSING"}
- Development mode: ${isDevelopment}
  `;

  console.error(errorMessage);

  if (!isDevelopment) {
    // In production, throw error
    throw new Error("Supabase configuration error: Missing anon key");
  } else {
    // In development, warn but continue with a placeholder
    console.warn(
      "⚠️ Using placeholder Supabase key for development. Features may not work correctly.",
    );
  }
}

if (!supabaseUrl) {
  console.error("❌ Missing VITE_SUPABASE_URL environment variable");
  throw new Error("Supabase configuration error: Missing URL");
}

// Create Supabase client with validated configuration
export const supabase = createClient(
  supabaseUrl,
  supabaseKey || "placeholder-key-for-development",
  {
    auth: {
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true,
    },
  },
);

// Export configuration status for debugging
export const supabaseConfig = {
  url: supabaseUrl,
  hasKey: !!supabaseKey,
  isDevelopment,
  isConfigured: !!(supabaseUrl && supabaseKey),
};

// Database types for TypeScript
export interface User {
  id: string;
  email: string;
  phone?: string;
  full_name: string;
  points: number;
  member_level: "bronze" | "silver" | "gold" | "platinum";
  created_at: string;
  updated_at: string;
}

export interface PointTransaction {
  id: string;
  user_id: string;
  points: number;
  transaction_type: "earn" | "redeem" | "bonus";
  description: string;
  reference_id?: string;
  created_at: string;
}

export interface Reward {
  id: string;
  name: string;
  description: string;
  points_required: number;
  category: "discount" | "product" | "voucher";
  image_url?: string;
  is_active: boolean;
  created_at: string;
}

export interface RedemptionHistory {
  id: string;
  user_id: string;
  reward_id: string;
  points_used: number;
  status: "pending" | "approved" | "completed" | "cancelled";
  created_at: string;
  completed_at?: string;
}

export interface Milestone {
  id: string;
  points_required: number;
  reward_title: string;
  reward_description: string;
  is_active: boolean;
  created_at: string;
}
