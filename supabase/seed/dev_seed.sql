-- KarmaHR test data: TWO companies, with a login for every role.
-- FOR A DEVELOPMENT / TEST PROJECT ONLY. Never run this on a project that
-- holds real people: it creates logins that share one password.
--
-- How to use: set the test password on the line marked CHANGE-ME below
-- (12+ characters), then run the whole script in the Supabase SQL Editor.
-- Running it again wipes this seed data and recreates it, so it is safe to
-- repeat. It only ever touches the two companies and eight logins named
-- here; any other company or login you made by hand is left alone.
-- To remove everything it made, run dev_seed_remove.sql.
--
-- The logins (all use the one password you set):
--
--   Himalaya Tech Pvt Ltd                  Everest Traders
--   admin@himalaya-tech.test  Company Admin  hr@everest-traders.test    HR
--   hr@himalaya-tech.test     HR             mina@everest-traders.test  Employee
--   exec@himalaya-tech.test   Executive
--   sita@himalaya-tech.test   Employee (leads "Support Team")
--   ram@himalaya-tech.test    Employee
--   gita@himalaya-tech.test   Employee
--
-- Two companies, so the isolation rules can be tried for real: signed in as
-- hr@himalaya-tech.test you must never see anything of Everest Traders.

do $seed$
declare
  pw constant text := 'CHANGE-ME';   -- <- the one place to set the password

  co_a constant uuid := 'a0000000-0000-4000-8000-000000000001';
  co_b constant uuid := 'b0000000-0000-4000-8000-000000000001';
  hash text;
begin
  if pw = 'CHANGE-ME' or length(pw) < 12 then
    raise exception
      'Set a test password (12 or more characters) on the line marked CHANGE-ME, then run the script again.';
  end if;
  hash := extensions.crypt(pw, extensions.gen_salt('bf'));

  -- 1. Clear any earlier run of this seed (and nothing else).
  delete from auth.users
    where email like '%@himalaya-tech.test'
       or email like '%@everest-traders.test';
  delete from public.companies where id in (co_a, co_b);

  -- 2. The companies, their branches and departments.
  insert into public.companies (id, name) values
    (co_a, 'Himalaya Tech Pvt Ltd'),
    (co_b, 'Everest Traders');

  insert into public.branches (id, company_id, name, city) values
    ('a0000000-0000-4000-8000-0000000000b1', co_a, 'Kathmandu Head Office', 'Kathmandu'),
    ('b0000000-0000-4000-8000-0000000000b1', co_b, 'Pokhara Office', 'Pokhara');

  insert into public.departments (id, company_id, name) values
    ('a0000000-0000-4000-8000-0000000000d1', co_a, 'Human Resources'),
    ('a0000000-0000-4000-8000-0000000000d2', co_a, 'Support'),
    ('a0000000-0000-4000-8000-0000000000d3', co_a, 'Engineering'),
    ('b0000000-0000-4000-8000-0000000000d1', co_b, 'Administration'),
    ('b0000000-0000-4000-8000-0000000000d2', co_b, 'Sales');

  -- 3. The people. Pay is monthly NPR (basic, dearness, transport).
  insert into public.employees
    (id, company_id, staff_id, name, job_title, department_id, branch_id,
     joining_date, employment_type, work_location, email,
     basic_salary, dearness_allowance, transport_allowance)
  values
    ('a0000000-0000-4000-8000-0000000000e1', co_a, 'HT-001', 'Hari Hr',
     'HR Manager', 'a0000000-0000-4000-8000-0000000000d1',
     'a0000000-0000-4000-8000-0000000000b1', '2023-04-10', 'Full-Time',
     'Kathmandu Head Office', 'hr@himalaya-tech.test', 60000, 5000, 3000),
    ('a0000000-0000-4000-8000-0000000000e2', co_a, 'HT-002', 'Eka Exec',
     'Chief Executive Officer', null,
     'a0000000-0000-4000-8000-0000000000b1', '2022-01-15', 'Full-Time',
     'Kathmandu Head Office', 'exec@himalaya-tech.test', 150000, 10000, 5000),
    ('a0000000-0000-4000-8000-0000000000e3', co_a, 'HT-003', 'Sita Employee',
     'Support Agent', 'a0000000-0000-4000-8000-0000000000d2',
     'a0000000-0000-4000-8000-0000000000b1', '2025-03-01', 'Full-Time',
     'Kathmandu Head Office', 'sita@himalaya-tech.test', 30000, 2000, 1000),
    ('a0000000-0000-4000-8000-0000000000e4', co_a, 'HT-004', 'Ram Employee',
     'Support Agent', 'a0000000-0000-4000-8000-0000000000d2',
     'a0000000-0000-4000-8000-0000000000b1', '2025-06-16', 'Full-Time',
     'Kathmandu Head Office', 'ram@himalaya-tech.test', 32000, 2000, 1000),
    ('a0000000-0000-4000-8000-0000000000e5', co_a, 'HT-005', 'Gita Employee',
     'Software Engineer', 'a0000000-0000-4000-8000-0000000000d3',
     'a0000000-0000-4000-8000-0000000000b1', '2024-09-02', 'Full-Time',
     'Kathmandu Head Office', 'gita@himalaya-tech.test', 55000, 4000, 2000),
    ('b0000000-0000-4000-8000-0000000000e1', co_b, 'ET-001', 'Binod Hr',
     'HR Manager', 'b0000000-0000-4000-8000-0000000000d1',
     'b0000000-0000-4000-8000-0000000000b1', '2021-11-01', 'Full-Time',
     'Pokhara Office', 'hr@everest-traders.test', 52000, 4000, 2500),
    ('b0000000-0000-4000-8000-0000000000e2', co_b, 'ET-002', 'Mina Employee',
     'Sales Executive', 'b0000000-0000-4000-8000-0000000000d2',
     'b0000000-0000-4000-8000-0000000000b1', '2024-02-20', 'Full-Time',
     'Pokhara Office', 'mina@everest-traders.test', 28000, 2000, 1000);

  -- Sita, Ram and Gita report to Hari; Mina reports to Binod.
  update public.employees set manager_id = 'a0000000-0000-4000-8000-0000000000e1'
    where id in ('a0000000-0000-4000-8000-0000000000e3',
                 'a0000000-0000-4000-8000-0000000000e4',
                 'a0000000-0000-4000-8000-0000000000e5');
  update public.employees set manager_id = 'b0000000-0000-4000-8000-0000000000e1'
    where id = 'b0000000-0000-4000-8000-0000000000e2';

  -- 4. One team: Sita leads, Ram is a member.
  insert into public.teams (id, company_id, name, department_id, head_employee_id)
  values ('a0000000-0000-4000-8000-0000000000f1', co_a, 'Support Team',
          'a0000000-0000-4000-8000-0000000000d2',
          'a0000000-0000-4000-8000-0000000000e3');
  insert into public.team_members (company_id, team_id, employee_id) values
    (co_a, 'a0000000-0000-4000-8000-0000000000f1', 'a0000000-0000-4000-8000-0000000000e3'),
    (co_a, 'a0000000-0000-4000-8000-0000000000f1', 'a0000000-0000-4000-8000-0000000000e4');

  -- 5. The logins: auth.users + auth.identities (what makes an email and
  -- password sign-in work) + our own profiles row (company, role, employee).
  -- The token columns must be '' not null, or Supabase's login fails.
  with acct(id, email, full_name, role_key, company_id, employee_id) as (
    values
      ('a1000000-0000-4000-8000-000000000001'::uuid, 'admin@himalaya-tech.test', 'Adi Admin',      'company_admin', co_a, null::uuid),
      ('a1000000-0000-4000-8000-000000000002'::uuid, 'hr@himalaya-tech.test',    'Hari Hr',        'hr',            co_a, 'a0000000-0000-4000-8000-0000000000e1'::uuid),
      ('a1000000-0000-4000-8000-000000000003'::uuid, 'exec@himalaya-tech.test',  'Eka Exec',       'executive',     co_a, 'a0000000-0000-4000-8000-0000000000e2'::uuid),
      ('a1000000-0000-4000-8000-000000000004'::uuid, 'sita@himalaya-tech.test',  'Sita Employee',  'employee',      co_a, 'a0000000-0000-4000-8000-0000000000e3'::uuid),
      ('a1000000-0000-4000-8000-000000000005'::uuid, 'ram@himalaya-tech.test',   'Ram Employee',   'employee',      co_a, 'a0000000-0000-4000-8000-0000000000e4'::uuid),
      ('a1000000-0000-4000-8000-000000000006'::uuid, 'gita@himalaya-tech.test',  'Gita Employee',  'employee',      co_a, 'a0000000-0000-4000-8000-0000000000e5'::uuid),
      ('b1000000-0000-4000-8000-000000000001'::uuid, 'hr@everest-traders.test',  'Binod Hr',       'hr',            co_b, 'b0000000-0000-4000-8000-0000000000e1'::uuid),
      ('b1000000-0000-4000-8000-000000000002'::uuid, 'mina@everest-traders.test','Mina Employee',  'employee',      co_b, 'b0000000-0000-4000-8000-0000000000e2'::uuid)
  ),
  users as (
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, confirmation_token, recovery_token,
      email_change_token_new, email_change, email_change_token_current,
      phone_change, phone_change_token, reauthentication_token,
      raw_app_meta_data, raw_user_meta_data, is_super_admin,
      created_at, updated_at)
    select
      '00000000-0000-0000-0000-000000000000', a.id, 'authenticated',
      'authenticated', a.email, hash,
      now(), '', '', '', '', '', '', '', '',
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', a.full_name), false,
      now(), now()
    from acct a
    returning id
  ),
  identities as (
    insert into auth.identities (
      id, user_id, identity_data, provider, provider_id,
      last_sign_in_at, created_at, updated_at)
    select
      gen_random_uuid(), a.id,
      jsonb_build_object('sub', a.id::text, 'email', a.email,
                         'email_verified', true, 'phone_verified', false),
      'email', a.id::text, now(), now(), now()
    from acct a
    returning user_id
  )
  insert into public.profiles (id, company_id, role_id, employee_id, full_name)
  select a.id, a.company_id, r.id, a.employee_id, a.full_name
  from acct a
  join public.roles r on r.key = a.role_key and r.company_id is null;
end
$seed$;
