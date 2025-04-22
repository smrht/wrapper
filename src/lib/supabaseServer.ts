// src/lib/supabaseServer.ts – voor Server Components & route‑handlers
import { cookies } from 'next/headers'
import { createServerClient } from '@supabase/ssr'
import type { Database } from '@/types/database'

export const supabaseServer = () =>
  createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies }        // zorgt dat `updateSession()` cookies bijwerkt
  )
