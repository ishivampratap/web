-- Run this once in Supabase: SQL Editor > New query > paste > Run.
-- Before running, replace owner@example.com (3 places below use the same email)
-- with Dr. Gautam's real email address, in lowercase.

create table if not exists public.site_content (
  id int primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

alter table public.site_content enable row level security;

-- Everyone can read the site content
create policy "Public can read content" on public.site_content
  for select using (true);

-- Only the owner can create or change it
create policy "Owner can insert content" on public.site_content
  for insert to authenticated
  with check ((auth.jwt() ->> 'email') = 'akg@nerist.ac.in');

create policy "Owner can update content" on public.site_content
  for update to authenticated
  using ((auth.jwt() ->> 'email') = 'akg@nerist.ac.in')
  with check ((auth.jwt() ->> 'email') = 'akg@nerist.ac.in');

-- Image storage (public to view, owner only to change)
insert into storage.buckets (id, name, public)
values ('site-images', 'site-images', true)
on conflict (id) do nothing;

create policy "Public can view images" on storage.objects
  for select using (bucket_id = 'site-images');

create policy "Owner can upload images" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'site-images' and (auth.jwt() ->> 'email') = 'akg@nerist.ac.in');

create policy "Owner can update images" on storage.objects
  for update to authenticated
  using (bucket_id = 'site-images' and (auth.jwt() ->> 'email') = 'akg@nerist.ac.in');

create policy "Owner can delete images" on storage.objects
  for delete to authenticated
  using (bucket_id = 'site-images' and (auth.jwt() ->> 'email') = 'akg@nerist.ac.in');
