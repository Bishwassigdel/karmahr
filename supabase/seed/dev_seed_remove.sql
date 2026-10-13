-- Removes everything dev_seed.sql created: its two companies (with their
-- employees, teams and so on) and its eight logins. Anything else in the
-- project, including logins you made by hand, is left alone.

delete from auth.users
  where email like '%@himalaya-tech.test'
     or email like '%@everest-traders.test';

delete from public.companies
  where id in ('a0000000-0000-4000-8000-000000000001',
               'b0000000-0000-4000-8000-000000000001');
