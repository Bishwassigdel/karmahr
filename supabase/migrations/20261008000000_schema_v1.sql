-- KarmaHR schema v1: the organisation and its people.
--
-- Every company-owned row carries company_id, and every link between two
-- company rows includes company_id in the foreign key, so a row can never
-- point at another company's data (an employee can't sit in another
-- company's department, a team can't contain another company's employee).
--
-- Row Level Security is switched ON for every table here, with no policies
-- yet: until Day 5 adds them, the app's publishable key can read nothing.
-- Locked by default is the safe starting point.

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Companies (tenants)
-- ---------------------------------------------------------------------------

create table public.companies (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Roles. company_id null = a built-in role every company has; later a
-- company can add its own custom roles. Permissions arrive with Day 5.
-- ---------------------------------------------------------------------------

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies (id) on delete cascade,
  key text not null check (key ~ '^[a-z][a-z_]*$'),
  name text not null,
  unique nulls not distinct (company_id, key)
);

insert into public.roles (company_id, key, name) values
  (null, 'company_admin', 'Company Admin'),
  (null, 'hr', 'HR'),
  (null, 'executive', 'Executive'),
  (null, 'employee', 'Employee');
-- A team head is an employee who leads a team (teams.head_employee_id),
-- not a separate role.

-- ---------------------------------------------------------------------------
-- Branches and departments
-- ---------------------------------------------------------------------------

create table public.branches (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  city text not null default '',
  created_at timestamptz not null default now(),
  unique (company_id, id)
);
create unique index branches_company_name_key
  on public.branches (company_id, lower(name));

create table public.departments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  created_at timestamptz not null default now(),
  unique (company_id, id)
);
create unique index departments_company_name_key
  on public.departments (company_id, lower(name));

-- ---------------------------------------------------------------------------
-- Employees. Mirrors EmployeeRecord in lib/state/employee_records_state.dart.
-- Money is monthly NPR. Salary and bank columns are sensitive: Day 5's
-- policies limit who may read them.
-- ---------------------------------------------------------------------------

create table public.employees (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  staff_id text not null check (length(trim(staff_id)) > 0), -- e.g. MB-24071
  name text not null check (length(trim(name)) > 0),
  job_title text not null check (length(trim(job_title)) > 0),
  department_id uuid,
  branch_id uuid,
  manager_id uuid,
  joining_date date not null,
  employment_type text not null default 'Full-Time'
    check (employment_type in ('Full-Time', 'Part-Time', 'Contract', 'Intern')),
  work_location text not null default '',
  email text not null default '',
  phone text not null default '',
  basic_salary numeric(12, 2) not null default 0 check (basic_salary >= 0),
  dearness_allowance numeric(12, 2) not null default 0
    check (dearness_allowance >= 0),
  transport_allowance numeric(12, 2) not null default 0
    check (transport_allowance >= 0),
  filing_status text not null default 'single'
    check (filing_status in ('single', 'married')),
  status text not null default 'active'
    check (status in ('active', 'inactive')),
  bank_name text not null default '',
  account_number text not null default ''
    check (account_number ~ '^[0-9]*$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, id),
  unique (company_id, staff_id),
  check (manager_id is null or manager_id <> id),
  foreign key (company_id, department_id)
    references public.departments (company_id, id) on delete set null (department_id),
  foreign key (company_id, branch_id)
    references public.branches (company_id, id) on delete set null (branch_id),
  foreign key (company_id, manager_id)
    references public.employees (company_id, id) on delete set null (manager_id)
);
create unique index employees_company_email_key
  on public.employees (company_id, lower(email)) where email <> '';
create index employees_department_idx on public.employees (department_id);
create index employees_branch_idx on public.employees (branch_id);
create index employees_manager_idx on public.employees (manager_id);

create trigger employees_set_updated_at
  before update on public.employees
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- User profiles: one per login (auth.users). Links a login to its company,
-- its role and, for most people, their employee record.
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  company_id uuid not null references public.companies (id) on delete cascade,
  role_id uuid not null references public.roles (id),
  employee_id uuid,
  full_name text not null default '',
  created_at timestamptz not null default now(),
  unique (company_id, employee_id),
  foreign key (company_id, employee_id)
    references public.employees (company_id, id) on delete set null (employee_id)
);
create index profiles_company_idx on public.profiles (company_id);

-- ---------------------------------------------------------------------------
-- Teams. HR makes a team, adds members and picks one member as head; the
-- head may assign work to the other members. Rules from the app's
-- TeamsState, enforced here too:
--   * names are unique in a company (ignoring case)
--   * the head must be a member of the team
--   * a person can lead only one team
--   * removing the head from the team leaves the team with no head
-- ---------------------------------------------------------------------------

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  department_id uuid,
  head_employee_id uuid,
  created_at timestamptz not null default now(),
  unique (company_id, id),
  foreign key (company_id, department_id)
    references public.departments (company_id, id) on delete set null (department_id)
);
create unique index teams_company_name_key
  on public.teams (company_id, lower(name));
create unique index teams_one_team_per_head
  on public.teams (head_employee_id) where head_employee_id is not null;

create table public.team_members (
  company_id uuid not null,
  team_id uuid not null,
  employee_id uuid not null,
  added_at timestamptz not null default now(),
  primary key (team_id, employee_id),
  foreign key (company_id, team_id)
    references public.teams (company_id, id) on delete cascade,
  foreign key (company_id, employee_id)
    references public.employees (company_id, id) on delete cascade
);
create index team_members_employee_idx on public.team_members (employee_id);

-- The head must be a member. Checked at the end of the transaction, so a
-- team can be given a member and a head in one go. Removing that member
-- clears the head.
alter table public.teams
  add constraint teams_head_is_member
  foreign key (id, head_employee_id)
  references public.team_members (team_id, employee_id)
  on delete set null (head_employee_id)
  deferrable initially deferred;

-- ---------------------------------------------------------------------------
-- Locked until Day 5 adds policies.
-- ---------------------------------------------------------------------------

alter table public.companies enable row level security;
alter table public.roles enable row level security;
alter table public.branches enable row level security;
alter table public.departments enable row level security;
alter table public.employees enable row level security;
alter table public.profiles enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
