-- KarmaHR: inviting employees to sign in.
--
-- How it works, with no secret key and no server code:
--   1. HR invites an existing employee: one row in `invites` (their email).
--   2. The employee opens the app, taps "Activate your account", and signs up
--      with that email and a password of their own. Supabase emails a code
--      to that address.
--   3. When they enter the code, their email becomes CONFIRMED. The trigger
--      below then finds the invite for that email and creates their profile
--      (company, employee role, employee record).
--
-- Why it is safe:
--   * The profile is created only once the email is confirmed, so knowing an
--     invited address is not enough: you must be able to read its mailbox.
--     (Keep "Confirm email" ON in Supabase > Authentication > Providers.)
--   * Without an invite, signing up gives a login with no profile, which
--     sees nothing (Day 5 rules).
--   * An invite is used once, and never for a deactivated employee.
--   * Only HR can write invites, only in their own company.

create table public.invites (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies (id) on delete cascade,
  employee_id uuid not null,
  email text not null check (position('@' in email) > 1),
  created_at timestamptz not null default now(),
  accepted_at timestamptz,
  foreign key (company_id, employee_id)
    references public.employees (company_id, id) on delete cascade
);
-- One open invite per employee: inviting again replaces it.
create unique index invites_one_open_per_employee
  on public.invites (employee_id) where accepted_at is null;
create index invites_email_idx on public.invites (lower(email));

alter table public.invites enable row level security;

create policy "invites: HR reads company"
  on public.invites for select to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr()));
create policy "invites: HR creates"
  on public.invites for insert to authenticated
  with check (company_id = (select private.my_company_id())
              and (select private.is_hr())
              and accepted_at is null);
create policy "invites: HR cancels"
  on public.invites for delete to authenticated
  using (company_id = (select private.my_company_id())
         and (select private.is_hr())
         and accepted_at is null);
-- No update policy: only the trigger below marks an invite as used.

-- Runs when a login is created or its email gets confirmed.
create or replace function private.accept_invite()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
declare
  inv record;
begin
  if new.email is null or new.email_confirmed_at is null then
    return new;
  end if;
  if exists (select 1 from public.profiles where id = new.id) then
    return new;
  end if;

  select i.id, i.company_id, i.employee_id, e.name
    into inv
  from public.invites i
  join public.employees e
    on e.company_id = i.company_id and e.id = i.employee_id
  where lower(i.email) = lower(new.email)
    and i.accepted_at is null
    and e.status = 'active'
    -- the employee must not already have a login
    and not exists (select 1 from public.profiles p
                    where p.company_id = i.company_id
                      and p.employee_id = i.employee_id)
  order by i.created_at desc
  limit 1;
  if not found then
    return new;
  end if;

  insert into public.profiles (id, company_id, role_id, employee_id, full_name)
  values (
    new.id, inv.company_id,
    (select r.id from public.roles r
      where r.key = 'employee' and r.company_id is null),
    inv.employee_id, inv.name);
  update public.invites set accepted_at = now() where id = inv.id;
  return new;
exception when others then
  -- Never block someone from signing up because of the invite.
  return new;
end;
$$;

revoke all on function private.accept_invite() from public;

create trigger accept_invite_on_signup
  after insert or update of email_confirmed_at on auth.users
  for each row execute function private.accept_invite();
