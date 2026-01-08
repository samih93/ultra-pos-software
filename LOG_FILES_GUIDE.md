# Ultra Pos - Log Files Guide

## Finding Error Log Files

When the application encounters an error, it automatically writes detailed information to log files. This guide will help you locate these files to troubleshoot issues.

### Log File Location (Windows)

The log files are stored in the **logs** folder inside your application directory:

```
C:\ultra-pos-v1.1.70\logs\
```

Or more generally:

```
[Application Installation Folder]\logs\
```

### Log File Format

Files are named by date:

```
ultra_pos_20251213.log    (for December 13, 2025)
ultra_pos_20251214.log    (for December 14, 2025)
```

### How to Find the Log Files

**Method 1: Quick Access**

1. Open the folder where `Ultra_pos.exe` is located (e.g., `C:\ultra-pos-v1.1.70\`)
2. Look for a folder named `logs`
3. Open the `logs` folder
4. Find today's log file (named with today's date)

**Method 2: From Error Screen**
If the app shows an error screen, it will display the log file path directly on the screen.

### What's in the Log Files?

The log files contain:

- Application startup information
- Database initialization steps
- All errors with detailed stack traces
- Timestamps for each operation

Example log content:

```
[2025-12-13 14:30:00.123][INFO] Application starting...
[2025-12-13 14:30:01.456][INFO] ═══ Splash Screen Initialization Started ═══
[2025-12-13 14:30:02.789][INFO] App version: 1.1.70.101
[2025-12-13 14:30:03.012][INFO] App configuration started
[2025-12-13 14:30:03.234][INFO] Platform: Windows
[2025-12-13 14:30:04.567][INFO] Windows database initialization started
[2025-12-13 14:30:05.890][INFO] Database path: C:\Users\...\PosDb.db
[2025-12-13 14:30:06.123][ERROR] CRITICAL: Failed to copy database from assets
[2025-12-13 14:30:06.124][ERROR] Details: FileSystemException: Cannot open file
```

### Sending Log Files for Support

If you need to report an issue:

1. **Locate today's log file** (see above)
2. **Open the file** with Notepad or any text editor
3. **Copy the entire content** or just the error sections
4. **Send to support** with description of the issue

### Log File Management

- **Automatic Cleanup**: The app automatically deletes log files older than 7 days
- **File Size**: Each log file is typically small (a few KB)
- **No Personal Data**: Log files contain technical information only, no customer data

### Common Error Patterns in Logs

**Database Issues:**

```
[ERROR] CRITICAL: Windows database initialization failed
[ERROR] Details: Cannot open database
```

**Solution**: Check permissions or try running as Administrator

**Asset Loading Issues:**

```
[ERROR] CRITICAL: Failed to copy database from assets
[ERROR] Details: Unable to load asset
```

**Solution**: Reinstall the application

**Permission Issues:**

```
[ERROR] Failed to create directory
[ERROR] Details: Access denied
```

**Solution**: Run as Administrator or check folder permissions

### Need Help?

If you can't find the log files or need assistance:

1. Take a screenshot of the error (if visible)
2. Note the exact steps that caused the error
3. Contact support with the above information

---

**Note**: If the app shows a blank screen and no error message, the log file will still contain the error details. Always check the log file first!
