-- supabase/migrations/20250422124742_api_key_hashing.sql
-- Implement API Key Hashing using pgsodium
-- Rule Compliance: CP-02 (Security first)

-- 0. Create the private schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS private;

-- 1. Enable pgsodium extension if not already enabled (usually is by default on Supabase)
-- CREATE EXTENSION IF NOT EXISTS pgsodium WITH SCHEMA extensions;
-- Commented out as it's typically pre-enabled.

-- 2. Create a function to hash the key
-- Note: We expect the *actual plain text key* to be temporarily passed in the 'hashed_key' column on INSERT.
-- The trigger will replace it with the real hash.
CREATE OR REPLACE FUNCTION private.hash_api_key()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER -- Important for accessing pgsodium functions safely
SET search_path = extensions -- Ensure pgsodium is in the search path
AS $$
BEGIN
  -- Hash the plain text key provided in NEW.hashed_key
  -- crypto_pwhash_str generates a salt and hashes the password securely.
  NEW.hashed_key := extensions.crypto_pwhash_str(NEW.hashed_key::bytea);
  RETURN NEW;
END;
$$;

-- 3. Create the trigger function (this calls the hashing function)
CREATE OR REPLACE FUNCTION public.set_hashed_api_key()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Call the private hashing function
  SELECT private.hash_api_key() INTO NEW;
  RETURN NEW;
END;
$$;

-- 4. Create the trigger on the api_keys table
-- This trigger fires BEFORE an INSERT operation.
CREATE TRIGGER trigger_hash_api_key
BEFORE INSERT ON public.api_keys
FOR EACH ROW
EXECUTE FUNCTION public.set_hashed_api_key();

-- Optional: Add a similar trigger for UPDATE if keys can be rotated/updated
-- CREATE TRIGGER trigger_update_hashed_api_key
-- BEFORE UPDATE ON public.api_keys
-- FOR EACH ROW
-- WHEN (NEW.hashed_key IS DISTINCT FROM OLD.hashed_key) -- Only hash if the 'key' value changes
-- EXECUTE FUNCTION public.set_hashed_api_key();

-- Note: We still need a function to *verify* a provided key against the stored hash.
-- This will be needed when checking API key validity in middleware or API routes.