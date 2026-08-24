#!/usr/bin/env node
/**
 * Static RLS coverage check over Supabase migrations.
 *
 * Aggregates every CREATE TABLE across migration files and verifies each table
 * also has ENABLE ROW LEVEL SECURITY and at least one CREATE POLICY.
 * Heuristic only. Confirm ambiguous cases with inspect-db-schema.
 *
 * Run from the consumer repo root. Discovers supabase/migrations from cwd.
 */
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const EXEMPT = new Set([]);

function findMigrationsDir() {
  const fromCwd = join(process.cwd(), 'supabase', 'migrations');
  if (existsSync(fromCwd)) return fromCwd;
  let dir = dirname(fileURLToPath(import.meta.url));
  for (let i = 0; i < 10; i += 1) {
    const candidate = join(dir, 'supabase', 'migrations');
    if (existsSync(candidate)) return candidate;
    const parent = dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  console.error('supabase/migrations not found. Run from the consumer project root.');
  process.exit(2);
}

function loadSql(migrationsDir) {
  const files = readdirSync(migrationsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();
  return files.map((f) => readFileSync(join(migrationsDir, f), 'utf8')).join('\n');
}

function normalize(name) {
  return name.replace(/"/g, '').toLowerCase();
}

function collect(sql, regex) {
  const found = new Set();
  let m;
  while ((m = regex.exec(sql)) !== null) found.add(normalize(m[1]));
  return found;
}

const SCHEMA = '(?:"?\\w+"?\\s*\\.\\s*)?';
const IDENT = '"?(\\w+)"?';

function main() {
  const migrationsDir = findMigrationsDir();
  const sql = loadSql(migrationsDir);

  const created = collect(
    sql,
    new RegExp(`CREATE\\s+TABLE\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?${SCHEMA}${IDENT}`, 'gi'),
  );
  const rlsEnabled = collect(
    sql,
    new RegExp(
      `ALTER\\s+TABLE\\s+(?:IF\\s+EXISTS\\s+)?(?:ONLY\\s+)?${SCHEMA}${IDENT}\\s+ENABLE\\s+ROW\\s+LEVEL\\s+SECURITY`,
      'gi',
    ),
  );
  const policied = collect(
    sql,
    new RegExp(`CREATE\\s+POLICY\\s+[\\s\\S]*?\\sON\\s+${SCHEMA}${IDENT}`, 'gi'),
  );

  const missing = [];
  for (const table of [...created].sort()) {
    if (EXEMPT.has(table)) continue;
    const problems = [];
    if (!rlsEnabled.has(table)) problems.push('no ENABLE ROW LEVEL SECURITY');
    if (!policied.has(table)) problems.push('no CREATE POLICY');
    if (problems.length) missing.push({ table, problems });
  }

  console.log(`Scanned ${created.size} created tables in ${migrationsDir}.`);
  if (missing.length === 0) {
    console.log('OK: every table has RLS enabled and at least one policy.');
    process.exit(0);
  }

  console.error(`\nRLS coverage gaps (${missing.length}):`);
  for (const { table, problems } of missing) {
    console.error(`  - ${table}: ${problems.join('; ')}`);
  }
  console.error(
    '\nAdd the missing ENABLE ROW LEVEL SECURITY / CREATE POLICY in the owning migration.',
  );
  process.exit(1);
}

main();
