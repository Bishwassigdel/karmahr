// Row Level Security: sign in as different people from two companies and
// check what each can and can't read or change. The point of the whole
// file: one company must never see or touch another company's rows.

import { freshDatabase, asUser, runner, expectEqual } from './helpers.mjs';

const db = await freshDatabase();
const t = runner();

// Two companies with people, as the database owner (bypasses RLS).
const A = 'aaaaaaaa-0000-0000-0000-000000000000';
const B = 'bbbbbbbb-0000-0000-0000-000000000000';
const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const eHrA = id(101), eEmpA = id(102), eOtherA = id(103), eEmpB = id(201), eHrB = id(202);
const uHrA = id(1), uAdminA = id(2), uExecA = id(3), uEmpA = id(4);
const uHrB = id(5), uEmpB = id(6), uNoProfile = id(7);
const role = (key) => `(select id from public.roles where key = '${key}' and company_id is null)`;

await db.exec(`
  insert into companies (id, name) values ('${A}', 'Karma'), ('${B}', 'Other Co');
  insert into departments (id, company_id, name) values
    ('${id(11)}', '${A}', 'Support'), ('${id(21)}', '${B}', 'Support');
  insert into employees (id, company_id, staff_id, name, job_title, joining_date,
                         basic_salary, bank_name, account_number) values
    ('${eHrA}',    '${A}', 'A-1', 'Hari HR',     'HR Officer', '2024-01-01', 60000, 'NIC', '111'),
    ('${eEmpA}',   '${A}', 'A-2', 'Sita Staff',  'Agent',      '2024-01-01', 40000, 'NIC', '222'),
    ('${eOtherA}', '${A}', 'A-3', 'Ram Agent',   'Agent',      '2024-01-01', 41000, 'NIC', '333'),
    ('${eEmpB}',   '${B}', 'B-1', 'Bina Other',  'Agent',      '2024-01-01', 50000, 'NIC', '444'),
    ('${eHrB}',    '${B}', 'B-2', 'Bikash HR',   'HR Officer', '2024-01-01', 70000, 'NIC', '555');
  insert into auth.users (id) values
    ('${uHrA}'), ('${uAdminA}'), ('${uExecA}'), ('${uEmpA}'),
    ('${uHrB}'), ('${uEmpB}'), ('${uNoProfile}');
  insert into profiles (id, company_id, role_id, employee_id) values
    ('${uHrA}',    '${A}', ${role('hr')},            '${eHrA}'),
    ('${uAdminA}', '${A}', ${role('company_admin')}, null),
    ('${uExecA}',  '${A}', ${role('executive')},     null),
    ('${uEmpA}',   '${A}', ${role('employee')},      '${eEmpA}'),
    ('${uHrB}',    '${B}', ${role('hr')},            '${eHrB}'),
    ('${uEmpB}',   '${B}', ${role('employee')},      '${eEmpB}');
  insert into teams (id, company_id, name) values
    ('${id(31)}', '${A}', 'Support A'), ('${id(41)}', '${B}', 'Support B');
  insert into team_members (company_id, team_id, employee_id) values
    ('${A}', '${id(31)}', '${eEmpA}'), ('${B}', '${id(41)}', '${eEmpB}');
`);

const rows = async (user, sql) => (await asUser(db, user, sql)).rows;
const count = async (user, sql) => (await rows(user, sql)).length;
const refused = async (user, sql) => {
  try {
    await asUser(db, user, sql);
  } catch (e) {
    return e.message;
  }
  throw new Error('was allowed');
};
const tables = ['companies', 'roles', 'profiles', 'branches', 'departments',
  'employees', 'teams', 'team_members'];

// --- Nobody signed in, or signed in without a profile ----------------------

await t.check('logged out: every table reads empty', async () => {
  for (const tb of tables) expectEqual(await count(null, `select * from ${tb}`), 0, tb);
});
await t.check('logged out: the directory is refused', async () => {
  await refused(null, `select * from company_directory()`);
});
await t.check('a login with no profile sees nothing', async () => {
  for (const tb of tables) {
    if (tb === 'roles') continue; // built-in role names are not secret
    expectEqual(await count(uNoProfile, `select * from ${tb}`), 0, tb);
  }
  expectEqual(await count(uNoProfile, `select * from company_directory()`), 0, 'directory');
});

// --- The main promise: companies are walled off ----------------------------

await t.check('HR of A sees all of A\'s employees and none of B\'s', async () => {
  const names = (await rows(uHrA, `select name from employees order by name`)).map((r) => r.name);
  expectEqual(names, ['Hari HR', 'Ram Agent', 'Sita Staff']);
});
await t.check('HR of B sees only B', async () => {
  const names = (await rows(uHrB, `select name from employees order by name`)).map((r) => r.name);
  expectEqual(names, ['Bikash HR', 'Bina Other']);
});
await t.check('cross-company reads return nothing, table by table', async () => {
  for (const tb of ['companies', 'profiles', 'departments', 'employees', 'teams', 'team_members']) {
    const col = tb === 'companies' ? 'id' : 'company_id';
    expectEqual(await count(uHrA, `select * from ${tb} where ${col} = '${B}'`), 0, `A reading B ${tb}`);
    expectEqual(await count(uHrB, `select * from ${tb} where ${col} = '${A}'`), 0, `B reading A ${tb}`);
  }
});
await t.check('each company sees only its own company row', async () => {
  expectEqual((await rows(uEmpA, `select name from companies`)).map((r) => r.name), ['Karma']);
  expectEqual((await rows(uEmpB, `select name from companies`)).map((r) => r.name), ['Other Co']);
});
await t.check('HR of A cannot add an employee to company B', async () => {
  await refused(uHrA, `insert into employees (company_id, staff_id, name, job_title, joining_date)
                       values ('${B}', 'X-1', 'Spy', 'Agent', '2025-01-01')`);
});
await t.check('HR of A cannot change B\'s employees', async () => {
  expectEqual(await count(uHrA, `update employees set basic_salary = 1 where id = '${eEmpB}' returning id`), 0);
});
await t.check('HR of A cannot move an employee into company B', async () => {
  await refused(uHrA, `update employees set company_id = '${B}' where id = '${eOtherA}'`);
});
await t.check('HR of A cannot delete B\'s department', async () => {
  expectEqual(await count(uHrA, `delete from departments where id = '${id(21)}' returning id`), 0);
});
await t.check('HR of A cannot put B\'s employee in A\'s team', async () => {
  await refused(uHrA, `insert into team_members (company_id, team_id, employee_id)
                       values ('${A}', '${id(31)}', '${eEmpB}')`);
});

// --- Roles inside one company ----------------------------------------------

await t.check('HR can change an employee in their own company', async () => {
  expectEqual(await count(uHrA, `update employees set basic_salary = 45000 where id = '${eEmpA}' returning id`), 1);
});
await t.check('Company Admin can manage people too', async () => {
  expectEqual(await count(uAdminA, `update employees set job_title = 'Senior Agent' where id = '${eEmpA}' returning id`), 1);
});
await t.check('HR can add departments and teams', async () => {
  expectEqual(await count(uHrA, `insert into departments (company_id, name) values ('${A}', 'Sales') returning id`), 1);
  expectEqual(await count(uHrA, `insert into teams (company_id, name) values ('${A}', 'Sales A') returning id`), 1);
});
await t.check('Executive reads the whole company', async () => {
  expectEqual(await count(uExecA, `select * from employees`), 3);
});
await t.check('Executive cannot change anyone', async () => {
  expectEqual(await count(uExecA, `update employees set basic_salary = 1 returning id`), 0);
  await refused(uExecA, `insert into departments (company_id, name) values ('${A}', 'X')`);
});

// --- An ordinary employee ---------------------------------------------------

await t.check('an employee reads only their own full record', async () => {
  const r = await rows(uEmpA, `select id, basic_salary, account_number from employees`);
  expectEqual(r.map((x) => x.id), [eEmpA]);
  expectEqual(r[0].account_number, '222', 'own bank account');
});
await t.check('an employee cannot raise their own salary', async () => {
  expectEqual(await count(uEmpA, `update employees set basic_salary = 999999 where id = '${eEmpA}' returning id`), 0);
});
await t.check('an employee cannot add people', async () => {
  await refused(uEmpA, `insert into employees (company_id, staff_id, name, job_title, joining_date)
                        values ('${A}', 'A-9', 'Friend', 'Agent', '2025-01-01')`);
});
await t.check('an employee cannot create teams or change members', async () => {
  await refused(uEmpA, `insert into teams (company_id, name) values ('${A}', 'My Team')`);
  expectEqual(await count(uEmpA, `delete from team_members returning team_id`), 0);
});
await t.check('an employee reads their company\'s org: departments and teams', async () => {
  expectEqual(await count(uEmpA, `select * from departments`), 1);
  expectEqual((await rows(uEmpA, `select name from teams`)).map((r) => r.name), ['Support A']);
});
await t.check('the directory lists colleagues from own company only', async () => {
  const names = (await rows(uEmpA, `select name from company_directory()`)).map((r) => r.name);
  expectEqual(names, ['Hari HR', 'Ram Agent', 'Sita Staff']);
  const other = (await rows(uEmpB, `select name from company_directory()`)).map((r) => r.name);
  expectEqual(other, ['Bikash HR', 'Bina Other']);
});
await t.check('the directory never includes pay or bank details', async () => {
  const cols = Object.keys((await rows(uEmpA, `select * from company_directory()`))[0]).sort();
  for (const secret of ['basic_salary', 'dearness_allowance', 'transport_allowance',
    'bank_name', 'account_number', 'filing_status']) {
    if (cols.includes(secret)) throw new Error(`directory shows ${secret}`);
  }
});

// --- Profiles: nobody promotes themselves -----------------------------------

await t.check('an employee sees only their own profile', async () => {
  expectEqual((await rows(uEmpA, `select id from profiles`)).map((r) => r.id), [uEmpA]);
});
await t.check('HR sees their company\'s profiles, not B\'s', async () => {
  expectEqual(await count(uHrA, `select * from profiles`), 4);
});
await t.check('no one can change their own role, not even HR', async () => {
  for (const u of [uEmpA, uHrA, uAdminA]) {
    expectEqual(await count(u, `update profiles set role_id = ${role('company_admin')} where id = '${u}' returning id`), 0, u);
  }
});
await t.check('no one can create a profile from the app', async () => {
  await refused(uNoProfile, `insert into profiles (id, company_id, role_id)
                             values ('${uNoProfile}', '${A}', ${role('company_admin')})`);
});
await t.check('no one can move themselves to another company', async () => {
  expectEqual(await count(uHrA, `update profiles set company_id = '${B}' where id = '${uHrA}' returning id`), 0);
});

// --- Company settings -------------------------------------------------------

await t.check('Company Admin can rename their company; HR cannot', async () => {
  expectEqual(await count(uAdminA, `update companies set name = 'Karma Ltd' returning id`), 1);
  expectEqual(await count(uHrA, `update companies set name = 'Karma Ltd' returning id`), 0);
});
await t.check('the built-in roles are readable, but no one can edit them', async () => {
  expectEqual(await count(uEmpA, `select * from roles`), 4);
  expectEqual(await count(uAdminA, `update roles set name = 'Boss' returning id`), 0);
});
await t.check('the helper functions are not reachable when logged out', async () => {
  await refused(null, `select private.my_role()`);
});

t.done();
