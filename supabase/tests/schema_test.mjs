// Schema rules: every migration applied to an in-memory Postgres, then the
// promises the tables make (company isolation, team rules, cascades) are
// checked one by one. Run: cd supabase/tests && npm ci && npm test

import { freshDatabase } from './helpers.mjs';

let db;
let pass = 0, fail = 0;
async function ok(name, fn) { try { await fn(); pass++; console.log('PASS', name); } catch (e) { fail++; console.log('FAIL', name, '-', e.message); } }
async function rejects(name, q) { try { await db.exec(q); fail++; console.log('FAIL', name, '- was accepted'); } catch (e) { pass++; console.log('PASS', name, '(' + e.message.split('\n')[0] + ')'); } }
async function one(q) { return (await db.query(q)).rows[0]; }

await ok('migrations run', async () => { db = await freshDatabase(); });
console.log((await db.query('select version()')).rows[0].version.split(' ').slice(0,2).join(' '));

await ok('4 built-in roles', async () => { const r = await one(`select count(*)::int n from roles where company_id is null`); if (r.n !== 4) throw new Error(r.n); });
await ok('every table has RLS on', async () => {
  const r = await db.query(`select relname from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and relkind='r' and not relrowsecurity`);
  if (r.rows.length) throw new Error(r.rows.map(x=>x.relname).join(','));
});

await db.exec(`
insert into companies (id,name) values ('00000000-0000-0000-0000-00000000000a','Karma'),('00000000-0000-0000-0000-00000000000b','Other');
insert into departments (id,company_id,name) values ('00000000-0000-0000-0000-0000000000d1','00000000-0000-0000-0000-00000000000a','Support'),('00000000-0000-0000-0000-0000000000d2','00000000-0000-0000-0000-00000000000b','Support');
insert into branches (id,company_id,name) values ('00000000-0000-0000-0000-0000000000b1','00000000-0000-0000-0000-00000000000a','Kathmandu');
insert into employees (id,company_id,staff_id,name,job_title,joining_date,department_id,email) values
 ('00000000-0000-0000-0000-0000000000e1','00000000-0000-0000-0000-00000000000a','MB-1','A','Lead','2025-01-01','00000000-0000-0000-0000-0000000000d1','a@k.com'),
 ('00000000-0000-0000-0000-0000000000e2','00000000-0000-0000-0000-00000000000a','MB-2','B','Agent','2025-01-01',null,''),
 ('00000000-0000-0000-0000-0000000000e3','00000000-0000-0000-0000-00000000000a','MB-3','C','Agent','2025-01-01',null,''),
 ('00000000-0000-0000-0000-0000000000e9','00000000-0000-0000-0000-00000000000b','MB-1','X','Agent','2025-01-01',null,'');
`);
const A='00000000-0000-0000-0000-00000000000a', E1='00000000-0000-0000-0000-0000000000e1', E2='00000000-0000-0000-0000-0000000000e2', E3='00000000-0000-0000-0000-0000000000e3', E9='00000000-0000-0000-0000-0000000000e9';

await rejects('duplicate staff ID in one company', `insert into employees (company_id,staff_id,name,job_title,joining_date) values ('${A}','MB-1','Z','J','2025-01-01')`);
await rejects('duplicate email in one company (case-insensitive)', `insert into employees (company_id,staff_id,name,job_title,joining_date,email) values ('${A}','MB-7','Z','J','2025-01-01','A@K.com')`);
await rejects('employee in another company\'s department', `insert into employees (company_id,staff_id,name,job_title,joining_date,department_id) values ('${A}','MB-8','Z','J','2025-01-01','00000000-0000-0000-0000-0000000000d2')`);
await rejects('manager from another company', `update employees set manager_id='${E9}' where id='${E2}'`);
await rejects('own manager', `update employees set manager_id=id where id='${E2}'`);
await rejects('negative salary', `update employees set basic_salary=-1 where id='${E2}'`);
await rejects('letters in account number', `update employees set account_number='12ab' where id='${E2}'`);
await rejects('unknown employment type', `update employees set employment_type='Gig' where id='${E2}'`);
await rejects('blank name', `insert into employees (company_id,staff_id,name,job_title,joining_date) values ('${A}','MB-9','  ','J','2025-01-01')`);
await rejects('duplicate department name (case-insensitive)', `insert into departments (company_id,name) values ('${A}','support')`);
await ok('updated_at changes on update', async () => {
  const before = await one(`select updated_at from employees where id='${E2}'`);
  await db.exec(`begin; update employees set name='B2' where id='${E2}'; commit;`);
  const after = await one(`select updated_at from employees where id='${E2}'`);
  if (!(after.updated_at >= before.updated_at)) throw new Error('not updated');
});
await ok('deleting a department leaves the employee, without a department', async () => {
  await db.exec(`insert into departments (id,company_id,name) values ('00000000-0000-0000-0000-0000000000d3','${A}','Temp'); update employees set department_id='00000000-0000-0000-0000-0000000000d3' where id='${E3}'; delete from departments where id='00000000-0000-0000-0000-0000000000d3';`);
  const r = await one(`select department_id, company_id from employees where id='${E3}'`);
  if (r.department_id !== null || r.company_id !== A) throw new Error(JSON.stringify(r));
});

// Teams
const T='00000000-0000-0000-0000-0000000000f1', T2='00000000-0000-0000-0000-0000000000f2';
await ok('team with members and head in one transaction', () => db.exec(`
  begin;
  insert into teams (id,company_id,name,head_employee_id) values ('${T}','${A}','Support A','${E1}');
  insert into team_members (company_id,team_id,employee_id) values ('${A}','${T}','${E1}'),('${A}','${T}','${E2}'),('${A}','${T}','${E3}');
  commit;`));
await rejects('duplicate team name (case-insensitive)', `insert into teams (company_id,name) values ('${A}','support a')`);
await rejects('head who is not a member', `begin; insert into teams (id,company_id,name,head_employee_id) values ('${T2}','${A}','Sales','${E2}'); commit;`);
await db.exec('rollback').catch(()=>{});
await rejects('member from another company', `insert into team_members (company_id,team_id,employee_id) values ('${A}','${T}','${E9}')`);
await rejects('same person added twice', `insert into team_members (company_id,team_id,employee_id) values ('${A}','${T}','${E2}')`);
await rejects('a person leading two teams', `begin; insert into teams (id,company_id,name) values ('${T2}','${A}','Sales'); insert into team_members (company_id,team_id,employee_id) values ('${A}','${T2}','${E1}'); update teams set head_employee_id='${E1}' where id='${T2}'; commit;`);
await db.exec('rollback').catch(()=>{});
await ok('removing the head from the team clears the head', async () => {
  await db.exec(`delete from team_members where team_id='${T}' and employee_id='${E1}'`);
  const r = await one(`select head_employee_id from teams where id='${T}'`);
  if (r.head_employee_id !== null) throw new Error('head still set');
});
await ok('deleting a team removes its members, not the employees', async () => {
  await db.exec(`delete from teams where id='${T}'`);
  const m = await one(`select count(*)::int n from team_members where team_id='${T}'`);
  const e = await one(`select count(*)::int n from employees where company_id='${A}'`);
  if (m.n !== 0 || e.n !== 3) throw new Error(JSON.stringify({m,e}));
});

// Profiles
await ok('a login links to company, role and employee', () => db.exec(`
  insert into auth.users (id) values ('00000000-0000-0000-0000-000000000001');
  insert into profiles (id,company_id,role_id,employee_id) select '00000000-0000-0000-0000-000000000001','${A}',id,'${E2}' from roles where key='employee' and company_id is null;`));
await rejects('login linked to another company\'s employee', `insert into auth.users (id) values ('00000000-0000-0000-0000-000000000002'); insert into profiles (id,company_id,role_id,employee_id) select '00000000-0000-0000-0000-000000000002','${A}',id,'${E9}' from roles where key='employee' and company_id is null;`);
await rejects('two logins for one employee', `insert into auth.users (id) values ('00000000-0000-0000-0000-000000000003'); insert into profiles (id,company_id,role_id,employee_id) select '00000000-0000-0000-0000-000000000003','${A}',id,'${E2}' from roles where key='hr' and company_id is null;`);
await ok('deleting a company removes all its data', async () => {
  await db.exec(`delete from companies where id='${A}'`);
  for (const t of ['employees','departments','branches','teams','profiles']) {
    const r = await one(`select count(*)::int n from ${t} where company_id='${A}'`);
    if (r.n) throw new Error(t + ' left ' + r.n);
  }
  const other = await one(`select count(*)::int n from employees where company_id='00000000-0000-0000-0000-00000000000b'`);
  if (other.n !== 1) throw new Error('other company touched');
});
console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
