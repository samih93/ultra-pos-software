import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constances/table_constant.dart';
import 'file_logger.dart';

class PosDbHelper {
  PosDbHelper._();

  static final PosDbHelper db = PosDbHelper._();

  late Database database;

  // Safe logging that won't break the app if logging fails
  Future<void> _safeLog(String message) async {
    try {
      await FileLogger().log(message);
    } catch (e) {
      debugPrint('[FileLogger Error] $e');
    }
  }

  Future<void> initMobile() async {
    try {
      await _safeLog('═══ initMobile Started ═══');
      const databaseVersion = 111;
      var databasesPath = await getDatabasesPath();
      var completePath = path.join(databasesPath, "PosDb.db");
      await _safeLog('Mobile DB path: $completePath');
      print(completePath);
      var exists = await databaseExists(completePath);
      await _safeLog('Database exists: $exists');

      if (!exists) {
        await _safeLog('Database does not exist, copying from assets...');
        // Ensure the directory exists
        try {
          await Directory(path.dirname(completePath)).create(recursive: true);
          await _safeLog('Created database directory');
        } catch (e) {
          await _safeLog('Directory creation error: $e');
        }

        // Load from asset
        await _safeLog('Loading database from assets...');
        ByteData data = await rootBundle.load(
          path.join("assets/db/", "PosDb.db"),
        );
        await _safeLog(
          'Database loaded from assets (${data.lengthInBytes} bytes)',
        );
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        // Write to file
        await File(completePath).writeAsBytes(bytes, flush: true);
        await _safeLog('Database file written successfully');
      }

      Future<bool> isColumnExists(
        Database db,
        String tableName,
        String columnName,
      ) async {
        final result = await db.rawQuery('PRAGMA table_info($tableName)');
        for (final row in result) {
          if (row['name'] == columnName) {
            return true;
          }
        }
        return false;
      }

      Future<void> addColumnIfNotExists(
        Database db,
        String tableName,
        String columnName,
        String columnDefinition,
      ) async {
        if (!await isColumnExists(db, tableName, columnName)) {
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
          );
        }
      }

      // Open DB using default factory
      await _safeLog('Opening mobile database...');
      database = await openDatabase(
        completePath,
        version: databaseVersion,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 111) {
            await Future.wait([
              addColumnIfNotExists(
                db,
                TableConstant.receiptTable,
                'isPaid',
                'INTEGER default 1',
              ),
              addColumnIfNotExists(
                db,
                TableConstant.receiptTable,
                'remainingAmount',
                'REAL',
              ),
              db.execute('''
        CREATE TABLE IF NOT EXISTS ${TableConstant.financialTransactionTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transactionDate TEXT NOT NULL,
          primaryAmount REAL,
          secondaryAmount REAL,
          isTransactionInPrimary INTEGER DEFAULT 0,
          dollarRate REAL,
          paymentType TEXT NOT NULL,
          flow TEXT NOT NULL,
          transactionType TEXT NOT NULL,
          receiptId INTEGER,
          expenseId INTEGER,
          customerId INTEGER,
          shiftId INTEGER,
          note TEXT,
          fromCash INTEGER DEFAULT 0,
          userId INTEGER,
    FOREIGN KEY (userId) REFERENCES ${TableConstant.userTable}(id)
        );
      '''),
              addColumnIfNotExists(
                db,
                TableConstant.settings,
                'telegramChatId',
                'TEXT',
              ),
              //! core 1.1.10
              addColumnIfNotExists(
                db,
                TableConstant.categoryTable,
                'hideOnMenu',
                'INTEGER default 0',
              ),

              //! core 1.1.13
              db.execute('''
                    CREATE TABLE IF NOT EXISTS ${TableConstant.employeeTable} (
                      id INTEGER PRIMARY KEY AUTOINCREMENT,
                      name TEXT,
                      phoneNumber TEXT,
                      email TEXT,
                      active INTERGER DEFAULT 1,
                      salaryPerHour REAL,
                      profilePicture BLOB
                    );
                  '''),
              db.execute('''
                    CREATE TABLE IF NOT EXISTS ${TableConstant.attendanceTable} (
                      id INTEGER PRIMARY KEY AUTOINCREMENT,
                      employeeId INTEGER,
                      status TEXT,
                      checkInTime TEXT NOT NULL,
                      checkOutTime TEXT ,
                      checkedImage BLOB,
                      workedHours REAL,
                      overtimeHours REAL,
                      FOREIGN KEY (employeeId) REFERENCES ${TableConstant.employeeTable}(id)
                    );
                  '''),
              addColumnIfNotExists(
                db,
                TableConstant.financialTransactionTable,
                'employeeId',
                'INTEGER',
              ),

              addColumnIfNotExists(
                db,
                TableConstant.quickSelectProductsTable,
                'sortOrder',
                'INTEGER default 0',
              ),
              addColumnIfNotExists(
                db,
                TableConstant.productTable,
                'description',
                'TEXT',
              ),
              // V1.1.51
              // Subscriptions table
              db.execute('''
            CREATE TABLE IF NOT EXISTS ${TableConstant.subscriptionsTable} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customerId INTEGER NOT NULL,
              startDate TEXT NOT NULL,
              nextPaymentDate TEXT NOT NULL,
              status TEXT NOT NULL DEFAULT 'active',
              monthlyAmount REAL NOT NULL,
              lastPaidDate TEXT,
              note TEXT,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL,
              FOREIGN KEY (customerId) REFERENCES ${TableConstant.customersTable}(id)
            );
          '''),

              // Subscription cycles table
              db.execute('''
            CREATE TABLE IF NOT EXISTS ${TableConstant.subscriptionCyclesTable} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              subscriptionId INTEGER NOT NULL,
              cycleStartDate TEXT NOT NULL,
              cycleEndDate TEXT NOT NULL,
              status TEXT NOT NULL DEFAULT 'unpaid',
              transactionId INTEGER,
              paidByUserId INTEGER,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL,
              FOREIGN KEY (subscriptionId) REFERENCES ${TableConstant.subscriptionsTable}(id),
              FOREIGN KEY (transactionId) REFERENCES ${TableConstant.financialTransactionTable}(id),
              FOREIGN KEY (paidByUserId) REFERENCES ${TableConstant.userTable}(id)
            );
          '''),
              //! Add opening hours as JSON string
              addColumnIfNotExists(
                db,
                TableConstant.settings,
                'openingHours',
                'TEXT',
              ),
            ]);
          }
        },
      );
      await _safeLog('Mobile database opened successfully');
      await _safeLog('═══ initMobile Completed ═══');
    } catch (e, stackTrace) {
      await _safeLog('ERROR in initMobile: $e');
      await _safeLog('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future initWindows() async {
    try {
      await _safeLog('═══ initWindows Started ═══');
      sqfliteFfiInit();
      await _safeLog('sqfliteFfiInit completed');
      const databaseVersion = 111;

      var databaseFactory = databaseFactoryFfi;
      var databasesPath = await databaseFactory.getDatabasesPath();
      var completepath = path.join(databasesPath, "PosDb.db");

      var exists = await databaseFactory.databaseExists(completepath);
      await _safeLog('Database exists: $exists');
      debugPrint("database : $exists");
      if (!exists) {
        //! Should happen only the first time you launch your application

        //! NOTE------------START COPY DB FROM MY ASSETS ------------------
        await _safeLog('Database does not exist, copying from assets...');
        debugPrint("Creating new copy from asset");

        //! Make sure the parent directory exists
        try {
          await Directory(path.dirname(completepath)).create(recursive: true);
          await _safeLog('Created database directory');
        } catch (e) {
          await _safeLog('Directory creation error: $e');
        }

        //! Copy from asset
        await _safeLog('Loading database from assets...');
        ByteData data = await rootBundle.load(
          path.join("assets/db/", "PosDb.db"),
        );
        await _safeLog(
          'Database loaded from assets (${data.lengthInBytes} bytes)',
        );
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        //! Write and flush the bytes written
        await File(completepath).writeAsBytes(bytes, flush: true);
        await _safeLog('Database file written successfully');
      } else {
        await _safeLog('Using existing database');
      }

      Future<bool> isColumnExists(
        Database db,
        String tableName,
        String columnName,
      ) async {
        final result = await db.rawQuery('PRAGMA table_info($tableName)');
        for (final row in result) {
          if (row['name'] == columnName) {
            return true;
          }
        }
        return false;
      }

      // Add column if it does not exist
      Future<void> addColumnIfNotExists(
        Database db,
        String tableName,
        String columnName,
        String columnDefinition,
      ) async {
        if (!await isColumnExists(db, tableName, columnName)) {
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
          );
        }
      }

      await _safeLog('Opening Windows database...');
      database = await databaseFactory.openDatabase(
        completepath,
        options: OpenDatabaseOptions(
          version: databaseVersion,
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 111) {
              await Future.wait([
                db.execute('''
CREATE TABLE IF NOT EXISTS "${TableConstant.restaurantStockTransactionTable}" (
	"id"	INTEGER UNIQUE,
	"stockId"  INTEGER,
  "employeeId" INTEGER,
  "itemName" TEXT,
  "unitType" TEXT,
  "pricePerUnit" REAL,
  "transactionQty" REAL,
  "qtyAsGram" REAL,
  "qtyAsPortion" REAL,
  "transactionDate" TEXT,
  "transactionReason" TEXT,
  "transactionType" TEXT,
  "wasteType" TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("stockId") REFERENCES "${TableConstant.restaurantStockTable}"("id"),
  FOREIGN KEY("employeeId") REFERENCES "${TableConstant.userTable}"("id")
);

      '''),

                // ! quiver 1.4.7
                addColumnIfNotExists(
                  db,
                  TableConstant.restaurantStockTable,
                  'wasteFormula',
                  'Text',
                ),
                // ! quiver 1.4.8
                addColumnIfNotExists(
                  db,
                  TableConstant.categoryTable,
                  'section',
                  'Text default "kitchen"',
                ),
                // ! quiver 1.5.2
                addColumnIfNotExists(
                  db,
                  TableConstant.productTable,
                  'sortOrder',
                  'INTEGER default 0',
                ),
                // ! quiver 1.5.6
                addColumnIfNotExists(
                  db,
                  TableConstant.productTable,
                  'minSellingPrice',
                  'REAL default 0',
                ),
                // ! quiver 1.5.7
                addColumnIfNotExists(
                  db,
                  TableConstant.productTable,
                  'isWeighted',
                  'INTEGER default 0',
                ),
                addColumnIfNotExists(
                  db,
                  TableConstant.productTable,
                  'plu',
                  'INTEGER',
                ),
                //! quiver V1.6.3
                addColumnIfNotExists(
                  db,
                  TableConstant.restaurantStockTransactionTable,
                  'productId',
                  'INTEGER',
                ),
                //! quiver V1.6.4
                addColumnIfNotExists(
                  db,
                  TableConstant.productTable,
                  'isOffer',
                  'INTEGER default 0',
                ),
                //! quiver V1.6.5
                addColumnIfNotExists(
                  db,
                  TableConstant.restaurantStockTransactionTable,
                  'oldQty',
                  'REAL',
                ),

                //! quiver  V1.6.7
                addColumnIfNotExists(
                  db,
                  TableConstant.receiptTable,
                  'nbOfCustomers',
                  'INTEGER default 1',
                ),
                addColumnIfNotExists(
                  db,
                  TableConstant.tablesTable,
                  'nbOfCustomers',
                  'INTEGER default 1',
                ),
                //! quiver  V1.7.1
                addColumnIfNotExists(
                  db,
                  TableConstant.settings,
                  'note',
                  'TEXT',
                ),

                //! quiver  V1.7.2
                db.execute('''
CREATE TABLE IF NOT EXISTS ${TableConstant.quickSelectProductsTable} (
    id INTEGER PRIMARY KEY ,
    productId INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (productId) REFERENCES products(id)
);
      '''),

                //! quiver  V1.7.3
                addColumnIfNotExists(
                  db,
                  TableConstant.suppliers,
                  'contactDetails',
                  'TEXT',
                ),
                addColumnIfNotExists(
                  db,
                  TableConstant.suppliers,
                  'supplierAddress',
                  'TEXT',
                ),

                //! quiver  V1.7.6
                addColumnIfNotExists(
                  db,
                  TableConstant.receiptTable,
                  'isPaid',
                  'INTEGER default 1',
                ),
                addColumnIfNotExists(
                  db,
                  TableConstant.receiptTable,
                  'remainingAmount',
                  'REAL',
                ),

                db.execute('''
        CREATE TABLE IF NOT EXISTS ${TableConstant.financialTransactionTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transactionDate TEXT NOT NULL,
          primaryAmount REAL,
          secondaryAmount REAL,
          isTransactionInPrimary INTEGER DEFAULT 0,
          dollarRate REAL,
          paymentType TEXT NOT NULL,
          flow TEXT NOT NULL,
          transactionType TEXT NOT NULL,
          receiptId INTEGER,
          expenseId INTEGER,
          customerId INTEGER,
          shiftId INTEGER,
          note TEXT,       
          fromCash INTEGER DEFAULT 0,
          userId INTEGER,
    FOREIGN KEY (userId) REFERENCES ${TableConstant.userTable}(id)
        );
      '''),
                addColumnIfNotExists(
                  db,
                  TableConstant.settings,
                  'telegramChatId',
                  'TEXT',
                ),
                //! core 1.1.10
                addColumnIfNotExists(
                  db,
                  TableConstant.categoryTable,
                  'hideOnMenu',
                  'INTEGER default 0',
                ),

                //! core 1.1.13
                db.execute('''
                    CREATE TABLE IF NOT EXISTS ${TableConstant.employeeTable} (
                      id INTEGER PRIMARY KEY AUTOINCREMENT,
                      name TEXT,
                      phoneNumber TEXT,
                      email TEXT,
                      active INTERGER DEFAULT 1,
                      salaryPerHour REAL,
                      profilePicture BLOB
                    );
                  '''),
                db.execute('''
                    CREATE TABLE IF NOT EXISTS ${TableConstant.attendanceTable} (
                      id INTEGER PRIMARY KEY AUTOINCREMENT,
                      employeeId INTEGER,
                      status TEXT,
                      checkInTime TEXT NOT NULL,
                      checkOutTime TEXT ,
                      checkedImage BLOB,
                      workedHours REAL,
                      overtimeHours REAL,
                      FOREIGN KEY (employeeId) REFERENCES ${TableConstant.employeeTable}(id)
                    );
                  '''),
                addColumnIfNotExists(
                  db,
                  TableConstant.financialTransactionTable,
                  'employeeId',
                  'INTEGER',
                ),
                // V1.1.16
                addColumnIfNotExists(
                  db,
                  TableConstant.quickSelectProductsTable,
                  'sortOrder',
                  'INTEGER default 0',
                ),

                addColumnIfNotExists(
                  db,
                  TableConstant.productTable,
                  'description',
                  'TEXT',
                ),

                //V1.1.51
                // Subscriptions table
                db.execute('''
                  CREATE TABLE IF NOT EXISTS ${TableConstant.subscriptionsTable} (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    customerId INTEGER NOT NULL,
                    startDate TEXT NOT NULL,
                    nextPaymentDate TEXT NOT NULL,
                    status TEXT NOT NULL DEFAULT 'active',
                    monthlyAmount REAL NOT NULL,
                    lastPaidDate TEXT,
                    createdAt TEXT NOT NULL,
                    updatedAt TEXT NOT NULL,
                    FOREIGN KEY (customerId) REFERENCES ${TableConstant.customersTable}(id)
                  );
                '''),

                // Subscription cycles table
                db.execute('''
                  CREATE TABLE IF NOT EXISTS ${TableConstant.subscriptionCyclesTable} (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    subscriptionId INTEGER NOT NULL,
                    cycleStartDate TEXT NOT NULL,
                    cycleEndDate TEXT NOT NULL,
                    status TEXT NOT NULL DEFAULT 'unpaid',
                    transactionId INTEGER,
                    paidByUserId INTEGER,
                    createdAt TEXT NOT NULL,
                    updatedAt TEXT NOT NULL,
                    FOREIGN KEY (subscriptionId) REFERENCES ${TableConstant.subscriptionsTable}(id),
                    FOREIGN KEY (transactionId) REFERENCES ${TableConstant.financialTransactionTable}(id),
                    FOREIGN KEY (paidByUserId) REFERENCES ${TableConstant.userTable}(id)
                  );
                '''),

                //! Add opening hours as JSON string
                addColumnIfNotExists(
                  db,
                  TableConstant.settings,
                  'openingHours',
                  'TEXT',
                ),
              ]);
            }
          },
        ),
      );
      await _safeLog('Windows database opened successfully');
      await _safeLog('═══ initWindows Completed ═══');
    } catch (e, stackTrace) {
      await _safeLog('ERROR in initWindows: $e');
      await _safeLog('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
