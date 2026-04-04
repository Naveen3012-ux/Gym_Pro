-- Face recognition mapping table
create table if not exists public.member_faces (
  member_id text primary key,
  face_token text not null unique,
  created_at timestamp with time zone default now()
);

-- Allow service role and authenticated users to read/write (adjust as needed)
alter table public.member_faces enable row level security;

create policy "service-role all" on public.member_faces
  for all
  to service_role
  using (true)
  with check (true);
