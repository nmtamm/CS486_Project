#!/usr/bin/env python3
"""
Step 14 Diagnostic Script — Test MS SQL Server Connection & Table Schema Readiness
Group: G02
DBMS: Microsoft SQL Server
Database: SpaceBookingDB_Phase2
"""

import sys
import pyodbc

# Database configuration settings
DB_CONFIG = {
    "server": "192.168.0.107,1433",
    "database": "SpaceBookingDB_Phase2",
    "driver": "{ODBC Driver 17 for SQL Server}",  # fallback to '{SQL Server}' if 17 is missing
    "trusted_connection": "no",  # Windows Authentication
    "user_name":"sa",
    "password":"Minhtam01@"
}

REQUIRED_TABLES = [
    'SpaceTypeBookingPolicy',
    'CampusUser',
    'CampusSpace',
    'CampusFacility',
    'Semester',
    'SpaceBooking',
    'BookingApproval',
    'SpaceUsageSession',
    'SpaceMaintenance',
    'FacilityMaintenance'
]

def test_connection():
    drivers = pyodbc.drivers()
    print("Available ODBC Drivers:", drivers)
    
    available_driver = None
    for target in [DB_CONFIG["driver"], "{ODBC Driver 18 for SQL Server}", "{SQL Server}"]:
        if target in drivers or target.strip("{}") in [d.strip("{}") for d in drivers]:
            available_driver = target
            break
            
    if not available_driver:
        if drivers:
            available_driver = drivers[0]
            if not available_driver.startswith("{"):
                available_driver = f"{{{available_driver}}}"
        else:
            print("[ERROR] No ODBC drivers found on system!")
            sys.exit(1)
            
    print(f"Using ODBC Driver: {available_driver}")
    
    conn_str = (
        f"DRIVER={available_driver};"
        f"SERVER={DB_CONFIG['server']};"
        f"DATABASE={DB_CONFIG['database']};"
        f"Trusted_Connection={DB_CONFIG['trusted_connection']};"
        f"UID={DB_CONFIG['user_name']};"
        f"PWD={DB_CONFIG['password']}"
    )
    
    print(f"Connecting to MS SQL Server '{DB_CONFIG['server']}', database '{DB_CONFIG['database']}'...")
    
    try:
        conn = pyodbc.connect(conn_str, timeout=5)
        cursor = conn.cursor()
        
        cursor.execute("SELECT @@VERSION AS Version, DB_NAME() AS CurrentDB")
        row = cursor.fetchone()
        print("\n[SUCCESS] Connected to SQL Server!")
        print(f"  Server Info: {row.Version.splitlines()[0]}")
        print(f"  Database Name: {row.CurrentDB}\n")
        
        # Verify required tables
        cursor.execute("""
            SELECT TABLE_NAME 
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_TYPE = 'BASE TABLE'
        """)
        existing_tables = set(r[0] for r in cursor.fetchall())
        
        print("Checking Database Table Readiness:")
        missing_tables = []
        for tbl in REQUIRED_TABLES:
            status = "FOUND" if tbl in existing_tables else "MISSING"
            print(f"  - Table {tbl:<25}: [{status}]")
            if tbl not in existing_tables:
                missing_tables.append(tbl)
                
        if missing_tables:
            print(f"\n[WARNING] Missing {len(missing_tables)} tables: {missing_tables}")
            print("Please execute 'outputs/10-schema-migration-G02.sql' to create the SpaceBookingDB_Phase2 database and schema.")
            sys.exit(1)
        else:
            print("\nAll required tables are present in SpaceBookingDB_Phase2. Ready for bulk data generation!")
            
        conn.close()
        return True
        
    except Exception as e:
        print(f"\n[ERROR] Connection failed: {e}")
        print("Troubleshooting Tip: Verify SQL Server service is running and 'SpaceBookingDB_Phase2' exists.")
        sys.exit(1)

if __name__ == "__main__":
    test_connection()
