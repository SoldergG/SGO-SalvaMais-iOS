-- FIX FOR INFINITE RECURSION ERROR (42P17)
-- Run this entire script in the Supabase SQL Editor

-- 1. Create a secure function to check user role without triggering RLS loops
-- SECURITY DEFINER means this function runs with admin privileges, bypassing RLS
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role text;
BEGIN
  SELECT role INTO user_role
  FROM public.profiles
  WHERE id = auth.uid();
  return user_role;
END;
$$;

-- 2. Drop the problematic recursive policies
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Super Admins can update profiles" ON public.profiles;
DROP POLICY IF EXISTS "View own team" ON public.teams;

-- 3. Re-create 'profiles' policies using the secure function
-- This prevents the "SELECT FROM profiles" loop because get_my_role() bypasses RLS

CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT USING (
    (auth.uid() = id) -- User can see themselves
    OR 
    (public.get_my_role() IN ('admin', 'super_admin')) -- Admins can see everyone
  );

CREATE POLICY "Super Admins can update profiles" ON public.profiles
  FOR UPDATE USING (
    public.get_my_role() = 'super_admin'
  );

-- 4. Re-create 'teams' policy
CREATE POLICY "View own team" ON public.teams
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() 
      AND (
        team_id = public.teams.id 
        OR 
        public.get_my_role() IN ('admin', 'super_admin')
      )
    )
  );

-- 5. Ensure the Super Admin user is set correctly (just in case)
UPDATE public.profiles 
SET role = 'super_admin', is_approved = TRUE, max_usage_limit = 999999
WHERE email = 'lucascorreiasalvador28@gmail.com';
