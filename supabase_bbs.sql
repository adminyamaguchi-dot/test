-- ご意見掲示板 (Supabase / PostgreSQL)
-- Supabase の SQL Editor に貼り付けて実行してください。

-- 1. テーブル
create table if not exists public.posts (
  id         bigint generated always as identity primary key,
  nickname   text not null check (char_length(nickname) between 1 and 20),
  message    text not null check (char_length(message)  between 1 and 500),
  created_at timestamptz not null default now()
);

create index if not exists posts_created_at_idx on public.posts (created_at desc);

-- 2. RLS を有効化
alter table public.posts enable row level security;

-- 3. ポリシー
-- 閲覧: 誰でも（未ログインの anon / ログイン済みの authenticated）可
create policy "posts_select_all"
  on public.posts for select
  to anon, authenticated
  using (true);

-- 書き込み: 誰でも可（入力内容は with check と上の check 制約で検証）
create policy "posts_insert_all"
  on public.posts for insert
  to anon, authenticated
  with check (
    char_length(btrim(nickname)) between 1 and 20
    and char_length(btrim(message)) between 1 and 500
  );

-- update / delete のポリシーは作成しない = anon・authenticated は編集・削除不可
-- （削除などの管理操作は、RLS をバイパスする service_role か、ダッシュボードから行う）

-- 4. ダミーデータ
-- SQL Editor は postgres ロールで実行されるため、RLS に関係なく投入できます。
insert into public.posts (nickname, message, created_at) values
  ('パンダ好き', 'パンダの展示がとても良かったです！', now() - interval '3 days'),
  ('たろう',     'ナイトズーをもっと増やしてほしいです。', now() - interval '2 days'),
  ('はなこ',     'ペンギンパレードに子どもが大喜びでした。', now() - interval '1 day'),
  ('ゾウさん',   'ゾウのシャワータイム、迫力がありました。',   now() - interval '3 hours');
