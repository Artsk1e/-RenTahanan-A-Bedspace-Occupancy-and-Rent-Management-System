const pool = require('./config/db');

async function analyze() {
  // Get all tables
  const tables = await pool.query(`
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    ORDER BY table_name
  `);
  console.log('=== TABLES ===');
  for (const t of tables.rows) {
    const cols = await pool.query(`
      SELECT c.column_name, c.data_type, c.is_nullable, c.column_default,
             CASE WHEN pk.column_name IS NOT NULL THEN 'PK' ELSE '' END as pk,
             CASE WHEN fk.column_name IS NOT NULL THEN 'FK' ELSE '' END as fk
      FROM information_schema.columns c
      LEFT JOIN (
        SELECT kcu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
        WHERE tc.constraint_type = 'PRIMARY KEY' AND tc.table_name = $1
      ) pk ON c.column_name = pk.column_name
      LEFT JOIN (
        SELECT kcu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = $1
      ) fk ON c.column_name = fk.column_name
      WHERE c.table_name = $1 AND c.table_schema = 'public'
      ORDER BY c.ordinal_position
    `, [t.table_name]);
    console.log('\n' + t.table_name.toUpperCase());
    cols.rows.forEach(c => {
      const flags = [c.pk, c.fk].filter(Boolean).join(' ');
      console.log(`  ${c.column_name.padEnd(25)} ${c.data_type.padEnd(20)} ${c.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'.padEnd(8)} ${flags}`);
    });
  }
  
  // Foreign keys detail
  const fks = await pool.query(`
    SELECT
      tc.table_name as from_table,
      kcu.column_name as from_column,
      ccu.table_name as to_table,
      ccu.column_name as to_column,
      rc.delete_rule
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
    JOIN information_schema.referential_constraints rc ON tc.constraint_name = rc.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
    ORDER BY tc.table_name
  `);
  console.log('\n=== FOREIGN KEYS ===');
  fks.rows.forEach(fk => {
    console.log(`  ${fk.from_table}.${fk.from_column} -> ${fk.to_table}.${fk.to_column} (ON DELETE ${fk.delete_rule})`);
  });
  
  // Enums
  const enums = await pool.query(`
    SELECT t.typname as enum_name, array_agg(e.enumlabel ORDER BY e.enumsortorder) as values
    FROM pg_type t
    JOIN pg_enum e ON t.oid = e.enumtypid
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE n.nspname = 'public'
    GROUP BY t.typname
    ORDER BY t.typname
  `);
  console.log('\n=== ENUMS ===');
  enums.rows.forEach(e => {
    const vals = Array.isArray(e.values) ? e.values : e.values.split(',');
    console.log(`  ${e.enum_name}: [${vals.join(', ')}]`);
  });
  
  // Triggers
  const triggers = await pool.query(`
    SELECT event_object_table as table_name, trigger_name, action_statement
    FROM information_schema.triggers
    WHERE trigger_schema = 'public'
    ORDER BY event_object_table, trigger_name
  `);
  console.log('\n=== TRIGGERS ===');
  triggers.rows.forEach(t => console.log(`  ${t.table_name}.${t.trigger_name}: ${t.action_statement.substring(0, 80)}...`));
  
  // Indexes
  const indexes = await pool.query(`
    SELECT indexname, tablename, indexdef
    FROM pg_indexes
    WHERE schemaname = 'public'
    ORDER BY tablename, indexname
  `);
  console.log('\n=== INDEXES ===');
  indexes.rows.forEach(i => console.log(`  ${i.tablename}.${i.indexname}`));
  
  await pool.end();
}

analyze().catch(e => { console.error(e); process.exit(1); });