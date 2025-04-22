-- Supabase Schema for Wrapper Project
-- Rule Compliance: CP-01 (Clean code), CP-02 (Security first), SB-01 (Supabase auth)

-- Profiles Table
-- Stores public profile information linked to authenticated users.
CREATE TABLE public.profiles (
  id UUID NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  updated_at TIMESTAMPTZ DEFAULT now(),
  full_name TEXT,
  avatar_url TEXT,
  -- Add other profile fields as needed

  CONSTRAINT proper_url CHECK (avatar_url IS NULL OR avatar_url ~* '^https?://.*')
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
-- Users can view any profile (adjust if privacy is needed)
CREATE POLICY "Allow public read access" ON public.profiles
  FOR SELECT USING (true);

-- Users can only update their own profile
CREATE POLICY "Allow individual update access" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at() 
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW; 
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update updated_at on profile changes
CREATE TRIGGER on_profile_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- API Keys Table
-- Stores API keys associated with users.
CREATE TABLE public.api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  key_name TEXT NOT NULL CHECK (char_length(key_name) > 0 AND char_length(key_name) <= 100),
  key_prefix TEXT NOT NULL UNIQUE CHECK (char_length(key_prefix) = 8), -- For identifying keys (e.g., sk_live_...)
  hashed_key TEXT NOT NULL, -- Store a hash of the actual key, not the key itself
  created_at TIMESTAMPTZ DEFAULT now(),
  last_used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  
  CONSTRAINT user_owns_key UNIQUE (user_id, key_name) -- Ensure key names are unique per user
);

ALTER TABLE public.api_keys ENABLE ROW LEVEL SECURITY;

-- RLS Policies for api_keys
-- Users can manage (select, insert, update, delete) their own API keys
CREATE POLICY "Allow individual access to API keys" ON public.api_keys
  FOR ALL USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX idx_api_keys_user_id ON public.api_keys(user_id);

-- TODO: Implement function to hash API keys before storing
-- TODO: Implement mechanism to check API key validity against hashed_key
-- TODO: Consider adding scopes/permissions to API keys
