// The test-data seed (supabase/seed/dev_seed.sql): refuses to run without a
// real password, builds two companies with a login for every role, can be
// run twice, never touches anything else, and the result obeys the Day 5
// security rules. Run: cd supabase/tests && npm ci && npm test

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { freshDatabase, asUser, runner, expectEqual } from './helpers.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const seedSql = fs.readFileSync(path.join(here, '..', 'seed', 'dev_seed.sql'), 'utf8');
const removeSql = fs.readFileSync(path.join(here, '..', 'seed', 'dev_seed_remove.sql'), 'utf8');
const PASSWORD = 'Test-password-123';
const withPassword = (pw) => seedSql.replace("'CHANGE-ME';", `'${pw}';`);

const t = runner();
const db = await freshDatabase();
const one = async (q) => (await db.query(q)).rows[0];
const count = async (table) => (await one(`select count(*)::int n from ${table}`)).n;

const A = 'a0000000-0000-4000-8000-000000000001';
const B = 'b0000000-0000-4000-8000-000000000001';
const login = async (email) => (await one(`select id from auth.users where email = '${email}'`)).id;

await t.check('the script ships with a placeholder, never a real password', () => {
  if (!seedSql.includes("pw constant text := 'CHANGE-ME';")) throw new Error('placeholder missing');
});
await t.check('it refuses to run until a password is set', async () => {
  try { await db.exec(seedSql); } catch (e) {
    if (!/Set a test password/.test(e.message)) throw e;
    return;
  }
  throw new Error('ran with the placeholder');
});
await t.check('it refuses a short password', async () => {
  try { await db.exec(withPassword('short')); } catch (e) {
    if (!/Set a test password/.test(e.message)) throw e;
    return;
  }
  throw new Error('accepted a short password');
});
await t.check('a refused run changes nothing', async () => {
  expectEqual(await count('auth.users'), 0, 'logins');
  expectEqual(await count('companies'), 0, 'companies');
});

await t.check('the seed runs', () => db.exec(withPassword(PASSWORD)));

await t.check('two companies, seven people, eight logins with profiles', async () => {
  expectEqual(await count('companies'), 2, 'companies');
  expectEqual(await count('employees'), 7, 'employees');
  expectEqual(await count('auth.users'), 8, 'logins');
  expectEqual(await count('auth.identities'), 8, 'identities');
  expectEqual(await count('profiles'), 8, 'profiles');
});
await t.check('every role has a login', async () => {
  const r = await db.query(`select r.key, count(*)::int n from profiles p join roles r on r.id = p.role_id group by r.key order by r.key`);
  expectEqual(r.rows.map((x) => `${x.key}:${x.n}`),
    ['company_admin:1', 'employee:4', 'executive:1', 'hr:2']);
});
await t.check('the password is stored hashed, and the right password matches', async () => {
  const r = await one(`select encrypted_password p,
      encrypted_password = extensions.crypt('${PASSWORD}', encrypted_password) as ok,
      encrypted_password = extensions.crypt('wrong-password-1', encrypted_password) as bad
    from auth.users where email = 'hr@himalaya-tech.test'`);
  if (r.p.includes(PASSWORD)) throw new Error('password stored in plain text');
  expectEqual([r.ok, r.bad], [true, false]);
});
await t.check('every login is confirmed and has none of the null token fields Supabase chokes on', async () => {
  const r = await one(`select count(*)::int n from auth.users
    where email_confirmed_at is null or confirmation_token is null or recovery_token is null
       or email_change_token_new is null or email_change is null or email_change_token_current is null
       or phone_change is null or phone_change_token is null or reauthentication_token is null
       or aud <> 'authenticated' or role <> 'authenticated'`);
  expectEqual(r.n, 0);
});
await t.check('each login has an email identity that matches it', async () => {
  const r = await one(`select count(*)::int n from auth.users u join auth.identities i on i.user_id = u.id
    where i.provider = 'email' and i.provider_id = u.id::text and i.identity_data->>'email' = u.email`);
  expectEqual(r.n, 8);
});
await t.check('the team: Sita leads, and the head is a member', async () => {
  const r = await one(`select e.name head, (select count(*)::int from team_members m where m.team_id = t.id) members
    from teams t join employees e on e.id = t.head_employee_id`);
  expectEqual([r.head, r.members], ['Sita Employee', 2]);
});
await t.check('managers and departments are linked', async () => {
  const r = await one(`select m.name mgr, d.name dept from employees e
    join employees m on m.id = e.manager_id join departments d on d.id = e.department_id
    where e.email = 'sita@himalaya-tech.test'`);
  expectEqual([r.mgr, r.dept], ['Hari Hr', 'Support']);
});

// The security rules, on the seeded data, as each real login.
const rows = async (user, sql) => (await asUser(db, user, sql)).rows;
await t.check('HR of Himalaya sees its 5 people and none of Everest', async () => {
  const names = (await rows(await login('hr@himalaya-tech.test'), `select name from employees order by name`)).map((r) => r.name);
  expectEqual(names, ['Eka Exec', 'Gita Employee', 'Hari Hr', 'Ram Employee', 'Sita Employee']);
});
await t.check('HR of Everest sees only Everest', async () => {
  const names = (await rows(await login('hr@everest-traders.test'), `select name from employees order by name`)).map((r) => r.name);
  expectEqual(names, ['Binod Hr', 'Mina Employee']);
});
await t.check('Executive and Company Admin read their whole company', async () => {
  expectEqual((await rows(await login('exec@himalaya-tech.test'), `select 1 from employees`)).length, 5);
  expectEqual((await rows(await login('admin@himalaya-tech.test'), `select 1 from employees`)).length, 5);
});
await t.check('an employee sees only their own record, with their own pay', async () => {
  const r = await rows(await login('sita@himalaya-tech.test'), `select name, basic_salary from employees`);
  expectEqual(r.map((x) => x.name), ['Sita Employee']);
});
await t.check('an employee from one company cannot see the other company at all', async () => {
  const mina = await login('mina@everest-traders.test');
  expectEqual((await rows(mina, `select 1 from companies where id = '${A}'`)).length, 0);
  expectEqual((await rows(mina, `select 1 from departments where company_id = '${A}'`)).length, 0);
  expectEqual((await rows(mina, `select 1 from teams where company_id = '${A}'`)).length, 0);
  const dir = (await rows(mina, `select name from company_directory() order by name`)).map((r) => r.name);
  expectEqual(dir, ['Binod Hr', 'Mina Employee']);
});
await t.check('the colleague directory shows Sita her Himalaya colleagues, never Everest', async () => {
  const dir = (await rows(await login('sita@himalaya-tech.test'), `select name from company_directory()`)).map((r) => r.name);
  expectEqual(dir.length, 5);
  if (dir.includes('Mina Employee') || dir.includes('Binod Hr')) throw new Error('Everest visible');
});

// Safe to repeat, and polite to everything else.
await t.check('a different company and login made by hand survive the seed', async () => {
  await db.exec(`insert into companies (id, name) values ('cccccccc-0000-4000-8000-000000000001', 'Hand-made Co');
    insert into auth.users (id, email) values ('cccccccc-1111-4000-8000-000000000001', 'me@gmail.com');`);
  await db.exec(withPassword(PASSWORD));
  expectEqual(await count('companies'), 3, 'companies');
  expectEqual((await one(`select count(*)::int n from auth.users where email = 'me@gmail.com'`)).n, 1);
});
await t.check('running the seed twice gives the same result, not duplicates', async () => {
  const before = await one(`select count(*)::int e, (select count(*)::int from profiles) p, (select count(*)::int from auth.users) u from employees`);
  await db.exec(withPassword(PASSWORD));
  const after = await one(`select count(*)::int e, (select count(*)::int from profiles) p, (select count(*)::int from auth.users) u from employees`);
  expectEqual(after, before);
});
await t.check('the remove script clears the seed and nothing else', async () => {
  await db.exec(removeSql);
  expectEqual(await count('employees'), 0, 'employees');
  expectEqual(await count('profiles'), 0, 'profiles');
  expectEqual(await count('teams'), 0, 'teams');
  expectEqual((await one(`select count(*)::int n from auth.users where email like '%.test'`)).n, 0);
  expectEqual((await one(`select count(*)::int n from companies`)).n, 1, 'hand-made company remains');
  expectEqual((await one(`select count(*)::int n from auth.users where email = 'me@gmail.com'`)).n, 1, 'hand-made login remains');
});
await t.check('after removing, the seed can be run again', async () => {
  await db.exec(withPassword(PASSWORD));
  expectEqual(await count('profiles'), 8);
});

t.done();
