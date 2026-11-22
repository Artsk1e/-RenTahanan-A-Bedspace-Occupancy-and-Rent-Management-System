const fs = require('fs');
const path = require('path');
const pool = require('./config/db');

async function runMigration() {
    const migrationPath = path.join(__dirname, 'schema/migrations/001_add_activity_logs_and_notifications.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');
    
    try {
        console.log('Running migration 001...');
        await pool.query(sql);
        console.log('Migration 001 completed successfully!');
        
        // Verify tables exist
        const activityLogs = await pool.query("SELECT COUNT(*) FROM activity_logs");
        const notifications = await pool.query("SELECT COUNT(*) FROM notifications");
        console.log('activity_logs rows:', activityLogs.rows[0].count);
        console.log('notifications rows:', notifications.rows[0].count);
        
        // Check table structures
        const activityCols = await pool.query(`
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'activity_logs' 
            ORDER BY ordinal_position
        `);
        const notificationCols = await pool.query(`
            SELECT column_name, data_type, is_nullable 
            FROM information_schema.columns 
            WHERE table_name = 'notifications' 
            ORDER BY ordinal_position
        `);
        
        console.log('\nactivity_logs columns:');
        activityCols.rows.forEach(r => console.log(`  ${r.column_name}: ${r.data_type} (${r.is_nullable})`));
        
        console.log('\nnotifications columns:');
        notificationCols.rows.forEach(r => console.log(`  ${r.column_name}: ${r.data_type} (${r.is_nullable})`));
        
    } catch (err) {
        console.error('Migration failed:', err.message);
    } finally {
        await pool.end();
        process.exit(0);
    }
}

runMigration();