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
from dotenv import load_dotenv
import os

load_dotenv()

# Configuration
# If you use local host SQL server
DB_CONFIG = {
    "server": "localhost",
    "database": "SpaceBookingDB_Phase2",
    "driver": "{ODBC Driver 17 for SQL Server}",
    "trusted_connection": "yes",
}

# If you use remote SQL server, uncomment the following
# DB_CONFIG = {
#     "server": os.getenv("server_name"), # (e.g., "remote ip,1433")
#     "database": "SpaceBookingDB_Phase2",
#     "driver": "{ODBC Driver 17 for SQL Server}",
#     "trusted_connection": "no",
#     "user_name": os.getenv("user_name"),
#     "password": os.getenv("password"),
# }

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

    # If you use local host SQL server
    conn_str = (
        f"DRIVER={available_driver};"
        f"SERVER={DB_CONFIG['server']};"
        f"DATABASE={DB_CONFIG['database']};"
        f"Trusted_Connection={DB_CONFIG['trusted_connection']};"
    )

    # If you use remote SQL server, uncomment the following
    # conn_str = (
    #     f"DRIVER={available_driver};"
    #     f"SERVER={DB_CONFIG['server']};"
    #     f"DATABASE={DB_CONFIG['database']};"
    #     f"Trusted_Connection={DB_CONFIG['trusted_connection']};"
    #     f"UID={DB_CONFIG['user_name']};"
    #     f"PWD={DB_CONFIG['password']}"
    # )

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

    # =====================================================================
    # CONFIGURATION
    # =====================================================================

    TOTAL_BOOKINGS = 500000

    # Number of bookings generated in memory before writing to database.
    PATCH_SIZE = 5000

    # Number of rows per executemany() call.
    BATCH_SIZE = 1000

    # Maximum number of spaces that can be currently unavailable
    # because of active out_of_service maintenance.
    #
    # With 60 spaces:
    #     60 total
    #     <= 20 unavailable
    #     >= 40 available
    #
    MAX_ACTIVE_MAINTENANCE_SPACES = 20
    CANCELLATION_RATE = 0.20
    REJECTION_RATE = 0.10

    try:

        # =================================================================
        # Phase 1: Seed Semesters
        # =================================================================

        print("[1/6] Seeding Semester Reference Table...")

        semesters_data = [
            (
                '2023-2024',
                'HK1',
                'Fall Semester 2023',
                '2023-09-04',
                '2024-01-14'
            ),
            (
                '2023-2024',
                'HK2',
                'Spring Semester 2024',
                '2024-02-05',
                '2024-06-16'
            ),
            (
                '2023-2024',
                'HK3',
                'Summer Semester 2024',
                '2024-06-24',
                '2024-08-18'
            ),
            (
                '2024-2025',
                'HK1',
                'Fall Semester 2024',
                '2024-09-02',
                '2025-01-12'
            ),
            (
                '2024-2025',
                'HK2',
                'Spring Semester 2025',
                '2025-02-03',
                '2025-06-15'
            ),
            (
                '2024-2025',
                'HK3',
                'Summer Semester 2025',
                '2025-06-23',
                '2025-08-17'
            ),
            (
                '2025-2026',
                'HK1',
                'Fall Semester 2025',
                '2025-09-01',
                '2026-01-11'
            ),
            (
                '2025-2026',
                'HK2',
                'Spring Semester 2026',
                '2026-02-02',
                '2026-06-14'
            ),
            (
                '2025-2026',
                'HK3',
                'Summer Semester 2026',
                '2026-06-22',
                '2026-08-16'
            )
        ]

        cursor.executemany(
            """
            INSERT INTO Semester
            (
                academic_year,
                semester_no,
                semester_name,
                start_date,
                end_date
            )
            VALUES (?, ?, ?, ?, ?)
            """,
            semesters_data
        )

        conn.commit()

        print("      -> Seeded 9 Semesters.")

        # =================================================================
        # Phase 2: Seed SpaceTypeBookingPolicy
        # =================================================================

        print("[2/6] Seeding SpaceTypeBookingPolicy...")

        cursor.executemany(
            """
            INSERT INTO SpaceTypeBookingPolicy
            (
                space_type,
                instant_booking_eligible,
                policy_note
            )
            VALUES (?, ?, ?)
            """,
            POLICIES
        )

        conn.commit()

        print("      -> Seeded 4 SpaceTypeBookingPolicies.")

        # =================================================================
        # Phase 3: Bulk Insert CampusUsers
        # =================================================================

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

        for idx, (role, status) in enumerate(
            roles_pool,
            start=1
        ):

            name = generate_full_name()

            email = (
                f"user{idx}.{role}@university.edu.vn"
            )

            phone = (
                f"090{idx:07d}"
                if idx < 10000000
                else f"091{idx:07d}"
            )

            dept = random.choice(
                DEPARTMENTS
            )

            users_data.append(
                (
                    name,
                    email,
                    phone,
                    role,
                    dept,
                    status
                )
            )

            if role == 'student':
                student_ids.append(idx)

            elif role == 'lecturer':
                lecturer_ids.append(idx)

            elif role == 'teaching_assistant':
                ta_ids.append(idx)

            elif role in (
                'facility_staff',
                'facility_manager'
            ):
                staff_ids.append(idx)

        cursor.executemany(
            """
            INSERT INTO CampusUser
            (
                full_name,
                email,
                phone,
                role,
                department,
                account_status
            )
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            users_data
        )

        conn.commit()

        print(
            f"      -> Inserted "
            f"{len(users_data):,} CampusUsers."
        )

        # =================================================================
        # Phase 4: Bulk Insert CampusSpaces & CampusFacilities
        # =================================================================

        print(
            "[4/6] Generating 60 CampusSpaces "
            "& 180 CampusFacilities..."
        )

        spaces_data = []

        space_codes = []

        space_type_lookup = {}

        space_capacity_lookup = {}

        # -------------------------------------------------------------
        # 4 Auditoriums
        # -------------------------------------------------------------

        for f in range(1, 3):

            for r in range(1, 3):

                code = f"A{f}0{r}"

                capacity = random.choice(
                    [150, 200, 250, 300]
                )

                spaces_data.append(
                    (
                        code,
                        f"Auditorium {code}",
                        'auditorium',
                        'Building A',
                        f,
                        f"{f}0{r}",
                        capacity,
                        'available',
                        'Requires staff approval'
                    )
                )

                space_codes.append(code)

                space_type_lookup[code] = (
                    'auditorium',
                    0
                )

                space_capacity_lookup[code] = capacity

        # -------------------------------------------------------------
        # 30 Classrooms
        # -------------------------------------------------------------

        for b in [
            'Building B',
            'Building C'
        ]:

            prefix = (
                'B'
                if b == 'Building B'
                else 'C'
            )

            for f in range(1, 4):

                for r in range(1, 6):

                    code = f"{prefix}{f}0{r}"

                    capacity = random.choice(
                        [30, 40, 50, 60]
                    )

                    spaces_data.append(
                        (
                            code,
                            f"Classroom {code}",
                            'classroom',
                            b,
                            f,
                            f"{f}0{r}",
                            capacity,
                            'available',
                            'General academic teaching'
                        )
                    )

                    space_codes.append(code)

                    space_type_lookup[code] = (
                        'classroom',
                        0
                    )

                    space_capacity_lookup[code] = capacity

        # -------------------------------------------------------------
        # 16 Computer Labs
        # -------------------------------------------------------------

        for b in [
            'Building C',
            'Building D'
        ]:

            prefix = (
                'C'
                if b == 'Building C'
                else 'D'
            )

            for f in range(4, 6):

                for r in range(1, 5):

                    code = (
                        f"LAB-{prefix}{f}0{r}"
                    )

                    capacity = random.choice(
                        [35, 40, 45, 50]
                    )

                    spaces_data.append(
                        (
                            code,
                            f"Computer Lab {code}",
                            'computer_lab',
                            b,
                            f,
                            f"{f}0{r}",
                            capacity,
                            'available',
                            'Instant booking for lab work'
                        )
                    )

                    space_codes.append(code)

                    space_type_lookup[code] = (
                        'computer_lab',
                        1
                    )

                    space_capacity_lookup[code] = capacity

        # -------------------------------------------------------------
        # 10 Meeting Rooms
        # -------------------------------------------------------------

        for f in range(1, 3):

            for r in range(1, 6):

                code = f"MTG-D{f}0{r}"

                capacity = random.choice(
                    [10, 15, 20, 25]
                )

                spaces_data.append(
                    (
                        code,
                        f"Meeting Room {code}",
                        'meeting_room',
                        'Building D',
                        f,
                        f"{f}0{r}",
                        capacity,
                        'available',
                        'Instant booking for small groups'
                    )
                )

                space_codes.append(code)

                space_type_lookup[code] = (
                    'meeting_room',
                    1
                )

                space_capacity_lookup[code] = capacity

        # -------------------------------------------------------------
        # Insert spaces
        # -------------------------------------------------------------

        cursor.executemany(
            """
            INSERT INTO CampusSpace
            (
                campus_space_code,
                space_name,
                space_type,
                building,
                floor,
                room_number,
                capacity,
                current_status,
                usage_policy
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            spaces_data
        )

        conn.commit()

        # -------------------------------------------------------------
        # Generate facilities
        # -------------------------------------------------------------

        facilities_data = []

        facility_types = [
            "Projector",
            "Whiteboard",
            "Microphone System",
            "Desktop Computers",
            "Air Conditioner",
            "Sound System"
        ]

        for sc in space_codes:

            for ftype in random.sample(
                facility_types,
                k=3
            ):
                facilities_data.append(
                    (
                        ftype,
                        f"Standard facility for {sc}",
                        sc,
                        "available"
                    )
                )

        cursor.executemany(
            """
            INSERT INTO CampusFacility
            (
                facility_type,
                description,
                campus_space_code,
                status
            )
            VALUES (?, ?, ?, ?)
            """,
            facilities_data
        )

        conn.commit()

        print(
            f"      -> Inserted "
            f"{len(spaces_data):,} Spaces and "
            f"{len(facilities_data):,} Facilities."
        )

        # -------------------------------------------------------------
        # Build facility -> space lookup
        # -------------------------------------------------------------

        cursor.execute(
            """
            SELECT
                campus_facility_id,
                campus_space_code
            FROM CampusFacility
            """
        )

        facility_space_lookup = {
            row[0]: row[1]
            for row in cursor.fetchall()
        }

        # =================================================================
        # Phase 5: Maintenance Data
        # =================================================================

        print(
            "[5/6] Pre-generating maintenance records..."
        )

        # -------------------------------------------------------------
        # IMPORTANT:
        #
        # Only these spaces are allowed to have CURRENT active
        # out_of_service maintenance.
        #
        # Historical/completed maintenance can still exist on every
        # space.
        # -------------------------------------------------------------

        active_maintenance_spaces = set(
            random.sample(
                space_codes,
                k=min(
                    MAX_ACTIVE_MAINTENANCE_SPACES,
                    len(space_codes)
                )
            )
        )

        print(
            f"      -> Maximum active maintenance spaces: "
            f"{MAX_ACTIVE_MAINTENANCE_SPACES}"
        )

        print(
            "      -> Controlled active maintenance spaces:"
        )

        print(
            "         "
            + ", ".join(
                sorted(active_maintenance_spaces)
            )
        )

        start_sim_date = datetime(
            2023,
            9,
            1,
            7,
            0
        )

        end_sim_date = datetime(
            2026,
            8,
            31,
            21,
            0
        )

        # =============================================================
        # Phase 5A: SpaceMaintenance
        # =============================================================

        print(
            "[5A] Generating ~100000 SpaceMaintenance records..."
        )

        maintenance_data = []

        for _ in range(100000):

            code = random.choice(
                space_codes
            )

            reporter = random.choice(
                staff_ids
            )

            assigned = random.choice(
                staff_ids
            )

            problem = random.choice(
                [
                    'ac_failure',
                    'damaged_furniture',
                    'cleaning',
                    'network',
                    'other'
                ]
            )

            days_offset = random.randint(
                0,
                1080
            )

            m_start = (
                start_sim_date
                + timedelta(
                    days=days_offset,
                    hours=random.randint(0, 10)
                )
            )

            m_duration = timedelta(
                days=random.randint(1, 4)
            )

            m_end = (
                m_start +
                m_duration
            )

            # ---------------------------------------------------------
            # Maintenance status
            #
            # 10% reported
            # 15% in_progress
            # 75% completed
            # ---------------------------------------------------------

            status_roll = random.random()

            if status_roll < 0.10:

                m_status = 'reported'

                comp_time = None

            elif status_roll < 0.25:

                m_status = 'in_progress'

                comp_time = None

            else:

                m_status = 'completed'

                comp_time = (
                    m_end.strftime(
                        '%Y-%m-%d %H:%M:%S'
                    )
                )

            # ---------------------------------------------------------
            # CONTROLLED IMPACT
            #
            # Active out_of_service is only allowed on the selected
            # active_maintenance_spaces.
            #
            # All other spaces can have advisory maintenance or
            # completed historical out_of_service maintenance.
            # ---------------------------------------------------------

            if (
                m_status in (
                    'reported',
                    'in_progress'
                )
                and
                code in active_maintenance_spaces
            ):

                impact = 'out_of_service'

            elif m_status in (
                'reported',
                'in_progress'
            ):

                impact = 'advisory'

            else:

                # Historical completed maintenance may be either
                # advisory or out_of_service because it is no longer
                # active.
                impact = (
                    'out_of_service'
                    if random.random() < 0.20
                    else 'advisory'
                )

            # ---------------------------------------------------------
            # Notification state
            # ---------------------------------------------------------

            if m_status in (
                'reported',
                'in_progress'
            ):

                if impact == 'out_of_service':

                    notify_status = (
                        'updated_to_out_of_service'
                    )

                else:

                    notify_status = (
                        'updated_to_advisory'
                    )

            else:

                notify_status = (
                    'nothing_to_notify'
                )

            maintenance_data.append(
                (
                    code,
                    reporter,
                    assigned,
                    impact,
                    (
                        f"Maintenance record for "
                        f"{problem} in {code}"
                    ),
                    problem,
                    m_start.strftime(
                        '%Y-%m-%d %H:%M:%S'
                    ),
                    comp_time,
                    m_status,
                    notify_status,
                    (
                        "Resolved successfully."
                        if m_status == 'completed'
                        else None
                    )
                )
            )

        # -------------------------------------------------------------
        # Insert SpaceMaintenance in batches
        # -------------------------------------------------------------

        for i in range(
            0,
            len(maintenance_data),
            BATCH_SIZE
        ):

            batch = maintenance_data[
                i:i + BATCH_SIZE
            ]

            cursor.executemany(
                """
                INSERT INTO SpaceMaintenance
                (
                    campus_space_code,
                    reporter_id,
                    assigned_staff_id,
                    impact_level,
                    problem_description,
                    problem_type,
                    start_time,
                    completion_time,
                    status,
                    notify_status,
                    result_note
                )
                VALUES
                (
                    ?, ?, ?, ?, ?, ?,
                    ?, ?, ?, ?, ?
                )
                """,
                batch
            )

            conn.commit()

            print(
                f"      -> SpaceMaintenance rows "
                f"{i + 1:,} to "
                f"{min(i + BATCH_SIZE, len(maintenance_data)):,}"
            )

        print(
            f"      -> Inserted "
            f"{len(maintenance_data):,} "
            f"SpaceMaintenance records."
        )

        # =============================================================
        # Phase 5B: FacilityMaintenance
        # =============================================================

        print(
            "[5B] Generating ~100000 FacilityMaintenance records..."
        )

        facility_maintenance_data = []

        facility_ids = list(
            facility_space_lookup.keys()
        )

        for _ in range(100000):

            facility_id = random.choice(
                facility_ids
            )

            code = facility_space_lookup[
                facility_id
            ]

            reporter = random.choice(
                staff_ids
            )

            assigned = random.choice(
                staff_ids
            )

            problem = random.choice(
                [
                    "equipment_failure",
                    "projector_failure",
                    "air_conditioner_failure",
                    "microphone_failure",
                    "computer_failure",
                    "network_issue",
                    "other"
                ]
            )

            days_offset = random.randint(
                0,
                1080
            )

            m_start = (
                start_sim_date
                + timedelta(
                    days=days_offset,
                    hours=random.randint(0, 10)
                )
            )

            m_duration = timedelta(
                days=random.randint(1, 4)
            )

            m_end = (
                m_start +
                m_duration
            )

            # ---------------------------------------------------------
            # Maintenance status
            # ---------------------------------------------------------

            status_roll = random.random()

            if status_roll < 0.10:

                m_status = "reported"

                comp_time = None

            elif status_roll < 0.25:

                m_status = "in_progress"

                comp_time = None

            else:

                m_status = "completed"

                comp_time = (
                    m_end.strftime(
                        "%Y-%m-%d %H:%M:%S"
                    )
                )

            # ---------------------------------------------------------
            # CONTROLLED IMPACT
            #
            # Only the selected active maintenance spaces may have
            # currently active out_of_service facility maintenance.
            # ---------------------------------------------------------

            if (
                m_status in (
                    "reported",
                    "in_progress"
                )
                and
                code in active_maintenance_spaces
            ):

                impact = "out_of_service"

            elif m_status in (
                "reported",
                "in_progress"
            ):

                impact = "advisory"

            else:

                impact = (
                    "out_of_service"
                    if random.random() < 0.20
                    else "advisory"
                )

            # ---------------------------------------------------------
            # Notification state
            # ---------------------------------------------------------

            if m_status in (
                "reported",
                "in_progress"
            ):

                if impact == "out_of_service":

                    notify_status = (
                        "updated_to_out_of_service"
                    )

                else:

                    notify_status = (
                        "updated_to_advisory"
                    )

            else:

                notify_status = (
                    "nothing_to_notify"
                )

            facility_maintenance_data.append(
                (
                    facility_id,
                    reporter,
                    assigned,
                    impact,
                    (
                        f"Facility maintenance record "
                        f"for {problem} in {code}"
                    ),
                    m_start.strftime(
                        "%Y-%m-%d %H:%M:%S"
                    ),
                    comp_time,
                    m_status,
                    notify_status,
                    (
                        "Resolved successfully."
                        if m_status == "completed"
                        else None
                    )
                )
            )

        # -------------------------------------------------------------
        # Insert FacilityMaintenance in batches
        # -------------------------------------------------------------

        for i in range(
            0,
            len(facility_maintenance_data),
            BATCH_SIZE
        ):

            batch = facility_maintenance_data[
                i:i + BATCH_SIZE
            ]

            cursor.executemany(
                """
                INSERT INTO FacilityMaintenance
                (
                    campus_facility_id,
                    reporter_id,
                    assigned_staff_id,
                    impact_level,
                    problem_description,
                    start_time,
                    completion_time,
                    status,
                    notify_status,
                    result_note
                )
                VALUES
                (
                    ?, ?, ?, ?, ?,
                    ?, ?, ?, ?, ?
                )
                """,
                batch
            )

            conn.commit()

            print(
                f"      -> FacilityMaintenance rows "
                f"{i + 1:,} to "
                f"{min(i + BATCH_SIZE, len(facility_maintenance_data)):,}"
            )

        print(
            f"      -> Inserted "
            f"{len(facility_maintenance_data):,} "
            f"FacilityMaintenance records."
        )

        # -------------------------------------------------------------
        # Release maintenance generation buffers
        # -------------------------------------------------------------

        del maintenance_data
        del facility_maintenance_data

        # =============================================================
        # Determine available spaces FROM DATABASE
        # =============================================================

        print()
        print(
            "      Checking space availability "
            "according to SQL Server..."
        )

        cursor.execute(
            """
            SELECT
                cs.campus_space_code
            FROM CampusSpace cs
            WHERE dbo.fn_IsSpaceAvailable(
                cs.campus_space_code,
                CAST('2026-08-01 07:00:00' AS DATETIME2),
                CAST('2026-08-01 08:00:00' AS DATETIME2),
                NULL
            ) = 1
            """
        )

        available_space_codes = [
            row[0]
            for row in cursor.fetchall()
        ]

        print(
            f"      -> Currently available spaces "
            f"according to SQL Server: "
            f"{len(available_space_codes):,}"
        )

        unavailable_space_count = (
            len(space_codes)
            - len(available_space_codes)
        )

        print(
            f"      -> Currently unavailable spaces: "
            f"{unavailable_space_count:,}"
        )

        if not available_space_codes:

            raise RuntimeError(
                "No spaces are currently available "
                "according to fn_IsSpaceAvailable(). "
                "Cannot generate SpaceBookings."
            )

        # =============================================================
        # IMPORTANT SAFETY CHECK
        # =============================================================

        if (
            len(available_space_codes)
            < len(space_codes)
            - MAX_ACTIVE_MAINTENANCE_SPACES
        ):

            print(
                "      WARNING: SQL Server reports more "
                "unavailable spaces than expected."
            )

            print(
                "      This may be caused by CampusSpace "
                "current_status or trigger behavior."
            )

        # =================================================================
        # Phase 6: PATCH-BASED CORE GENERATOR
        # =================================================================

        print()
        print(
            "[6/6] Generating "
            f"{TOTAL_BOOKINGS:,} SpaceBookings, "
            "~50k Approvals, and Usage Sessions "
            "in patches..."
        )

        occupied_grid = {
            code: []
            for code in available_space_codes
        }

        current_dt = datetime(
            2023,
            9,
            1,
            7,
            0
        )

        total_days = (
            datetime(
                2026,
                8,
                31
            )
            -
            datetime(
                2023,
                9,
                1
            )
        ).days + 1

        booking_counter = 0

        patch_number = 0

        # =============================================================
        # Patch loop
        # =============================================================

        while booking_counter < TOTAL_BOOKINGS:

            patch_number += 1

            patch_target = min(
                PATCH_SIZE,
                TOTAL_BOOKINGS - booking_counter
            )

            print()
            print("=" * 70)

            print(
                f"PATCH {patch_number}: "
                f"Generating {patch_target:,} bookings"
            )

            print("=" * 70)

            # =========================================================
            # 6A. Generate ONLY this patch in memory
            # =========================================================

            bookings_buffer = []

            booking_metadata = []

            while len(bookings_buffer) < patch_target:

                day_offset = random.randint(
                    0,
                    total_days - 1
                )

                day_date = (
                    current_dt
                    + timedelta(
                        days=day_offset
                    )
                )

                code = random.choice(
                    available_space_codes
                )

                stype, is_instant = (
                    space_type_lookup[code]
                )

                # -----------------------------------------------------
                # Requester
                # -----------------------------------------------------

                if stype == 'auditorium':

                    requester = random.choice(
                        lecturer_ids * 4
                        +
                        staff_ids
                    )

                elif stype == 'classroom':

                    requester = random.choice(
                        lecturer_ids * 3
                        +
                        ta_ids
                    )

                elif stype == 'computer_lab':

                    requester = random.choice(
                        ta_ids * 3
                        +
                        student_ids
                    )

                else:

                    requester = random.choice(
                        student_ids * 2
                        +
                        lecturer_ids
                        +
                        staff_ids
                    )

                # -----------------------------------------------------
                # Requested time
                # -----------------------------------------------------

                start_hour = random.randint(
                    7,
                    19
                )

                start_min = random.choice(
                    [0, 30]
                )

                duration_hours = random.choice(
                    [
                        1.0,
                        1.5,
                        2.0,
                        3.0
                    ]
                )

                req_start = datetime(
                    day_date.year,
                    day_date.month,
                    day_date.day,
                    start_hour,
                    start_min
                )

                req_end = (
                    req_start
                    +
                    timedelta(
                        hours=duration_hours
                    )
                )

                # -----------------------------------------------------
                # Booking information
                # -----------------------------------------------------

                purpose = random.choice(
                    PURPOSE_BY_SPACE[stype]
                )

                participants = random.randint(
                    5,
                    space_capacity_lookup[code]
                )

                submitted_at = (
                    req_start
                    -
                    timedelta(
                        days=random.randint(
                            1,
                            14
                        ),
                        hours=random.randint(
                            1,
                            8
                        )
                    )
                )

                is_booking_conflict = False

                for (
                    b_s,
                    b_e
                ) in occupied_grid[code]:

                    if (
                        req_start < b_e
                        and
                        req_end > b_s
                    ):

                        is_booking_conflict = True

                        break

                if is_booking_conflict:

                    continue

                # -----------------------------------------------------
                # Valid booking
                # -----------------------------------------------------

                booking_counter += 1

                status = (
                    'approved'
                    if is_instant == 1
                    else 'pending'
                )

                occupied_grid[code].append(
                    (
                        req_start,
                        req_end
                    )
                )

                bookings_buffer.append(
                    (
                        requester,
                        code,
                        req_start.strftime(
                            '%Y-%m-%d %H:%M:%S'
                        ),
                        req_end.strftime(
                            '%Y-%m-%d %H:%M:%S'
                        ),
                        purpose,
                        participants,
                        status,
                        is_instant,
                        1,
                        submitted_at.strftime(
                            '%Y-%m-%d %H:%M:%S'
                        )
                    )
                )

                booking_metadata.append(
                    {
                        "is_instant": is_instant,
                        "submitted_at": submitted_at,
                        "requested_start": req_start,
                        "requested_end": req_end
                    }
                )

            print(
                f"      Generated patch: "
                f"{len(bookings_buffer):,} bookings"
            )

            # =========================================================
            # 6B. Create temporary staging tables
            # =========================================================

            cursor.execute(
                """
                IF OBJECT_ID(
                    'tempdb..#SpaceBookingStage'
                ) IS NOT NULL
                    DROP TABLE #SpaceBookingStage;

                CREATE TABLE #SpaceBookingStage
                (
                    generator_row_id INT NOT NULL,

                    requester_id INT NOT NULL,

                    campus_space_code NVARCHAR(20)
                        NOT NULL,

                    requested_start_time DATETIME2
                        NOT NULL,

                    requested_end_time DATETIME2
                        NOT NULL,

                    purpose_type NVARCHAR(40)
                        NOT NULL,

                    expected_participants INT
                        NOT NULL,

                    status NVARCHAR(20)
                        NOT NULL,

                    is_instant_booking BIT
                        NOT NULL,

                    advisory_acknowledged BIT
                        NOT NULL,

                    submitted_at DATETIME2
                        NOT NULL
                );
                """
            )

            cursor.execute(
                """
                IF OBJECT_ID(
                    'tempdb..#InsertedBookingMap'
                ) IS NOT NULL
                    DROP TABLE #InsertedBookingMap;

                CREATE TABLE #InsertedBookingMap
                (
                    generator_row_id INT NOT NULL,

                    space_booking_id INT NOT NULL
                );
                """
            )

            conn.commit()

            # =========================================================
            # 6C. Stage ONLY this patch
            # =========================================================

            stage_buffer = []

            for generator_row_id, booking in enumerate(
                bookings_buffer,
                start=1
            ):

                stage_buffer.append(
                    (
                        generator_row_id,
                        *booking
                    )
                )

            for i in range(
                0,
                len(stage_buffer),
                BATCH_SIZE
            ):

                batch = stage_buffer[
                    i:i + BATCH_SIZE
                ]

                cursor.executemany(
                    """
                    INSERT INTO #SpaceBookingStage
                    (
                        generator_row_id,
                        requester_id,
                        campus_space_code,
                        requested_start_time,
                        requested_end_time,
                        purpose_type,
                        expected_participants,
                        status,
                        is_instant_booking,
                        advisory_acknowledged,
                        submitted_at
                    )
                    VALUES
                    (
                        ?, ?, ?, ?, ?,
                        ?, ?, ?, ?, ?,
                        ?
                    )
                    """,
                    batch
                )

            conn.commit()

            # =========================================================
            # 6D. Insert ONLY this patch into SpaceBooking
            # =========================================================

            print(
                f"      Inserting "
                f"{len(bookings_buffer):,} "
                f"SpaceBookings..."
            )

            cursor.execute(
                """
                MERGE INTO SpaceBooking AS target

                USING #SpaceBookingStage AS src

                    ON 1 = 0

                WHEN NOT MATCHED BY TARGET THEN

                    INSERT
                    (
                        requester_id,
                        campus_space_code,
                        requested_start_time,
                        requested_end_time,
                        purpose_type,
                        expected_participants,
                        status,
                        is_instant_booking,
                        advisory_acknowledged,
                        submitted_at
                    )

                    VALUES
                    (
                        src.requester_id,
                        src.campus_space_code,
                        src.requested_start_time,
                        src.requested_end_time,
                        src.purpose_type,
                        src.expected_participants,
                        src.status,
                        src.is_instant_booking,
                        src.advisory_acknowledged,
                        src.submitted_at
                    )

                OUTPUT
                    src.generator_row_id,
                    INSERTED.space_booking_id

                INTO #InsertedBookingMap
                (
                    generator_row_id,
                    space_booking_id
                );
                """
            )

            conn.commit()

            # =========================================================
            # 6E. Retrieve IDs for THIS PATCH
            # =========================================================

            cursor.execute(
                """
                SELECT
                    generator_row_id,
                    space_booking_id

                FROM #InsertedBookingMap

                ORDER BY generator_row_id;
                """
            )

            booking_id_map = {
                generator_row_id: space_booking_id
                for (
                    generator_row_id,
                    space_booking_id
                ) in cursor.fetchall()
            }

            if (
                len(booking_id_map)
                != len(bookings_buffer)
            ):

                raise RuntimeError(
                    f"Patch {patch_number}: "
                    f"SpaceBooking ID mapping incomplete. "
                    f"Generated "
                    f"{len(bookings_buffer):,}, "
                    f"inserted "
                    f"{len(booking_id_map):,}."
                )

            print(
                f"      -> Committed "
                f"{len(booking_id_map):,} "
                f"SpaceBookings."
            )

            # =========================================================
            # 6F. Generate approvals AND cancellations for THIS PATCH
            # =========================================================
            #
            # Non-instant bookings initially enter as:
            #
            #     pending
            #
            # Then:
            #
            #     20% -> cancelled
            #     80% -> approved through BookingApproval
            #
            # Instant bookings are already approved and do not require
            # BookingApproval.
            # =========================================================

            print(
                "      Generating BookingApprovals "
                "and cancellation decisions..."
            )

            approvals_buffer = []

            cancelled_booking_ids = []

            for generator_row_id, metadata in enumerate(
                booking_metadata,
                start=1
            ):

                actual_booking_id = (
                    booking_id_map[
                        generator_row_id
                    ]
                )

                # ---------------------------------------------------------
                # Instant bookings
                #
                # Already approved during SpaceBooking insertion.
                # No BookingApproval is required.
                # ---------------------------------------------------------

                if metadata["is_instant"] == 1:
                    continue

                # ---------------------------------------------------------
                # Non-instant booking
                #
                # Initially:
                #
                #     pending
                #
                # Randomly decide whether it is cancelled or approved.
                # ---------------------------------------------------------

                if random.random() < CANCELLATION_RATE:

                    cancelled_booking_ids.append(
                        actual_booking_id
                    )

                    continue

                # ---------------------------------------------------------
                # Booking is rejected
                # ---------------------------------------------------------

                # ---------------------------------------------------------
                # Booking is approved
                # ---------------------------------------------------------

                staff_reviewer = random.choice(
                    staff_ids
                )

                if random.random() < 0.85:

                    decision = 'approved'

                    decision_note = "Approved by staff."

                    rejection_reason = None

                else:

                    decision = 'rejected'

                    decision_note = "Booking rejected by staff."

                    rejection_reason = random.choice(
                        [
                            "Space unavailable for the requested time.",
                            "Booking does not meet space usage requirements.",
                            "Requested space is reserved for another activity.",
                            "Booking request conflicts with facility policy.",
                            "Insufficient justification for the requested booking."
                        ]
                    )

                submitted_at = (
                    metadata["submitted_at"]
                )

                req_start = (
                    metadata["requested_start"]
                )

                dec_time = (
                    submitted_at
                    +
                    timedelta(
                        hours=random.randint(
                            1,
                            24
                        )
                    )
                )

                if dec_time > req_start:

                    dec_time = (
                        req_start
                        -
                        timedelta(
                            minutes=30
                        )
                    )

                approvals_buffer.append(
                    (
                        actual_booking_id,
                        staff_reviewer,
                        decision,
                        dec_time.strftime(
                            '%Y-%m-%d %H:%M:%S'
                        ),
                        decision_note,
                        rejection_reason
                    )
                )

            print(
                f"      -> Pending bookings selected for "
                f"cancellation: "
                f"{len(cancelled_booking_ids):,}"
            )

            print(
                f"      -> Pending bookings selected for "
                f"approval: "
                f"{len(approvals_buffer):,}"
            )

            # =========================================================
            # 6F-1. Update pending -> cancelled
            # =========================================================

            if cancelled_booking_ids:

                print(
                    f"      Cancelling "
                    f"{len(cancelled_booking_ids):,} "
                    f"pending bookings..."
                )

                for i in range(
                    0,
                    len(cancelled_booking_ids),
                    BATCH_SIZE
                ):

                    batch = [
                        (booking_id,)
                        for booking_id
                        in cancelled_booking_ids[
                            i:i + BATCH_SIZE
                        ]
                    ]

                    cursor.executemany(
                        """
                        UPDATE SpaceBooking
                        SET status = 'cancelled'
                        WHERE space_booking_id = ?
                        AND status = 'pending'
                        """,
                        batch
                    )

                conn.commit()

                print(
                    f"      -> Cancelled "
                    f"{len(cancelled_booking_ids):,} "
                    f"pending bookings."
                )

            # =========================================================
            # 6G. Insert approvals for THIS PATCH
            # =========================================================

            print(
                f"      Inserting "
                f"{len(approvals_buffer):,} "
                f"BookingApprovals..."
            )

            for i in range(
                0,
                len(approvals_buffer),
                BATCH_SIZE
            ):

                batch = approvals_buffer[
                    i:i + BATCH_SIZE
                ]

                cursor.executemany(
                    """
                    INSERT INTO BookingApproval
                    (
                        space_booking_id,
                        staff_id,
                        decision,
                        decision_time,
                        decision_note,
                        rejection_reason
                    )
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    batch
                )

            conn.commit()

            print(
                f"      -> Committed "
                f"{len(approvals_buffer):,} "
                f"BookingApprovals."
            )

            # =========================================================
            # 6H. Create current patch ID table
            # =========================================================

            cursor.execute(
                """
                IF OBJECT_ID(
                    'tempdb..#CurrentPatchBookings'
                ) IS NOT NULL

                    DROP TABLE #CurrentPatchBookings;

                CREATE TABLE #CurrentPatchBookings
                (
                    space_booking_id INT PRIMARY KEY
                );
                """
            )

            patch_booking_ids = list(
                booking_id_map.values()
            )

            for i in range(
                0,
                len(patch_booking_ids),
                BATCH_SIZE
            ):

                batch = [
                    (booking_id,)
                    for booking_id
                    in patch_booking_ids[
                        i:i + BATCH_SIZE
                    ]
                ]

                cursor.executemany(
                    """
                    INSERT INTO #CurrentPatchBookings
                    (
                        space_booking_id
                    )
                    VALUES (?)
                    """,
                    batch
                )

            conn.commit()

            # =========================================================
            # 6I. approved -> checked_in
            # =========================================================

            print(
                "      Updating approved bookings "
                "to checked_in..."
            )

            cursor.execute(
                """
                UPDATE sb

                SET status = 'checked_in'

                FROM SpaceBooking sb

                INNER JOIN #CurrentPatchBookings p

                    ON p.space_booking_id =
                       sb.space_booking_id

                WHERE sb.status = 'approved'

                AND ABS(CHECKSUM(NEWID())) % 100 < 50;
                """
            )

            conn.commit()

            # =========================================================
            # 6J. checked_in -> completed
            # =========================================================

            print(
                "      Updating checked_in bookings "
                "to completed..."
            )

            cursor.execute(
                """
                UPDATE sb

                SET status = 'completed'

                FROM SpaceBooking sb

                INNER JOIN #CurrentPatchBookings p

                    ON p.space_booking_id =
                       sb.space_booking_id

                WHERE sb.status = 'checked_in'

                AND ABS(CHECKSUM(NEWID())) % 100 < 90;
                """
            )

            conn.commit()

            # =========================================================
            # 6K. Remaining checked_in -> no-show
            # =========================================================

            print(
                "      Updating remaining checked_in "
                "bookings to no-show..."
            )

            cursor.execute(
                """
                UPDATE sb

                SET status = 'no-show'

                FROM SpaceBooking sb

                INNER JOIN #CurrentPatchBookings p

                    ON p.space_booking_id =
                       sb.space_booking_id

                WHERE sb.status = 'checked_in';
                """
            )

            conn.commit()

            # =========================================================
            # 6L. Generate sessions for completed bookings
            # =========================================================

            print(
                "      Generating SpaceUsageSessions..."
            )

            cursor.execute(
                """
                SELECT
                    sb.space_booking_id,
                    sb.requested_start_time,
                    sb.requested_end_time

                FROM SpaceBooking sb

                INNER JOIN #CurrentPatchBookings p

                    ON p.space_booking_id =
                       sb.space_booking_id

                WHERE sb.status = 'completed';
                """
            )

            completed_bookings = (
                cursor.fetchall()
            )

            sessions_data = []

            for (
                booking_id,
                req_start,
                req_end
            ) in completed_bookings:

                checkin_staff = random.choice(
                    staff_ids
                )

                actual_start = (
                    req_start
                    +
                    timedelta(
                        minutes=random.randint(
                            -5,
                            10
                        )
                    )
                )

                actual_end = (
                    req_end
                    +
                    timedelta(
                        minutes=random.randint(
                            -5,
                            15
                        )
                    )
                )

                sessions_data.append(
                    (
                        booking_id,
                        checkin_staff,
                        actual_start.strftime(
                            '%Y-%m-%d %H:%M:%S'
                        ),
                        (
                            "Clean condition. "
                            "Projector and AC functional."
                        ),
                        actual_end.strftime(
                            '%Y-%m-%d %H:%M:%S'
                        ),
                        (
                            "Good condition. "
                            "Returned key to staff."
                        ),
                        (
                            "Session completed "
                            "without incidents."
                        )
                    )
                )

            # =========================================================
            # 6M. Insert sessions for THIS PATCH
            # =========================================================

            print(
                f"      Inserting "
                f"{len(sessions_data):,} "
                f"SpaceUsageSessions..."
            )

            for i in range(
                0,
                len(sessions_data),
                BATCH_SIZE
            ):

                batch = sessions_data[
                    i:i + BATCH_SIZE
                ]

                cursor.executemany(
                    """
                    INSERT INTO SpaceUsageSession
                    (
                        space_booking_id,
                        checked_in_by,
                        actual_start_time,
                        initial_condition,
                        actual_end_time,
                        final_condition,
                        usage_notes
                    )
                    VALUES
                    (
                        ?, ?, ?, ?, ?, ?, ?
                    )
                    """,
                    batch
                )

            conn.commit()

            print(
                f"      -> Committed "
                f"{len(sessions_data):,} "
                f"SpaceUsageSessions."
            )

            # =========================================================
            # Patch completed
            # =========================================================

            print()
            print(
                f"PATCH {patch_number} COMPLETED "
                f"("
                f"{booking_counter:,}/"
                f"{TOTAL_BOOKINGS:,}"
                f" total bookings)"
            )

        # =================================================================
        # Phase 7: Advisory Acknowledgement / Booking-Related Maintenance
        # =================================================================
        # For approved SpaceBookings, turn:
        # 5%  -> reported + advisory
        # 15% -> reported + out_of_service
        # =================================================================

        print()
        print(
            "[7/7] Generating booking-related maintenance "
            "for approved spaces..."
        )

        # ================================================================
        # 7A. Determine spaces with approved bookings
        # ================================================================

        cursor.execute(
            """
            SELECT
                sb.campus_space_code,
                MAX(ba.decision_time) AS latest_approval_time
            FROM SpaceBooking sb
            INNER JOIN BookingApproval ba
                ON ba.space_booking_id =
                sb.space_booking_id
            WHERE ba.decision = 'approved'
            GROUP BY
                sb.campus_space_code
            """
        )

        approved_space_rows = cursor.fetchall()

        approved_space_latest_approval = {
            row[0]: row[1]
            for row in approved_space_rows
        }

        approved_space_codes = list(
            approved_space_latest_approval.keys()
        )

        approved_space_count = len(
            approved_space_codes
        )

        print(
            f"      -> Spaces with approved bookings: "
            f"{approved_space_count:,}"
        )

        if approved_space_count == 0:

            print(
                "      -> No approved spaces found. "
                "Skipping Phase 7."
            )

        else:

            # ============================================================
            # 7B. Calculate maintenance counts
            # ============================================================

            advisory_count = max(
                1,
                round(
                    approved_space_count * 0.05
                )
            )

            out_of_service_count = max(
                1,
                round(
                    approved_space_count * 0.15
                )
            )

            # Cannot select more spaces than actually exist.
            total_required = (
                advisory_count
                +
                out_of_service_count
            )

            if total_required > approved_space_count:

                out_of_service_count = max(
                    0,
                    approved_space_count
                    - advisory_count
                )

            print(
                f"      -> Advisory spaces (5%): "
                f"{advisory_count:,}"
            )

            print(
                f"      -> Out-of-service spaces (15%): "
                f"{out_of_service_count:,}"
            )

            # ============================================================
            # 7C. Randomly divide approved spaces
            # ============================================================

            shuffled_spaces = (
                approved_space_codes.copy()
            )

            random.shuffle(
                shuffled_spaces
            )

            advisory_spaces = (
                shuffled_spaces[
                    :advisory_count
                ]
            )

            out_of_service_start = (
                advisory_count
            )

            out_of_service_spaces = (
                shuffled_spaces[
                    out_of_service_start:
                    out_of_service_start
                    + out_of_service_count
                ]
            )

            print(
                "      -> Selected advisory spaces:"
            )

            print(
                "         "
                +
                ", ".join(
                    sorted(
                        advisory_spaces
                    )
                )
            )

            print(
                "      -> Selected out-of-service spaces:"
            )

            print(
                "         "
                +
                ", ".join(
                    sorted(
                        out_of_service_spaces
                    )
                )
            )

            # ============================================================
            # 7D. Generate SpaceMaintenance / FacilityMaintenance
            # ============================================================

            phase7_space_maintenance = []

            phase7_facility_maintenance = []

            # ------------------------------------------------------------
            # Helper data
            # ------------------------------------------------------------

            facility_by_space = {}

            cursor.execute(
                """
                SELECT
                    campus_facility_id,
                    campus_space_code,
                    facility_type
                FROM CampusFacility
                """
            )

            for (
                facility_id,
                space_code,
                facility_type
            ) in cursor.fetchall():

                facility_by_space.setdefault(
                    space_code,
                    []
                ).append(
                    (
                        facility_id,
                        facility_type
                    )
                )

            facility_problem_map = {
                "Projector":
                    "projector_failure",

                "Whiteboard":
                    "whiteboard_damage",

                "Microphone System":
                    "microphone_failure",

                "Desktop Computers":
                    "computer_failure",

                "Air Conditioner":
                    "air_conditioner_failure",

                "Sound System":
                    "sound_system_failure"
            }

            # ------------------------------------------------------------
            # Generate advisory maintenance
            # ------------------------------------------------------------

            for code in advisory_spaces:

                reporter = random.choice(
                    staff_ids
                )

                assigned = random.choice(
                    staff_ids
                )

                # Randomly decide whether this
                # maintenance belongs to the
                # space or one of its facilities.
                #
                # 50% SpaceMaintenance
                # 50% FacilityMaintenance
                # when a facility exists.
                facilities = (
                    facility_by_space.get(
                        code,
                        []
                    )
                )

                use_facility = (
                    bool(facilities)
                    and
                    random.random() < 0.50
                )

                approval_time = (
                    approved_space_latest_approval[code]
                )

                approval_date = approval_time.date()

                maintenance_date = (
                    approval_date
                    + timedelta(
                        days=random.randint(1, 7)
                    )
                )

                maintenance_start = datetime(
                    maintenance_date.year,
                    maintenance_date.month,
                    maintenance_date.day,
                    random.randint(7, 18),
                    random.choice([0, 30])
                )

                if use_facility:

                    facility_id, facility_type = random.choice(facilities)

                    problem = facility_problem_map.get(
                        facility_type,
                        "facility_failure"
                    )

                    problem_description = (
                        f"{facility_type} failure identified "
                        f"after approved booking in {code}."
                    )
                    
                    phase7_facility_maintenance.append(
                        (
                            facility_id,
                            reporter,
                            assigned,
                            "advisory",
                            problem_description,
                            maintenance_start.strftime(
                                "%Y-%m-%d %H:%M:%S"
                            ),
                            None,
                            "reported",
                            "updated_to_advisory",
                            None
                        )
                    )

                else:

                    problem = random.choice(
                        [
                            "ac_failure",
                            "damaged_furniture",
                            "cleaning",
                            "network",
                            "other"
                        ]
                    )

                    phase7_space_maintenance.append(
                        (
                            code,
                            reporter,
                            assigned,
                            "advisory",
                            (
                                f"Advisory maintenance "
                                f"identified after approved "
                                f"booking in {code}."
                            ),
                            problem,
                            maintenance_start.strftime(
                                "%Y-%m-%d %H:%M:%S"
                            ),
                            None,
                            "reported",
                            "updated_to_advisory",
                            None
                        )
                    )

            # ------------------------------------------------------------
            # Generate out-of-service maintenance
            # ------------------------------------------------------------

            for code in out_of_service_spaces:

                reporter = random.choice(
                    staff_ids
                )

                assigned = random.choice(
                    staff_ids
                )

                facilities = (
                    facility_by_space.get(
                        code,
                        []
                    )
                )

                use_facility = (
                    bool(facilities)
                    and
                    random.random() < 0.50
                )

                approval_time = (
                    approved_space_latest_approval[code]
                )

                approval_date = approval_time.date()

                maintenance_date = (
                    approval_date
                    + timedelta(
                        days=random.randint(1, 7)
                    )
                )

                maintenance_start = datetime(
                    maintenance_date.year,
                    maintenance_date.month,
                    maintenance_date.day,
                    random.randint(7, 18),
                    random.choice([0, 30])
                )

                if use_facility:

                    facility_id, facility_type = random.choice(
                        facilities
                    )

                    problem = facility_problem_map.get(
                        facility_type,
                        "facility_failure"
                    )

                    problem_description = (
                        f"{facility_type} failure identified "
                        f"after approved booking in {code}."
                    )

                    phase7_facility_maintenance.append(
                        (
                            facility_id,
                            reporter,
                            assigned,
                            "out_of_service",
                            problem_description,
                            maintenance_start.strftime(
                                "%Y-%m-%d %H:%M:%S"
                            ),
                            None,
                            "reported",
                            "updated_to_out_of_service",
                            None
                        )
                    )

                else:

                    problem = random.choice(
                        [
                            "ac_failure",
                            "damaged_furniture",
                            "cleaning",
                            "network",
                            "other"
                        ]
                    )

                    phase7_space_maintenance.append(
                        (
                            code,
                            reporter,
                            assigned,
                            "out_of_service",
                            (
                                f"Out-of-service maintenance "
                                f"identified after approved "
                                f"booking in {code}."
                            ),
                            problem,
                            maintenance_start.strftime(
                                "%Y-%m-%d %H:%M:%S"
                            ),
                            None,
                            "reported",
                            "updated_to_out_of_service",
                            None
                        )
                    )

            # ============================================================
            # 7E. Insert SpaceMaintenance
            # ============================================================

            print(
                f"      Inserting "
                f"{len(phase7_space_maintenance):,} "
                f"Phase 7 SpaceMaintenance records..."
            )

            for i in range(
                0,
                len(phase7_space_maintenance),
                BATCH_SIZE
            ):

                batch = phase7_space_maintenance[
                    i:i + BATCH_SIZE
                ]

                cursor.executemany(
                    """
                    INSERT INTO SpaceMaintenance
                    (
                        campus_space_code,
                        reporter_id,
                        assigned_staff_id,
                        impact_level,
                        problem_description,
                        problem_type,
                        start_time,
                        completion_time,
                        status,
                        notify_status,
                        result_note
                    )
                    VALUES
                    (
                        ?, ?, ?, ?, ?, ?,
                        ?, ?, ?, ?, ?
                    )
                    """,
                    batch
                )

            conn.commit()

            # ============================================================
            # 7F. Insert FacilityMaintenance
            # ============================================================

            print(
                f"      Inserting "
                f"{len(phase7_facility_maintenance):,} "
                f"Phase 7 FacilityMaintenance records..."
            )

            for i in range(
                0,
                len(phase7_facility_maintenance),
                BATCH_SIZE
            ):

                batch = phase7_facility_maintenance[
                    i:i + BATCH_SIZE
                ]

                cursor.executemany(
                    """
                    INSERT INTO FacilityMaintenance
                    (
                        campus_facility_id,
                        reporter_id,
                        assigned_staff_id,
                        impact_level,
                        problem_description,
                        start_time,
                        completion_time,
                        status,
                        notify_status,
                        result_note
                    )
                    VALUES
                    (
                        ?, ?, ?, ?, ?,
                        ?, ?, ?, ?, ?
                    )
                    """,
                    batch
                )

            conn.commit()

            # ============================================================
            # 7G. Statistics
            # ============================================================

            print(
                f"      -> Phase 7 SpaceMaintenance: "
                f"{len(phase7_space_maintenance):,}"
            )

            print(
                f"      -> Phase 7 FacilityMaintenance: "
                f"{len(phase7_facility_maintenance):,}"
            )

            print(
                f"      -> Phase 7 total maintenance: "
                f"{len(phase7_space_maintenance) + len(phase7_facility_maintenance):,}"
            )

            # ------------------------------------------------------------
            # Release Phase 7 buffers
            # ------------------------------------------------------------

            del approved_space_codes
            del shuffled_spaces
            del advisory_spaces
            del out_of_service_spaces
            del facility_by_space
            del phase7_space_maintenance
            del phase7_facility_maintenance

            # ---------------------------------------------------------
            # Release Python memory belonging to this patch.
            #
            # occupied_grid is intentionally NOT deleted because it
            # must persist across patches to prevent generated booking
            # conflicts between different patches.
            # ---------------------------------------------------------

            del bookings_buffer
            del booking_metadata
            del stage_buffer
            del approvals_buffer
            del sessions_data
            del booking_id_map
            del completed_bookings

        # =================================================================
        # Final statistics
        # =================================================================

        print()
        print(
            "================================================================"
        )

        print(
            "  FINAL DATABASE COUNTS"
        )

        print(
            "================================================================"
        )

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM SpaceBooking
            """
        )

        total_db_bookings = cursor.fetchone()[0]

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM BookingApproval
            """
        )

        total_db_approvals = cursor.fetchone()[0]

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM SpaceUsageSession
            """
        )

        total_db_sessions = cursor.fetchone()[0]

        print(
            f"  SpaceBookings       : "
            f"{total_db_bookings:,}"
        )

        print(
            f"  BookingApprovals    : "
            f"{total_db_approvals:,}"
        )

        print(
            f"  UsageSessions       : "
            f"{total_db_sessions:,}"
        )

        print(
            f"  Available spaces    : "
            f"{len(available_space_codes):,}"
        )

        print(
            f"  Unavailable spaces  : "
            f"{len(space_codes) - len(available_space_codes):,}"
        )

        print(
            "================================================================"
        )

        elapsed = (
            datetime.now() - start_time
        ).total_seconds()

        print(
            "  BULK GENERATION COMPLETED "
            f"SUCCESSFULLY IN {elapsed:.2f} SECONDS!"
        )

        print(
            "================================================================"
        )

    except Exception:

        conn.rollback()

        print()
        print(
            "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        )

        print(
            "  ERROR OCCURRED — TRANSACTION ROLLED BACK"
        )

        print(
            "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        )

        raise

    finally:

        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()
