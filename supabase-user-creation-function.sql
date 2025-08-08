-- Create a function to handle user creation that bypasses RLS
CREATE OR REPLACE FUNCTION public.create_user_profile(
  user_id UUID,
  user_email TEXT,
  user_full_name TEXT,
  user_phone TEXT DEFAULT NULL
)
RETURNS public.users
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
DECLARE
  new_user public.users;
BEGIN
  -- Insert the user record
  INSERT INTO public.users (
    id,
    email,
    full_name,
    phone,
    points,
    member_level,
    created_at,
    updated_at
  ) VALUES (
    user_id,
    user_email,
    user_full_name,
    user_phone,
    1000, -- Welcome bonus
    'bronze',
    NOW(),
    NOW()
  ) RETURNING * INTO new_user;
  
  -- Add welcome bonus transaction
  INSERT INTO public.point_transactions (
    user_id,
    points,
    transaction_type,
    description,
    created_at
  ) VALUES (
    user_id,
    1000,
    'bonus',
    'โบนัสสมาชิกใหม่',
    NOW()
  );
  
  RETURN new_user;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT, TEXT, TEXT) TO authenticated, anon;

SELECT 'User creation function created successfully!' as message;
