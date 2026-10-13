// Shared setup for the database tests: an in-memory Postgres (PGlite) that
// looks enough like a Supabase project for our migrations and policies to
// run, with every migration applied in order.

import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrations = path.join(here, '..', 'migrations');

// What a real Supabase project already has before our migrations run: the
// API roles, an auth schema with users and auth.uid(), and the default
// grants that give the API roles access to everything in public (which is
// why Row Level Security has to do the real work).
const supabaseStandIn = `
  create role anon nologin;
  create role authenticated nologin;
  create schema auth;
  -- The columns of Supabase's auth.users and auth.identities that matter
  -- to us (the real tables have a few more, all optional).
  create table auth.users (
    instance_id uuid,
    id uuid primary key,
    aud varchar(255),
    role varchar(255),
    email varchar(255),
    encrypted_password varchar(255),
    email_confirmed_at timestamptz,
    confirmation_token varchar(255),
    recovery_token varchar(255),
    email_change_token_new varchar(255),
    email_change varchar(255),
    email_change_token_current varchar(255),
    phone_change varchar(255),
    phone_change_token varchar(255),
    reauthentication_token varchar(255),
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamptz,
    updated_at timestamptz
  );
  create table auth.identities (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    identity_data jsonb not null,
    provider text not null,
    provider_id text not null,
    last_sign_in_at timestamptz,
    created_at timestamptz,
    updated_at timestamptz
  );
  -- Supabase keeps pgcrypto (crypt, gen_salt) in the "extensions" schema.
  create schema extensions;
  create extension pgcrypto schema extensions;
  create function auth.uid() returns uuid language sql stable as $$
    select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
  $$;
  grant usage on schema auth to anon, authenticated;
  grant execute on function auth.uid() to anon, authenticated;
  grant usage on schema public to anon, authenticated;
  alter default privileges in schema public
    grant all on tables to anon, authenticated;
  alter default privileges in schema public
    grant all on functions to anon, authenticated;
`;

export async function freshDatabase() {
  const db = new PGlite({ extensions: { pgcrypto } });
  await db.exec(supabaseStandIn);
  for (const f of fs.readdirSync(migrations).filter((f) => f.endsWith('.sql')).sort()) {
    await db.exec(fs.readFileSync(path.join(migrations, f), 'utf8'));
  }
  return db;
}

/// Runs [sql] as the API would for the signed-in user [userId] (or logged
/// out when null), inside a transaction that is always rolled back, so one
/// test can't change what the next one sees.
export async function asUser(db, userId, sql, params = []) {
  let result;
  let error;
  try {
    await db.transaction(async (tx) => {
      await tx.exec(`set local role ${userId ? 'authenticated' : 'anon'}`);
      await tx.query(`select set_config('request.jwt.claim.sub', $1, true)`, [
        userId ?? '',
      ]);
      result = await tx.query(sql, params);
      await tx.rollback();
    });
  } catch (e) {
    error = e;
  }
  if (error && !/rollback/i.test(String(error.message))) throw error;
  return result;
}

/// A tiny test runner: prints PASS/FAIL per check and exits non-zero on any
/// failure, so CI goes red.
export function runner() {
  let pass = 0;
  let fail = 0;
  return {
    async check(name, fn) {
      try {
        await fn();
        pass++;
        console.log('PASS', name);
      } catch (e) {
        fail++;
        console.log('FAIL', name, '-', e.message);
      }
    },
    done() {
      console.log(`\n${pass} passed, ${fail} failed`);
      process.exit(fail ? 1 : 0);
    },
  };
}

export function expectEqual(actual, expected, what = 'value') {
  const a = JSON.stringify(actual);
  const b = JSON.stringify(expected);
  if (a !== b) throw new Error(`${what}: expected ${b}, got ${a}`);
}
