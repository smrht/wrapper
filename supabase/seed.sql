-- supabase/seed.sql
-- Voorbeelddata voor ontwikkeling

-- Zorg ervoor dat de UUIDs hieronder overeenkomen met bestaande gebruikers in auth.users!
-- Je kunt gebruikers aanmaken via de Supabase UI of je applicatie.

-- Leeg de tabel eerst om conflicten te voorkomen bij opnieuw uitvoeren
-- TRUNCATE public.profiles RESTART IDENTITY CASCADE;
-- TRUNCATE public.api_keys RESTART IDENTITY CASCADE; 
-- Wees voorzichtig met TRUNCATE in productie!

-- Voeg voorbeeld profielen toe
INSERT INTO public.profiles (id, full_name, avatar_url)
VALUES
  -- Vervang deze UUID door een bestaande auth.users.id
  ('8a7e1f0a-3b1c-4d5e-9f2a-1b3c4d5e6f7a', 'Alice Developer', 'https://example.com/avatars/alice.png'),
  -- Vervang deze UUID door een andere bestaande auth.users.id
  ('f0a9b8c7-6d5e-4f3a-2b1c-0a9b8c7d6e5f', 'Bob Tester', NULL);

-- Voeg voorbeeld API keys toe (ZONDER HASHING - dit is alleen voor structuur)
-- LET OP: Deze worden niet gehashed! Hashing gebeurt via triggers.
-- We voegen hier nog geen keys toe totdat hashing is geïmplementeerd.
/*
INSERT INTO public.api_keys (user_id, key_name, key_prefix, hashed_key)
VALUES
  -- Gebruik dezelfde UUIDs als hierboven
  ('8a7e1f0a-3b1c-4d5e-9f2a-1b3c4d5e6f7a', 'My First Key', 'sk_test_1', 'dummy_hash_1'),
  ('f0a9b8c7-6d5e-4f3a-2b1c-0a9b8c7d6e5f', 'Bob Key Dev', 'sk_test_2', 'dummy_hash_2');
*/

SELECT 'Seed data applied successfully (profiles only for now).';
