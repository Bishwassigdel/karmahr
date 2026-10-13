// Inviting employees: only HR can invite, and a login becomes a profile only
// when its confirmed email matches an open invite.

import { freshDatabase, asUser, runner, expectEqual } from './helpers.mjs';

const db = await freshDatabase();
const t = runner();

const A = 'aaaaaaaa-0000-0000-0000-000000000000';
const B = 'bbbbbbbb-0000-0000-0000-000000000000';
const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const eHr = id(101), eSita = id(102), eRam = id(103), eGone = id(104), eBina = id(201);
const uHr = id(1), uAdmin = id(2), uSita = id(3), uHrB = id(4);
const role = (key) => `(select id from public.roles where key = '${key}' and company_id is null)`;

await db.exec(`
  insert into companies (id, name) values ('${A}', 'Karma'), ('${B}', 'Other Co');
  insert into employees (id, company_id, staff_id, name, job_title, joining_date, email, status) values
    ('${eHr}',   '${A}', 'A-1', 'Hari HR',   'HR Officer', '2024-01-01', 'hari@karma.test', 'active'),
    ('${eSita}', '${A}', 'A-2', 'Sita Staff','Agent',      '2024-01-01', 'sita@karma.test', 'active'),
    ('${eRam}',  '${A}', 'A-3', 'Ram Agent', 'Agent',      '2024-01-01', 'ram@karma.test',  'active'),
    ('${eGone}', '${A}', 'A-4', 'Gita Gone', 'Agent',      '2024-01-01', 'gita@karma.test', 'inactive'),
    ('${eBina}', '${B}', 'B-1', 'Bina Other','Agent',      '2024-01-01', 'bina@other.test', 'active');
  insert into auth.users (id, email, email_confirmed_at) values
    ('${uHr}', 'hari@karma.test', now()), ('${uAdmin}', 'admin@karma.test', now()),
    ('${uSita}', 'sita-login@karma.test', now()), ('${uHrB}', 'hr@other.test', now());
  insert into profiles (id, company_id, role_id, employee_id) values
    ('${uHr}',    '${A}', ${role('hr')},            '${eHr}'),
    ('${uAdmin}', '${A}', ${role('company_admin')}, null),
    ('${uHrB}',   '${B}', ${role('hr')},            null);
`);

const rows = async (u, sql) => (await asUser(db, u, sql)).rows;
const count = async (u, sql) => (await rows(u, sql)).length;
const refused = async (u, sql) => {
  try { await asUser(db, u, sql); } catch (e) { return e.message; }
  throw new Error('was allowed');
};
const invite = (emp, email, comp = A) =>
  `insert into invites (company_id, employee_id, email) values ('${comp}', '${emp}', '${email}')`;
// A new login, as Supabase's sign-up makes it (permanent: run as the owner).
const signUp = (uid, email, confirmed) => db.exec(
  `insert into auth.users (id, email, email_confirmed_at)
   values ('${uid}', '${email}', ${confirmed ? 'now()' : 'null'})`);
const confirm = (uid) => db.exec(`update auth.users set email_confirmed_at = now() where id = '${uid}'`);
const profileOf = async (uid) =>
  (await db.query(`select p.company_id, p.employee_id, r.key as role
                   from profiles p join roles r on r.id = p.role_id where p.id = '${uid}'`)).rows;

// --- who may invite ---------------------------------------------------------

await t.check('HR can invite an employee of their own company', async () => {
  expectEqual(await count(uHr, `${invite(eSita, 'sita@karma.test')} returning id`), 1);
});
await t.check('Company Admin can invite too', async () => {
  expectEqual(await count(uAdmin, `${invite(eRam, 'ram@karma.test')} returning id`), 1);
});
await t.check('an employee cannot invite anyone', async () => {
  await refused(uSita, invite(eRam, 'x@karma.test'));
});
await t.check('HR cannot invite into another company, or another company\'s employee', async () => {
  await refused(uHr, invite(eBina, 'bina@other.test', B));
  await refused(uHr, invite(eBina, 'bina@other.test', A));
});
await t.check('HR of B cannot see or cancel A\'s invites', async () => {
  await db.exec(invite(eSita, 'sita@karma.test'));
  expectEqual(await count(uHrB, `select * from invites`), 0);
  expectEqual(await count(uHrB, `delete from invites returning id`), 0);
  expectEqual(await count(uHr, `select * from invites`), 1);
});
await t.check('an employee cannot read invites', async () => {
  expectEqual(await count(uSita, `select * from invites`), 0);
});
await t.check('nobody can edit an invite from the app', async () => {
  expectEqual(await count(uHr, `update invites set email = 'evil@x.test' returning id`), 0);
  expectEqual(await count(uHr, `update invites set accepted_at = now() returning id`), 0);
});
await t.check('only one open invite per employee', async () => {
  await refused(uHr, invite(eSita, 'other@karma.test'));
});
await t.check('HR can cancel an open invite', async () => {
  expectEqual(await count(uHr, `delete from invites where employee_id = '${eSita}' returning id`), 1);
});

// --- turning a sign-up into a profile ----------------------------------------

const nSita = id(11), nSita2 = id(12), nStranger = id(13), nGone = id(14), nRam = id(15);

await t.check('an unconfirmed sign-up gets nothing, even with a matching invite', async () => {
  await signUp(nSita, 'sita@karma.test', false);
  expectEqual(await profileOf(nSita), []);
});
await t.check('confirming the email creates the profile: employee role, right company and record', async () => {
  await confirm(nSita);
  expectEqual(await profileOf(nSita), [{ company_id: A, employee_id: eSita, role: 'employee' }]);
  expectEqual((await db.query(`select accepted_at is not null as used from invites where employee_id = '${eSita}'`)).rows, [{ used: true }]);
});
await t.check('the new login then sees its own company and nothing of the other', async () => {
  expectEqual((await rows(nSita, `select name from employees`)).map((r) => r.name), ['Sita Staff']);
  expectEqual(await count(nSita, `select * from company_directory()`), 4);
  expectEqual(await count(nSita, `select * from invites`), 0);
});
await t.check('the email match ignores capitals', async () => {
  await db.exec(invite(eRam, 'ram@karma.test'));
  await signUp(nRam, 'RAM@Karma.Test', true);
  expectEqual((await profileOf(nRam)).map((r) => r.employee_id), [eRam]);
});
await t.check('an invite is used once: a second login with the same email gets nothing', async () => {
  await signUp(nSita2, 'sita@karma.test', true);
  expectEqual(await profileOf(nSita2), []);
});
await t.check('a stranger without an invite gets a login but no profile and no data', async () => {
  await signUp(nStranger, 'stranger@x.test', true);
  expectEqual(await profileOf(nStranger), []);
  for (const tb of ['employees', 'teams', 'departments', 'invites'])
    expectEqual(await count(nStranger, `select * from ${tb}`), 0, tb);
  expectEqual(await count(nStranger, `select * from company_directory()`), 0);
});
await t.check('a deactivated employee\'s invite is not honoured', async () => {
  await db.exec(invite(eGone, 'gita@karma.test'));
  await signUp(nGone, 'gita@karma.test', true);
  expectEqual(await profileOf(nGone), []);
});
await t.check('an invite never creates a profile in another company', async () => {
  const rowsAll = (await db.query(`select company_id from profiles where id in ('${nSita}','${nRam}')`)).rows;
  for (const r of rowsAll) expectEqual(r.company_id, A);
});
await t.check('a person with an existing account is left alone', async () => {
  // Hari already has a login; an invite for Hari's record and a new login must not clash.
  await db.exec(invite(eHr, 'hari2@karma.test'));
  const nHari2 = id(16);
  await signUp(nHari2, 'hari2@karma.test', true);
  expectEqual(await profileOf(nHari2), []);
});

t.done();
