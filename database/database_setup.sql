-- ====================================================================================
-- STUDENT ASSISTANT APPLICATION SYSTEM - DATABASE SETUP SCRIPT
-- ====================================================================================
-- This script initializes the required tables, foreign key constraints, 
-- and Row Level Security (RLS) policies for the Supabase backend.
-- ====================================================================================

-- ------------------------------------------------------------------------------------
-- 1. TABLE CREATION & CASCADING CONSTRAINTS
-- ------------------------------------------------------------------------------------

-- Create the Profiles table (Linked to Supabase Auth)
CREATE TABLE profiles (
    -- The ON DELETE CASCADE ensures that if an Auth user is deleted, their profile is too.
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    student_number TEXT UNIQUE NOT NULL,
    role TEXT DEFAULT 'student' NOT NULL
);

-- Create the Applications table (Linked to Profiles)
CREATE TABLE applications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    -- The ON DELETE CASCADE ensures if a profile is deleted, their applications are too.
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    student_number TEXT NOT NULL,
    full_name TEXT NOT NULL,
    year_of_study TEXT NOT NULL,
    module1_level TEXT NOT NULL,
    module1_name TEXT NOT NULL,
    module2_level TEXT,
    module2_name TEXT,
    meets_requirements BOOLEAN DEFAULT false,
    status TEXT DEFAULT 'pending' NOT NULL,
    documentUrl TEXT
);

-- ------------------------------------------------------------------------------------
-- 2. DATABASE ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------------

-- Enable RLS to lock down the tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Users can view their own profile" 
ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE USING (auth.uid() = id);

-- Applications Policies: Students
CREATE POLICY "Students can view own applications" 
ON applications FOR SELECT USING (auth.uid() = student_id);

CREATE POLICY "Students can insert own applications" 
ON applications FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can update own applications" 
ON applications FOR UPDATE USING (auth.uid() = student_id);

-- Applications Policies: Admins
-- (Checks the profiles table to see if the requesting user has the 'admin' role)
CREATE POLICY "Admins can view all applications" 
ON applications FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

CREATE POLICY "Admins can update all applications" 
ON applications FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

CREATE POLICY "Admins can delete applications" 
ON applications FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- ------------------------------------------------------------------------------------
-- 3. STORAGE BUCKET ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------------
-- Note: The 'supporting_documents' bucket must be created in the Storage dashboard first, 
-- and set to "Public" so the URLs can be opened in the app.

-- Allow authenticated students and admins to upload files
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'supporting_documents');

-- Allow authenticated users to view and download files
CREATE POLICY "Allow authenticated reads"
ON storage.objects FOR SELECT 
TO authenticated 
USING (bucket_id = 'supporting_documents');

-- Allow authenticated users to update/overwrite their files
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'supporting_documents');

-- Allow authenticated users to delete their files
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'supporting_documents');