// src/lib/supabaseClient.ts – alleen voor Client Components
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database'

export const supabase = createBrowserClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
