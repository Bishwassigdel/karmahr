-- KarmaHR: a deactivated employee can no longer use the system.
--
-- Until now, setting an employee to "inactive" only changed a label: their
-- login kept working and Row Level Security still let them read the company.
-- Every policy works out "who is this?" through the helpers below, so the fix
-- lives in one place: for a person whose employee record is inactive, the
-- helpers answer "nobody" (NULL), and every policy then refuses them.
--
-- Accounts with no employee record (Executive, Company Admin) are unaffected.
-- The person can still read their own profile row (so the app can tell them
-- why), but nothing else.

create or replace function private.my_company_id()
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select p.company_id
  from public.profiles p
  left join public.employees e on e.id = p.employee_id
  where p.id = auth.uid() and coalesce(e.status, 'active') = 'active'
$$;

create or replace function private.my_employee_id()
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select p.employee_id
  from public.profiles p
  left join public.employees e on e.id = p.employee_id
  where p.id = auth.uid() and coalesce(e.status, 'active') = 'active'
$$;

create or replace function private.my_role()
returns text
language sql stable security definer
set search_path = ''
as $$
  select r.key
  from public.profiles p
  join public.roles r on r.id = p.role_id
  left join public.employees e on e.id = p.employee_id
  where p.id = auth.uid() and coalesce(e.status, 'active') = 'active'
$$;

-- Lets the app ask, right after sign-in: "is my account switched off?"
-- true = fine, false = deactivated (or no profile). Only about the caller.
create or replace function public.account_is_active()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    left join public.employees e on e.id = p.employee_id
    where p.id = auth.uid() and coalesce(e.status, 'active') = 'active'
  )
$$;

revoke all on function public.account_is_active() from public, anon;
grant execute on function public.account_is_active() to authenticated;
