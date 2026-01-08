# Ultra Pos - Troubleshooting Guide

## Blank Screen Issue After PC Shutdown

### Problem Description
The app shows a blank screen after an unexpected PC shutdown or crash. This happens even with a fresh database.

### Root Cause Analysis
Based on Windows error logs:
- **Exception Code**: `0xc0000409` (STATUS_STACK_BUFFER_OVERRUN)
- **Event Type**: BEX64 (Buffer Overrun Exception - 64-bit)
- **Faulting Module**: `flutter_windows.dll`

This indicates a critical error during app initialization that was being silently caught, resulting in a blank screen instead of a proper error message.

### Solutions Implemented (v1.1.71+)

1. **Comprehensive Error Handling**
   - All database initialization wrapped in try-catch blocks
   - Detailed error logging with visual markers
   - Proper error propagation to UI layer

2. **Database Integrity Checks**
   - Automatic detection of corrupted database files
   - Automatic recovery by recreating from assets
   - PRAGMA integrity_check before opening database

3. **Enhanced Error UI**
   - Shows detailed error messages instead of blank screen
   - Displays error details with copy functionality
   - Provides retry option to restart app

4. **Diagnostic Logging**
   - Detailed initialization logs with step-by-step progress
   - Visual markers for success (✓) and failure (✗)
   - Stack traces for all errors

### How to Diagnose Issues

#### Step 1: Check Debug Logs
When running the app, check the debug console for initialization logs:

```
╔═══════════════════════════════════════╗
║   Ultra Pos INITIALIZATION START   ║
╚═══════════════════════════════════════╝

App version: 1.1.71.xxx
Platform: Windows

--- Starting App Configuration ---
✓ Window manager initialized

Initializing database and localization...

=== Database Initialization Started ===
Database path: C:\Users\[USER]\AppData\Roaming\[APP]\PosDb.db
Database exists: true
Checking database integrity...
Integrity check result: ok
Opening database...
✓ Database opened successfully
✓ Database connection verified
=== Database Initialization Complete ===

--- App Configuration Complete ---

✓ APP CONFIGURATION COMPLETED
```

#### Step 2: Look for Error Markers
If initialization fails, you'll see:

```
❌❌❌ CRITICAL DATABASE ERROR ❌❌❌
Error: [error description]
Stack: [stack trace]
=========================================
```

#### Step 3: Common Issues and Solutions

##### Issue 1: Database File Locked
**Symptoms**: Error message contains "database is locked"
**Solution**: 
1. Close all instances of the app
2. Delete: `C:\Users\[USER]\AppData\Roaming\Ultra Pos\PosDb.db`
3. Restart the app (it will recreate the database)

##### Issue 2: Corrupted Database
**Symptoms**: Error message contains "malformed" or "integrity check failed"
**Solution**: 
- The app now automatically detects and recreates corrupted databases
- If manual intervention needed, delete the database file (see Issue 1)

##### Issue 3: Permission Denied
**Symptoms**: Error message contains "access denied" or "permission"
**Solution**:
1. Run app as Administrator (right-click → Run as Administrator)
2. Check folder permissions for: `C:\Users\[USER]\AppData\Roaming\`
3. Make sure antivirus isn't blocking the app

##### Issue 4: Missing Assets
**Symptoms**: Error message contains "Unable to load asset" or "assets/db/PosDb.db"
**Solution**:
1. Verify the installation folder contains `data/flutter_assets/assets/db/PosDb.db`
2. Reinstall the application from a fresh download

### Database Locations

**Windows**: 
```
C:\Users\[USERNAME]\AppData\Roaming\[APP_NAME]\PosDb.db
```

**Android/iOS**:
```
[App Data Directory]/PosDb.db
```

### Manual Database Reset

If you need to manually reset the database:

1. **Close the application completely**
2. **Navigate to the database location** (see above)
3. **Delete or rename `PosDb.db`**
4. **Restart the application**
5. The app will automatically create a fresh database from assets

### Getting Support

If issues persist:

1. **Copy Error Details**: Click the copy button in the error screen
2. **Check Debug Logs**: Look for the detailed initialization logs
3. **Note the Following**:
   - Windows version
   - App version
   - Error message and details
   - Steps that led to the error
4. **Contact Support**: Provide all the above information

### For Developers

#### Testing Database Recovery
To test the database recovery mechanism:

1. Locate the database file
2. Open it with a hex editor and corrupt a few bytes
3. Start the app - it should automatically detect and recreate

#### Adding More Diagnostic Info
Edit `lib/shared/services/pos_db_helper.dart` and add more `debugPrint()` statements as needed.

#### Viewing Real-time Logs on Production
For production builds without debug console:

1. Add file logging capability
2. Or use Windows Event Viewer
3. Or implement remote logging

### Version History

- **v1.1.71**: Added comprehensive error handling and diagnostic logging
- **v1.1.70**: Initial issue reported (blank screen after PC shutdown)
