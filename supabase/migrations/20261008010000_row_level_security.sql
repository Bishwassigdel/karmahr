-- KarmaHR Row Level Security v1: who may see and change what.
--
-- Everything is worked out from the signed-in user's own profile row
-- (auth.uid() -> profiles), never from anything the app sends, so a user
-- can't claim another company or a higher role.
--
--   Logged out ............ nothing
--   Employee .............. own company's org (branches, departments, teams),
--                           own full employee record, and a colleague
--                           directory WITHOUT pay or bank details
--   Executive ............. reads everything in own company
--   HR, Company Admin ..... reads and changes own company's org and people
--   Everyone .............. never another company's rows; never their own
--                           role (no one can update profiles from the app)

-- ---------------------------------------------------------------------------
-- Helpers, in a schema the API does not expose. SECURITY DEFINER so they can
-- read profiles without tripping profiles' own policies; search_path is
-- pinned so they can't be hijacked.
-- ---------------------------------------------------------------------------

create schema if not exists private;
grant usage on schema private to authenticated;

create or replace function private.my_company_id()
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select p.company_id from public.profiles p where p.id = auth.uid()
$$;

create or replace function private.my_employee_id()
returns uuid
language sql stable security definer
set search_path = ''
as $$
  select p.employee_id from public.profiles p where p.id = auth.uid()
$$;

create or replace function private.my_role()
returns text
language sql stable security definer
set search_path = ''
as $$
  select r.key
  from public.profiles p
  join public.roles r on r.id = p.role_id
  where p.id = auth.uid()
$$;

-- HR and Company Admin manage the company's org and people.
create or replace function private.is_hr()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select coalesce(private.my_role() in ('hr', 'company_admin'), false)
$$;

-- Executives read the whole company but change nothing here.
create or replace function private.can_read_company()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select coalesce(
    private.my_role() in ('hr', 'company_admin', 'executive'), false)
$$;

revoke all on function private.my_company_id() from public;
revoke all on function private.my_employee_id() from public;
revoke all on function private.my_role() from public;
revoke all on function private.is_hr() from public;
revoke all on function private.can_read_company() from public;
grant execute on function private.my_company_id() to authenticated;
grant execute on function private.my_employee_id() to authenticated;
grant execute on function private.my_role() to authenticated;
grant execute on function private.is_hr() to authenticated;
grant execute on function private.can_read_company() to authenticated;

-- Calls are wrapped in (select ...) below so Postgres works each one out
-- once per query, not once per row.

-- ---------------------------------------------------------------------------
-- companies: see your own; Company Admin may rename it.
-- ---------------------------------------------------------------------------

create policy "companies: read own"
  on public.companies for select to authenticated
  using (id = (select private.my_company_id()));

create policy "companies: admin renames own"
  on public.companies for update to authenticated
  using (id = (select private.my_company_id())
         and (select private.my_role()) = 'company_admin')
  with check (id = (select private.my_company_id()));

-- ---------------------------------------------------------------------------
-- roles: the built-in roles plus your company's own. Read-only from the app.
-- ---------------------------------------------------------------------------

create policy "roles: read built-in and own"
  on public.roles for select to authenticated
  using (company_id is null or company_id = (select private.my_company_id()));

-- ---------------------------------------------------------------------------
-- profiles: read your own; HR reads the company's. No one writes from the
-- app: logins are created on the server (Day 7), so nobody can change their
-- own role or company.
-- ---------------------------------------------------------------------------

create policy "profiles: read own"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()));

create policy "profiles: HR reads company"
  on public.profiles for select to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()));

-- ---------------------------------------------------------------------------
-- branches, departments, teams, team_members: everyone in the company reads
-- them; HR changes them.
-- ---------------------------------------------------------------------------

create policy "branches: read company"
  on public.branches for select to authenticated
  using (company_id = (select private.my_company_id()));
create policy "branches: HR adds"
  on public.branches for insert to authenticated
  with check (company_id = (select private.my_company_id())
              and (select private.is_hr()));
create policy "branches: HR changes"
  on public.branches for update to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()))
  with check (company_id = (select private.my_company_id()));
create policy "branches: HR removes"
  on public.branches for delete to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()));

create policy "departments: read company"
  on public.departments for select to authenticated
  using (company_id = (select private.my_company_id()));
create policy "departments: HR adds"
  on public.departments for insert to authenticated
  with check (company_id = (select private.my_company_id())
              and (select private.is_hr()));
create policy "departments: HR changes"
  on public.departments for update to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()))
  with check (company_id = (select private.my_company_id()));
create policy "departments: HR removes"
  on public.departments for delete to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()));

create policy "teams: read company"
  on public.teams for select to authenticated
  using (company_id = (select private.my_company_id()));
create policy "teams: HR adds"
  on public.teams for insert to authenticated
  with check (company_id = (select private.my_company_id())
              and (select private.is_hr()));
create policy "teams: HR changes"
  on public.teams for update to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()))
  with check (company_id = (select private.my_company_id()));
create policy "teams: HR removes"
  on public.teams for delete to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()));

create policy "team_members: read company"
  on public.team_members for select to authenticated
  using (company_id = (select private.my_company_id()));
create policy "team_members: HR adds"
  on public.team_members for insert to authenticated
  with check (company_id = (select private.my_company_id())
              and (select private.is_hr()));
create policy "team_members: HR removes"
  on public.team_members for delete to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()));

-- ---------------------------------------------------------------------------
-- employees: the full record holds pay and bank details.
--   * HR, Company Admin and Executive read the company's records
--   * an employee reads only their own
--   * only HR adds, changes or removes, and only in their own company
-- Colleagues are seen through company_directory() below instead.
-- ---------------------------------------------------------------------------

create policy "employees: managers of the company read"
  on public.employees for select to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.can_read_company()));

create policy "employees: read own record"
  on public.employees for select to authenticated
  using (id = (select private.my_employee_id()));

create policy "employees: HR adds"
  on public.employees for insert to authenticated
  with check (company_id = (select private.my_company_id())
              and (select private.is_hr()));
create policy "employees: HR changes"
  on public.employees for update to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()))
  with check (company_id = (select private.my_company_id()));
create policy "employees: HR removes"
  on public.employees for delete to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()));

-- The colleague directory: everyone in your company, without pay or bank
-- details. A function rather than a view so it can show colleagues the
-- caller can't read in the table itself, while choosing the safe columns.
create or replace function public.company_directory()
returns table (
  id uuid,
  staff_id text,
  name text,
  job_title text,
  department_id uuid,
  branch_id uuid,
  manager_id uuid,
  joining_date date,
  employment_type text,
  work_location text,
  email text,
  phone text,
  status text
)
language sql stable security definer
set search_path = ''
as $$
  select e.id, e.staff_id, e.name, e.job_title, e.department_id,
         e.branch_id, e.manager_id, e.joining_date, e.employment_type,
         e.work_location, e.email, e.phone, e.status
  from public.employees e
  where e.company_id = private.my_company_id()
  order by e.name
$$;

revoke all on function public.company_directory() from public, anon;
grant execute on function public.company_directory() to authenticated;
