-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Quotes Table
CREATE TABLE quotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  text TEXT NOT NULL,
  author TEXT,
  category TEXT,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);
-- Enable RLS for quotes table
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

-- Profiles Table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT,
  avatar_url TEXT
);
ALTER TABLE profiles
ADD COLUMN bio TEXT;
ALTER TABLE profiles
ADD COLUMN created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE profiles
DROP COLUMN avatar_url;
-- Enable RLS for profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Likes Table
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quote_id UUID REFERENCES quotes(id),
  user_id UUID REFERENCES auth.users(id)
);
-- Enable RLS for likes table
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Add featured_quote_id column to profiles table if it doesn't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS featured_quote_id UUID REFERENCES quotes(id);

-- Add category column to quotes table if it doesn't exist
ALTER TABLE quotes 
ADD COLUMN IF NOT EXISTS category TEXT;

-- Add updated_at column to profiles table if it doesn't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW());

-- Create function to update updated_at timestamp if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at timestamp if it doesn't exist
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Ensure RLS is enabled on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- Update or create RLS policies for profiles
DROP POLICY IF EXISTS "Anyone can view profiles" ON profiles;
CREATE POLICY "Anyone can view profiles"
    ON profiles FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
CREATE POLICY "Users can insert their own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Update or create RLS policies for quotes
DROP POLICY IF EXISTS "Anyone can view quotes" ON quotes;
CREATE POLICY "Anyone can view quotes"
    ON quotes FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Authenticated users can insert quotes" ON quotes;
CREATE POLICY "Authenticated users can insert quotes"
    ON quotes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own quotes" ON quotes;
CREATE POLICY "Users can update their own quotes"
    ON quotes FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own quotes" ON quotes;
CREATE POLICY "Users can delete their own quotes"
    ON quotes FOR DELETE
    USING (auth.uid() = user_id);

-- Update or create RLS policies for likes
DROP POLICY IF EXISTS "Anyone can view likes" ON likes;
CREATE POLICY "Anyone can view likes"
    ON likes FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Authenticated users can insert likes" ON likes;
CREATE POLICY "Authenticated users can insert likes"
    ON likes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own likes" ON likes;
CREATE POLICY "Users can delete their own likes"
    ON likes FOR DELETE
    USING (auth.uid() = user_id);

-- Add unique constraint to likes table if it doesn't exist
ALTER TABLE likes 
ADD CONSTRAINT unique_quote_user_like UNIQUE(quote_id, user_id);

-- Add ON DELETE CASCADE to likes table if it doesn't exist
ALTER TABLE likes 
DROP CONSTRAINT IF EXISTS likes_quote_id_fkey,
ADD CONSTRAINT likes_quote_id_fkey 
FOREIGN KEY (quote_id) 
REFERENCES quotes(id) 
ON DELETE CASCADE;

-- Create function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email)
    VALUES (new.id, new.email);
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user(); 