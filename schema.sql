-- Japan Akura Supabase schema
-- Run this file in Supabase SQL Editor. Then create an Auth user and promote it to admin.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'student' check (role in ('student','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null default 'Grammar',
  level text not null default 'Beginner',
  jp text,
  si_summary text not null,
  body text,
  duration text default '10 min',
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.exam_papers (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  exam_type text not null,
  level text not null,
  description text,
  questions jsonb not null default '[]'::jsonb,
  is_published boolean not null default false,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.student_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid references public.lessons(id) on delete cascade,
  completed_at timestamptz not null default now(),
  unique(student_id, lesson_id)
);

create table if not exists public.exam_results (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  paper_id uuid references public.exam_papers(id) on delete set null,
  score integer not null default 0,
  total integer not null default 0,
  submitted_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

alter table public.profiles enable row level security;
alter table public.lessons enable row level security;
alter table public.exam_papers enable row level security;
alter table public.student_progress enable row level security;
alter table public.exam_results enable row level security;

drop policy if exists "profiles read self or admin" on public.profiles;
create policy "profiles read self or admin" on public.profiles for select using (id = auth.uid() or public.is_admin());
drop policy if exists "profile self insert" on public.profiles;
create policy "profile self insert" on public.profiles for insert with check (id = auth.uid() and role = 'student');
drop policy if exists "admin update profiles" on public.profiles;
create policy "admin update profiles" on public.profiles for update using (public.is_admin()) with check (public.is_admin());

drop policy if exists "published lessons readable" on public.lessons;
create policy "published lessons readable" on public.lessons for select using (true);
drop policy if exists "admin manage lessons" on public.lessons;
create policy "admin manage lessons" on public.lessons for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "published exams readable" on public.exam_papers;
create policy "published exams readable" on public.exam_papers for select using (is_published = true or public.is_admin());
drop policy if exists "admin manage exams" on public.exam_papers;
create policy "admin manage exams" on public.exam_papers for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "student read own progress" on public.student_progress;
create policy "student read own progress" on public.student_progress for select using (student_id = auth.uid() or public.is_admin());
drop policy if exists "student write own progress" on public.student_progress;
create policy "student write own progress" on public.student_progress for all using (student_id = auth.uid()) with check (student_id = auth.uid());

drop policy if exists "student read own results" on public.exam_results;
create policy "student read own results" on public.exam_results for select using (student_id = auth.uid() or public.is_admin());
drop policy if exists "student write own results" on public.exam_results;
create policy "student write own results" on public.exam_results for insert with check (student_id = auth.uid());

-- Create a storage bucket named "learning-assets" in Storage, then apply these policies:
insert into storage.buckets (id, name, public) values ('learning-assets','learning-assets',true)
on conflict (id) do nothing;

drop policy if exists "public read learning assets" on storage.objects;
create policy "public read learning assets" on storage.objects for select using (bucket_id = 'learning-assets');
drop policy if exists "admin upload learning assets" on storage.objects;
create policy "admin upload learning assets" on storage.objects for insert with check (bucket_id = 'learning-assets' and public.is_admin());
drop policy if exists "admin update learning assets" on storage.objects;
create policy "admin update learning assets" on storage.objects for update using (bucket_id = 'learning-assets' and public.is_admin());
drop policy if exists "admin delete learning assets" on storage.objects;
create policy "admin delete learning assets" on storage.objects for delete using (bucket_id = 'learning-assets' and public.is_admin());

-- After creating your own Auth account, replace the UUID below with that account's id:
-- update public.profiles set role = 'admin' where id = 'YOUR-AUTH-USER-UUID';
