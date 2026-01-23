-- SCRIPT: BACKFILL MISSING PROFILES
-- Run this in Supabase SQL Editor to ensure all auth users have a profile

-- 1. Insert profiles for users who exist in auth.users but not in public.profiles
INSERT INTO public.profiles (id, email, role, is_approved, max_usage_limit)
SELECT 
  id, 
  email, 
  'free', 
  FALSE, 
  100
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles);

-- 2. Ensure the Super Admin is set up correctly
UPDATE public.profiles 
SET 
  role = 'super_admin', 
  is_approved = TRUE, 
  max_usage_limit = 999999
WHERE email = 'lucascorreiasalvador28@gmail.com';

-- 3. Output confirmation
SELECT count(*) as profiles_created FROM public.profiles WHERE created_at > now() - interval '1 minute';
