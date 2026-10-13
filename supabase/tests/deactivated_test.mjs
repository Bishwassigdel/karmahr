// A deactivated employee must be locked out by the database itself, not just
// by the app: even with a valid login they read and change nothing.

import { freshDatabase, asUser, runner, expectEqual } from './helpers.mjs';

const db = await freshDatabase();
const t = runner();

const A = 'aaaaaaaa-0000-0000-0000-000000000000';
const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const eHr = id(101), eEmp = id(102), eBoss = id(103);
const uHr = id(1), uEmp = id(2), uExec = id(3), uBoss = id(4);
const role = (key) => `(select id from public.roles where key = '${key}' and company_id is null)`;

await db.exec(`
  insert into companies (id, name) values ('${A}', 'Karma');
  insert into employees (id, company_id, staff_id, name, job_title, joining_date, basic_salary) values
    ('${eHr}',   '${A}', 'A-1', 'Hari HR',    'HR Officer', '2024-01-01', 60000),
    ('${eEmp}',  '${A}', 'A-2', 'Sita Staff', 'Agent',      '2024-01-01', 40000),
    ('${eBoss}', '${A}', 'A-3', 'Bhim Boss',  'Manager',    '2024-01-01', 90000);
  insert into auth.users (id) values ('${uHr}'), ('${uEmp}'), ('${uExec}'), ('${uBoss}');
  insert into profiles (id, company_id, role_id, employee_id) values
    ('${uHr}',   '${A}', ${role('hr')},        '${eHr}'),
    ('${uEmp}',  '${A}', ${role('employee')},  '${eEmp}'),
    ('${uExec}', '${A}', ${role('executive')}, null),
    ('${uBoss}', '${A}', ${role('hr')},        '${eBoss}');
`);

const rows = async (u, sql) => (await asUser(db, u, sql)).rows;
const count = async (u, sql) => (await rows(u, sql)).length;
const active = async (u) => (await rows(u, `select account_is_active() as ok`))[0].ok;

await t.check('while active, an employee reads their company', async () => {
  expectEqual(await count(uEmp, `select * from company_directory()`), 3);
  expectEqual(await count(uEmp, `select * from employees`), 1);
  expectEqual(await active(uEmp), true);
});

// HR deactivates Sita, and Hari (HR) as the owner would see it.
await db.exec(`update employees set status = 'inactive' where id = '${eEmp}'`);

await t.check('a deactivated employee sees no company data at all', async () => {
  expectEqual(await count(uEmp, `select * from company_directory()`), 0, 'directory');
  for (const tb of ['employees', 'departments', 'branches', 'teams', 'team_members', 'companies']) {
    expectEqual(await count(uEmp, `select * from ${tb}`), 0, tb);
  }
});
await t.check('they cannot even read their own employee record', async () => {
  expectEqual(await count(uEmp, `select * from employees where id = '${eEmp}'`), 0);
});
await t.check('they can still read their own profile, and are told the account is off', async () => {
  expectEqual(await count(uEmp, `select * from profiles`), 1);
  expectEqual(await active(uEmp), false);
});
await t.check('they cannot change anything', async () => {
  expectEqual(await count(uEmp, `update employees set basic_salary = 1 returning id`), 0);
  expectEqual(await count(uEmp, `update employees set status = 'active' where id = '${eEmp}' returning id`), 0);
});
await t.check('a deactivated HR person loses HR powers too', async () => {
  await db.exec(`update employees set status = 'inactive' where id = '${eBoss}'`);
  expectEqual(await count(uBoss, `select * from employees`), 0);
  expectEqual(await count(uBoss, `update employees set job_title = 'x' returning id`), 0);
  expectEqual(await active(uBoss), false);
});
await t.check('everyone else is untouched', async () => {
  expectEqual(await active(uHr), true);
  expectEqual(await count(uHr, `select * from employees`), 3);
  expectEqual(await active(uExec), true); // no employee record: not affected
  expectEqual(await count(uExec, `select * from employees`), 3);
});
await t.check('HR can bring the person back, and access returns', async () => {
  expectEqual(await count(uHr, `update employees set status = 'active' where id = '${eEmp}' returning id`), 1);
  // (the rollback in asUser undoes it, so re-activate as the owner)
  await db.exec(`update employees set status = 'active' where id = '${eEmp}'`);
  expectEqual(await active(uEmp), true);
  expectEqual(await count(uEmp, `select * from company_directory()`), 3);
});
await t.check('a login with no profile is not "active"', async () => {
  expectEqual(await active(id(99)), false);
});
await t.check('logged out cannot ask', async () => {
  try { await asUser(db, null, `select account_is_active()`); } catch { return; }
  throw new Error('was allowed');
});

t.done();
