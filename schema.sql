-- 英単語ノート：Supabaseセットアップ用SQL
-- Supabaseダッシュボード → SQL Editor に貼り付けて実行してください

create extension if not exists pgcrypto;

create table if not exists vocab_students (
  id uuid primary key default gen_random_uuid(),
  branch text not null,
  name text not null,
  created_at timestamptz not null default now(),
  unique (branch, name)
);

create table if not exists vocab_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references vocab_students(id) on delete cascade,
  word text not null,
  level int not null,
  status int not null default 0, -- 0=わからない 1=あやふや 2=覚えた
  updated_at timestamptz not null default now(),
  unique (student_id, word)
);

alter table vocab_students enable row level security;
alter table vocab_progress enable row level security;

-- 簡易運用のためanonキーからの読み書きを許可しています。
-- 生徒はパスワード無しで名前だけを入力する想定のため、
-- 「同じ校舎・名前を入力すれば誰でも進捗を見られる/書き換えられる」点はご了承ください。
-- (厳密な本人認証が必要な場合は別途ログイン機能の追加が必要です)
create policy "allow anon all students" on vocab_students
  for all using (true) with check (true);

create policy "allow anon all progress" on vocab_progress
  for all using (true) with check (true);
