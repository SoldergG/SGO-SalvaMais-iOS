-- 1. Permitir que usuários criem seus próprios perfis se o trigger falhar (Self-Healing)
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. Criar perfis faltantes (Backfill)
INSERT INTO public.profiles (id, email, role, is_approved, max_usage_limit)
SELECT 
  id, 
  email, 
  'free', 
  FALSE, 
  100
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles);

-- 3. Atualizar Super Admin IGNORANDO maiúsculas/minúsculas (ILIKE)
UPDATE public.profiles 
SET 
  role = 'super_admin', 
  is_approved = TRUE, 
  max_usage_limit = 999999
WHERE email ILIKE 'lucascorreiasalvador28@gmail.com';

-- 4. Atualizar a função de trigger para evitar o problema no futuro
CREATE OR REPLACE FUNCTION public.set_super_admin_if_match()
RETURNS TRIGGER AS $$
BEGIN
  -- Usa LOWER() para comparar sempre em minúsculo
  IF LOWER(new.email) = 'lucascorreiasalvador28@gmail.com' THEN
    UPDATE public.profiles 
    SET role = 'super_admin', is_approved = TRUE, max_usage_limit = 999999
    WHERE id = new.id;
  END IF;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
