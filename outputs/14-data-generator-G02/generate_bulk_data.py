#!/usr/bin/env python3
"""
Step 14 Core Script — High-Performance Bulk Sample Data Generator
Group: G02
DBMS: Microsoft SQL Server
Database: SpaceBookingDB_Phase2
Target Volume: 100,000 SpaceBookings, ~50,000 BookingApprovals, ~50,000 SpaceUsageSessions
Timeframe: 3 Academic Years (2023–2026)
"""

import sys
import random
from datetime import datetime, timedelta
import pyodbc

# Configuration
DB_CONFIG = {
    "server": "localhost",
    "database": "SpaceBookingDB_Phase2",
    "driver": "{ODBC Driver 17 for SQL Server}",
    "trusted_connection": "yes"
}

BATCH_SIZE = 10000

# Data Domain Constants
SPACE_TYPES = ['auditorium', 'classroom', 'computer_lab', 'meeting_room']

POLICIES = [
    ('auditorium', 0, 'Requires facility staff manual approval.'),
    ('classroom', 0, 'Requires department staff manual approval.'),
    ('computer_lab', 1, 'Instant auto-approval enabled if slot is clear.'),
    ('meeting_room', 1, 'Instant auto-approval enabled if slot is clear.')
]

PURPOSE_BY_SPACE = {
    'auditorium': ['lecture', 'seminar', 'administrative_event', 'examination'],
    'classroom': ['lecture', 'examination', 'seminar'],
    'computer_lab': ['workshop', 'examination', 'student_activity'],
    'meeting_room': ['meeting', 'administrative_event', 'student_activity']
}

DEPARTMENTS = [
    'School of Computer Science',
    'Faculty of Computer Science',
    'Faculty of Information Technology',
    'Software Engineering Department',
    'Data Science & AI Department',
    'Network & Cyber Security Department'
]

VIETNAMESE_SURNAMES = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương', 'Lý']
VIETNAMESE_MIDDLES = ['Văn', 'Thị', 'Minh', 'Ngọc', 'Đức', 'Thanh', 'Quang', 'Hồng', 'Anh', 'Bảo', 'Hữu', 'Đình']
VIETNAMESE_GIVEN = ['An', 'Bình', 'Cường', 'Dũng', 'Em', 'Giang', 'Hùng', 'Hải', 'Khang', 'Linh', 'Mai', 'Nam', 'Phương', 'Quân', 'Sơn', 'Tâm', 'Tuấn', 'Việt', 'Yến']

def get_connection():
    drivers = pyodbc.drivers()
    available_driver = None
    for target in [DB_CONFIG["driver"], "{ODBC Driver 18 for SQL Server}", "{SQL Server}"]:
        if target in drivers or target.strip("{}") in [d.strip("{}") for d in drivers]:
            available_driver = target
            break
    if not available_driver:
        available_driver = drivers[0] if drivers else "{SQL Server}"
        if not available_driver.startswith("{"):
            available_driver = f"{{{available_driver}}}"

    conn_str = (
        f"DRIVER={available_driver};"
        f"SERVER={DB_CONFIG['server']};"
        f"DATABASE={DB_CONFIG['database']};"
        f"Trusted_Connection={DB_CONFIG['trusted_connection']};"
    )
    conn = pyodbc.connect(conn_str)
    return conn

def generate_full_name():
    return f"{random.choice(VIETNAMESE_SURNAMES)} {random.choice(VIETNAMESE_MIDDLES)} {random.choice(VIETNAMESE_GIVEN)}"

def main():
    print("================================================================")
    print("  STEP 14 — HIGH-PERFORMANCE BULK DATA GENERATOR")
    print(f"  TARGET DATABASE: {DB_CONFIG['database']}")
    print("================================================================")
    
    start_time = datetime.now()
    conn = get_connection()
    cursor = conn.cursor()
    cursor.fast_executemany = True
    
    # -------------------------------------------------------------------------
    # Phase 1: Seed Semesters (9 semesters across 3 Academic Years)
    # -------------------------------------------------------------------------
    print("[1/6] Seeding Semester Reference Table...")
    semesters_data = [
        ('2023-2024', 'HK1', 'Fall Semester 2023', '2023-09-04', '2024-01-14'),
        ('2023-2024', 'HK2', 'Spring Semester 2024', '2024-02-05', '2024-06-16'),
        ('2023-2024', 'HK3', 'Summer Semester 2024', '2024-06-24', '2024-08-18'),
        ('2024-2025', 'HK1', 'Fall Semester 2024', '2024-09-02', '2025-01-12'),
        ('2024-2025', 'HK2', 'Spring Semester 2025', '2025-02-03', '2025-06-15'),
        ('2024-2025', 'HK3', 'Summer Semester 2025', '2025-06-23', '2025-08-17'),
        ('2025-2026', 'HK1', 'Fall Semester 2025', '2025-09-01', '2026-01-11'),
        ('2025-2026', 'HK2', 'Spring Semester 2026', '2026-02-02', '2026-06-14'),
        ('2025-2026', 'HK3', 'Summer Semester 2026', '2026-06-22', '2026-08-16')
    ]
    cursor.executemany("""
        INSERT INTO Semester (academic_year, semester_no, semester_name, start_date, end_date)
        VALUES (?, ?, ?, ?, ?)
    """, semesters_data)
    conn.commit()
    print("      -> Seeded 9 Semesters.")

    # -------------------------------------------------------------------------
    # Phase 2: Seed SpaceTypeBookingPolicy
    # -------------------------------------------------------------------------
    print("[2/6] Seeding SpaceTypeBookingPolicy...")
    cursor.executemany("""
        INSERT INTO SpaceTypeBookingPolicy (space_type, instant_booking_eligible, policy_note)
        VALUES (?, ?, ?)
    """, POLICIES)
    conn.commit()
    print("      -> Seeded 4 SpaceTypeBookingPolicies.")

    # -------------------------------------------------------------------------
    # Phase 3: Bulk Insert CampusUsers (2,500 Users)
    # -------------------------------------------------------------------------
    print("[3/6] Generating 2,500 CampusUsers...")
    users_data = []
    roles_pool = (
        [('student', 'active')] * 1950 +
        [('student', 'inactive')] * 50 +
        [('lecturer', 'active')] * 340 +
        [('lecturer', 'suspended')] * 10 +
        [('teaching_assistant', 'active')] * 100 +
        [('facility_staff', 'active')] * 30 +
        [('department_admin', 'active')] * 15 +
        [('facility_manager', 'active')] * 5
    )
    
    student_ids = []
    lecturer_ids = []
    ta_ids = []
    staff_ids = []
    
    for idx, (role, status) in enumerate(roles_pool, start=1):
        name = generate_full_name()
        email = f"user{idx}.{role}@university.edu.vn"
        phone = f"090{idx:07d}" if idx < 10000000 else f"091{idx:07d}"
        dept = random.choice(DEPARTMENTS)
        users_data.append((name, email, phone, role, dept, status))
        
        if role == 'student':
            student_ids.append(idx)
        elif role == 'lecturer':
            lecturer_ids.append(idx)
        elif role == 'teaching_assistant':
            ta_ids.append(idx)
        elif role in ('facility_staff', 'facility_manager'):
            staff_ids.append(idx)
            
    cursor.executemany("""
        INSERT INTO CampusUser (full_name, email, phone, role, department, account_status)
        VALUES (?, ?, ?, ?, ?, ?)
    """, users_data)
    conn.commit()
    print(f"      -> Inserted {len(users_data)} CampusUsers.")

    # -------------------------------------------------------------------------
    # Phase 4: Bulk Insert CampusSpaces (60 Spaces) & CampusFacilities (180 Items)
    # -------------------------------------------------------------------------
    print("[4/6] Generating 60 CampusSpaces & 180 CampusFacilities...")
    spaces_data = []
    space_codes = []
    space_type_lookup = {}
    
    # 4 Auditoriums (Building A)
    for f in range(1, 3):
        for r in range(1, 3):
            code = f"A{f}0{r}"
            spaces_data.append((code, f"Auditorium {code}", 'auditorium', 'Building A', f, f"{f}0{r}", random.choice([150, 200, 250, 300]), 'available', 'Requires staff approval'))
            space_codes.append(code)
            space_type_lookup[code] = ('auditorium', 0)

    # 30 Classrooms (Building B & C)
    for b in ['Building B', 'Building C']:
        prefix = 'B' if b == 'Building B' else 'C'
        for f in range(1, 4):
            for r in range(1, 6):
                code = f"{prefix}{f}0{r}"
                spaces_data.append((code, f"Classroom {code}", 'classroom', b, f, f"{f}0{r}", random.choice([40, 50, 60, 80]), 'available', 'General academic teaching'))
                space_codes.append(code)
                space_type_lookup[code] = ('classroom', 0)

    # 16 Computer Labs (Building C & D)
    for b in ['Building C', 'Building D']:
        prefix = 'C' if b == 'Building C' else 'D'
        for f in range(4, 6):
            for r in range(1, 5):
                code = f"LAB-{prefix}{f}0{r}"
                spaces_data.append((code, f"Computer Lab {code}", 'computer_lab', b, f, f"{f}0{r}", random.choice([35, 40, 45, 50]), 'available', 'Instant booking for lab work'))
                space_codes.append(code)
                space_type_lookup[code] = ('computer_lab', 1)

    # 10 Meeting Rooms (Building D)
    for f in range(1, 3):
        for r in range(1, 6):
            code = f"MTG-D{f}0{r}"
            spaces_data.append((code, f"Meeting Room {code}", 'meeting_room', 'Building D', f, f"{f}0{r}", random.choice([10, 15, 20, 25]), 'available', 'Instant booking for small groups'))
            space_codes.append(code)
            space_type_lookup[code] = ('meeting_room', 1)

    cursor.executemany("""
        INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, spaces_data)
    conn.commit()

    # Facilities (unique facility_type per space)
    facilities_data = []
    facility_types = ['Projector HD', 'Whiteboard', 'Microphone System', 'Desktop Computers', 'Air Conditioner', 'Sound System']
    for sc in space_codes:
        for ftype in random.sample(facility_types, k=3):
            unique_fac_type = f"{ftype} - {sc}"
            facilities_data.append((unique_fac_type, f"Standard facility for {sc}", sc, 'available'))
            
    cursor.executemany("""
        INSERT INTO CampusFacility (facility_type, description, campus_space_code, status)
        VALUES (?, ?, ?, ?)
    """, facilities_data)
    conn.commit()
    print(f"      -> Inserted {len(spaces_data)} Spaces and {len(facilities_data)} Facilities.")

    # -------------------------------------------------------------------------
    # Phase 5: Pre-Generate SpaceMaintenance (~1,500 Records)
    # -------------------------------------------------------------------------
    print("[5/6] Pre-generating ~1,500 SpaceMaintenance Records...")
    maintenance_data = []
    out_of_service_intervals = {}
    
    start_sim_date = datetime(2023, 9, 1, 7, 0)
    end_sim_date = datetime(2026, 8, 31, 21, 0)
    
    for _ in range(1500):
        code = random.choice(space_codes)
        reporter = random.choice(staff_ids)
        assigned = random.choice(staff_ids)
        impact = 'out_of_service' if random.random() < 0.20 else 'advisory'
        problem = random.choice(['ac_failure', 'damaged_furniture', 'cleaning', 'network', 'other'])
        
        days_offset = random.randint(0, 1080)
        m_start = start_sim_date + timedelta(days=days_offset, hours=random.randint(0, 10))
        m_duration = timedelta(days=random.randint(1, 4))
        m_end = m_start + m_duration
        
        m_status = 'completed' if m_end < end_sim_date else 'in_progress'
        comp_time = m_end.strftime('%Y-%m-%d %H:%M:%S') if m_status == 'completed' else None
        
        maintenance_data.append((
            code, reporter, assigned, impact,
            f"Maintenance record for {problem} in {code}", problem,
            m_start.strftime('%Y-%m-%d %H:%M:%S'), comp_time, m_status, "Resolved successfully." if m_status == 'completed' else None
        ))
        
        if impact == 'out_of_service':
            if code not in out_of_service_intervals:
                out_of_service_intervals[code] = []
            out_of_service_intervals[code].append((m_start, m_end))

    cursor.executemany("""
        INSERT INTO SpaceMaintenance (campus_space_code, reporter_id, assigned_staff_id, impact_level, problem_description, problem_type, start_time, completion_time, status, result_note)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, maintenance_data)
    conn.commit()
    print(f"      -> Inserted {len(maintenance_data)} SpaceMaintenance records.")

    # -------------------------------------------------------------------------
    # Phase 6: Core Bulk Generator (100k SpaceBookings, ~50k Approvals, ~50k Sessions)
    # -------------------------------------------------------------------------
    print("[6/6] Generating 100,000 SpaceBookings, ~50k Approvals, and ~50k Usage Sessions...")
    
    bookings_buffer = []
    approvals_buffer = []
    sessions_buffer = []
    
    occupied_grid = {code: [] for code in space_codes}
    TOTAL_BOOKINGS = 100000
    
    current_dt = datetime(2023, 9, 1, 7, 0)
    total_days = (datetime(2026, 8, 31) - datetime(2023, 9, 1)).days + 1
    
    booking_counter = 0
    
    while booking_counter < TOTAL_BOOKINGS:
        day_offset = random.randint(0, total_days - 1)
        day_date = current_dt + timedelta(days=day_offset)
        
        booking_counter += 1
        booking_id = booking_counter
        
        code = random.choice(space_codes)
        stype, is_instant = space_type_lookup[code]
        
        if stype == 'auditorium':
            requester = random.choice(lecturer_ids * 4 + staff_ids)
        elif stype == 'classroom':
            requester = random.choice(lecturer_ids * 3 + ta_ids)
        elif stype == 'computer_lab':
            requester = random.choice(ta_ids * 3 + student_ids)
        else:
            requester = random.choice(student_ids * 2 + lecturer_ids + staff_ids)
            
        start_hour = random.randint(7, 19)
        start_min = random.choice([0, 30])
        duration_hours = random.choice([1.0, 1.5, 2.0, 3.0])
        
        req_start = datetime(day_date.year, day_date.month, day_date.day, start_hour, start_min)
        req_end = req_start + timedelta(hours=duration_hours)
        
        purpose = random.choice(PURPOSE_BY_SPACE[stype])
        participants = random.randint(5, 50)
        submitted_at = req_start - timedelta(days=random.randint(1, 14), hours=random.randint(1, 8))
        
        is_maint_conflict = False
        if code in out_of_service_intervals:
            for (m_s, m_e) in out_of_service_intervals[code]:
                if req_start < m_e and req_end > m_s:
                    is_maint_conflict = True
                    break
                    
        is_booking_conflict = False
        if not is_maint_conflict:
            for (b_s, b_e) in occupied_grid[code]:
                if req_start < b_e and req_end > b_s:
                    is_booking_conflict = True
                    break
                    
        if is_maint_conflict or is_booking_conflict:
            status = 'rejected'
        else:
            rnd = random.random()
            if rnd < 0.50:  # 50% completed -> exactly 50,000 expected
                status = 'completed'
            elif rnd < 0.65: # 15% approved
                status = 'approved'
            elif rnd < 0.80: # 15% cancelled
                status = 'cancelled'
            elif rnd < 0.85: # 5% no-show
                status = 'no-show'
            elif rnd < 0.90: # 5% pending
                status = 'pending'
            else:            # 10% rejected
                status = 'rejected'
                
            if status in ('approved', 'completed', 'no-show'):
                occupied_grid[code].append((req_start, req_end))
                
        bookings_buffer.append((
            requester, code,
            req_start.strftime('%Y-%m-%d %H:%M:%S'),
            req_end.strftime('%Y-%m-%d %H:%M:%S'),
            purpose, participants, status, is_instant,
            submitted_at.strftime('%Y-%m-%d %H:%M:%S')
        ))
        
        # Generate matching BookingApproval for non-instant bookings (~50k target)
        if is_instant == 0 and status in ('approved', 'completed', 'no-show', 'rejected'):
            staff_reviewer = random.choice(staff_ids)
            decision = 'rejected' if status == 'rejected' else 'approved'
            dec_time = submitted_at + timedelta(hours=random.randint(1, 24))
            if dec_time > req_start:
                dec_time = req_start - timedelta(minutes=30)
                
            dec_note = "Approved by staff." if decision == 'approved' else None
            rej_reason = "Schedule conflict or room policy violation." if decision == 'rejected' else None
            
            approvals_buffer.append((
                booking_id, staff_reviewer, decision,
                dec_time.strftime('%Y-%m-%d %H:%M:%S'),
                dec_note, rej_reason
            ))
            
        # Generate matching SpaceUsageSession for completed bookings (~50k target)
        if status == 'completed':
            checkin_staff = random.choice(staff_ids)
            actual_start = req_start + timedelta(minutes=random.randint(-5, 10))
            actual_end = req_end + timedelta(minutes=random.randint(-5, 15))
            
            sessions_buffer.append((
                booking_id, checkin_staff,
                actual_start.strftime('%Y-%m-%d %H:%M:%S'),
                "Clean condition. Projector and AC functional.",
                actual_end.strftime('%Y-%m-%d %H:%M:%S'),
                "Good condition. Returned key to staff.",
                "Session completed without incidents."
            ))

    print(f"      -> In-memory simulation generated:")
    print(f"         - SpaceBookings    : {len(bookings_buffer):,}")
    print(f"         - BookingApprovals : {len(approvals_buffer):,}")
    print(f"         - UsageSessions    : {len(sessions_buffer):,}")

    # Bulk Ingestion into SQL Server using fast_executemany
    print("\n[Ingest] Bulk inserting SpaceBookings into SpaceBookingDB_Phase2...")
    cursor.execute("ALTER TABLE SpaceBooking DISABLE TRIGGER ALL;")
    conn.commit()
    
    for i in range(0, len(bookings_buffer), BATCH_SIZE):
        batch = bookings_buffer[i:i+BATCH_SIZE]
        cursor.executemany("""
            INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, is_instant_booking, submitted_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, batch)
        conn.commit()
        print(f"         - Inserted rows {i+1:,} to {min(i+BATCH_SIZE, len(bookings_buffer)):,}")
        
    cursor.execute("ALTER TABLE SpaceBooking ENABLE TRIGGER ALL;")
    conn.commit()
    
    print("[Ingest] Bulk inserting BookingApprovals into SpaceBookingDB_Phase2...")
    for i in range(0, len(approvals_buffer), BATCH_SIZE):
        batch = approvals_buffer[i:i+BATCH_SIZE]
        cursor.executemany("""
            INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_time, decision_note, rejection_reason)
            VALUES (?, ?, ?, ?, ?, ?)
        """, batch)
        conn.commit()
        print(f"         - Inserted rows {i+1:,} to {min(i+BATCH_SIZE, len(approvals_buffer)):,}")

    print("[Ingest] Bulk inserting SpaceUsageSessions into SpaceBookingDB_Phase2...")
    for i in range(0, len(sessions_buffer), BATCH_SIZE):
        batch = sessions_buffer[i:i+BATCH_SIZE]
        cursor.executemany("""
            INSERT INTO SpaceUsageSession (space_booking_id, checked_in_by, actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, batch)
        conn.commit()
        print(f"         - Inserted rows {i+1:,} to {min(i+BATCH_SIZE, len(sessions_buffer)):,}")

    conn.close()
    
    elapsed = (datetime.now() - start_time).total_seconds()
    print("================================================================")
    print(f"  BULK GENERATION COMPLETED SUCCESSFULLY IN {elapsed:.2f} SECONDS!")
    print("================================================================")

if __name__ == "__main__":
    main()
