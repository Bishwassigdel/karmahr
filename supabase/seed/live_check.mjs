// Checks the REAL Supabase project after dev_seed.sql has run: signs in as
// each seeded login and verifies what each can and cannot see.
//
//   SEED_PASSWORD='the password you put in the seed' node supabase/seed/live_check.mjs
//
// Needs the project URL and publishable key from the app's .env file. It
// only signs in and reads; it changes nothing.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const here = path.dirname(fileURLToPath(import.meta.url));
const env = Object.fromEntries(
  fs.readFileSync(path.join(here, '..', '..', '.env'), 'utf8')
    .split('\n').filter((l) => /^[A-Z_]+=/.test(l))
    .map((l) => [l.split('=')[0], l.slice(l.indexOf('=') + 1).trim()]),
);
const url = env.SUPABASE_URL.replace(/\/$/, '');
const key = env.SUPABASE_PUBLISHABLE_KEY;
const password = process.env.SEED_PASSWORD;
if (!password) {
  console.error('Set SEED_PASSWORD to the password you put in dev_seed.sql.');
  process.exit(2);
}

let pass = 0, fail = 0;
const check = (name, ok, detail = '') => {
  ok ? pass++ : fail++;
  console.log(ok ? 'PASS' : 'FAIL', name, ok ? '' : `- ${detail}`);
};

async function signIn(email) {
  const r = await fetch(`${url}/auth/v1/token?grant_type=password`, {
    method: 'POST',
    headers: { apikey: key, 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  const body = await r.json();
  return r.ok ? body.access_token : null;
}
async function get(token, pathAndQuery) {
  const r = await fetch(`${url}/rest/v1/${pathAndQuery}`, {
    headers: { apikey: key, Authorization: `Bearer ${token ?? key}` },
  });
  return { status: r.status, body: await r.json() };
}
const names = (r) => r.body.map((x) => x.name).sort();

const D = '@himalaya-tech.test', E = '@everest-traders.test';
const accounts = [
  [`admin${D}`, 'company_admin'], [`hr${D}`, 'hr'], [`exec${D}`, 'executive'],
  [`sita${D}`, 'employee'], [`ram${D}`, 'employee'], [`gita${D}`, 'employee'],
  [`hr${E}`, 'hr'], [`mina${E}`, 'employee'],
];
const tokens = {};
for (const [email, role] of accounts) {
  tokens[email] = await signIn(email);
  check(`${email} can sign in`, !!tokens[email], 'sign-in refused (wrong password, or seed not run?)');
  if (!tokens[email]) continue;
  const p = await get(tokens[email], 'profiles?select=full_name,roles(key)');
  const mine = p.body?.filter?.((x) => x.roles?.key === role) ?? [];
  check(`${email} has the ${role} role`, p.status === 200 && mine.length >= 1, JSON.stringify(p.body).slice(0, 120));
}

if (Object.values(tokens).every(Boolean)) {
  const emp = (e) => get(tokens[e], 'employees?select=name,basic_salary');
  const hrA = await emp(`hr${D}`);
  // The seeded people at least (HR may have added more in the app), and
  // nobody from Everest.
  const seededA = ['Eka Exec', 'Gita Employee', 'Hari Hr', 'Ram Employee', 'Sita Employee'];
  check('HR of Himalaya sees its seeded people', seededA.every((n) => names(hrA).includes(n)), names(hrA).join());
  check('...and none of Everest', !names(hrA).some((n) => ['Binod Hr', 'Mina Employee'].includes(n)), names(hrA).join());
  const sizeA = hrA.body.length;
  const hrB = await emp(`hr${E}`);
  check('HR of Everest sees only Everest', names(hrB).join() === ['Binod Hr', 'Mina Employee'].join(), names(hrB).join());
  check('Executive reads the whole company', (await emp(`exec${D}`)).body.length === sizeA);
  check('Company Admin reads the whole company', (await emp(`admin${D}`)).body.length === sizeA);
  check('an employee sees only their own record', names(await emp(`sita${D}`)).join() === 'Sita Employee');
  check('Mina (Everest) sees only herself', names(await emp(`mina${E}`)).join() === 'Mina Employee');

  const cross = await get(tokens[`hr${D}`], 'employees?select=name&company_id=eq.b0000000-0000-4000-8000-000000000001');
  check("HR of Himalaya asking for Everest's people gets nothing", cross.body.length === 0, JSON.stringify(cross.body));
  const crossCo = await get(tokens[`mina${E}`], 'companies?select=name');
  check('Mina sees only her own company row', crossCo.body.length === 1 && crossCo.body[0].name === 'Everest Traders', JSON.stringify(crossCo.body));
  const dir = await get(tokens[`ram${D}`], 'rpc/company_directory?select=name');
  check("the directory shows Ram his colleagues, not Everest's", dir.status === 200 && dir.body.length === sizeA && !dir.body.some((x) => /Mina|Binod/.test(x.name)), JSON.stringify(dir.body).slice(0, 120));
  const secret = await get(tokens[`ram${D}`], 'rpc/company_directory');
  check('the directory has no pay or bank columns', secret.body.length > 0 && !('basic_salary' in secret.body[0]) && !('account_number' in secret.body[0]));
  const edit = await fetch(`${url}/rest/v1/employees?id=eq.a0000000-0000-4000-8000-0000000000e4`, {
    method: 'PATCH',
    headers: { apikey: key, Authorization: `Bearer ${tokens[`sita${D}`]}`, 'Content-Type': 'application/json', Prefer: 'return=representation' },
    body: JSON.stringify({ basic_salary: 1 }),
  });
  check("an employee can't change a colleague's pay", (await edit.json()).length === 0);
  const anon = await get(null, 'employees?select=name');
  check('someone not signed in sees no employees', anon.body.length === 0, JSON.stringify(anon.body));
}

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
