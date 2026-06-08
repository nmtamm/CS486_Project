
# Business Requirement Analysis — QuickShip Logistics

> **Example** — for reference only; replace with actual project content.

---

## 1. Business Purpose

**Core problem:** QuickShip Logistics manages freight delivery manually (notebooks, printed rate tables, phone calls, text messages), causing incorrect fee calculations, overlapping driver assignments, no parcel visibility in transit, slow complaint resolution, and difficulty reconciling COD collections.

**Primary objectives:**
- Automate order intake, shipping fee calculation, and shipment tracking.
- Eliminate overlapping driver assignments through rules-based auto-assignment.
- Provide real-time visibility into parcel location within the transit warehouse network.
- Enable structured complaint handling with compensation tracking.
- Automate COD collection reconciliation and disbursement to senders.

**Scope:**
- **In scope:** Order management, shipping rate tables, warehouse network management, driver management & auto-assignment, shipment tracking, delivery attempt management, COD collection & disbursement, complaint management, employee and customer management.
- **Out of scope:** Accounting/general ledger integration, payroll, HR management, vehicle fleet maintenance, route optimization.

## 2. Actors

| ID | Role | Responsibilities | Interactions |
|----|------|-----------------|--------------|
| A-01 | Reception Clerk | Creates orders, enters shipment details, accepts parcels dropped off at warehouse | Creates and modifies orders; views rate tables; records receiving warehouse |
| A-02 | Warehouse Staff | Handles parcels at origin/transit/destination warehouses; records movement | Registers incoming/outgoing parcels; updates tracking entries |
| A-03 | Driver | Picks up parcels (door-to-door), transports between warehouses, delivers to recipients | Views assigned orders; records pickup and delivery results; collects COD payments |
| A-04 | Customer Service Representative | Handles complaints from customers | Creates and updates complaints; views order history; processes compensation |
| A-05 | Accountant | Reconciles COD collections daily; processes COD disbursements to senders | Views COD collection reports; reconciles driver collections; initiates disbursements |
| A-06 | Warehouse Manager | Manages warehouse operations; oversees staff and capacity | Views warehouse status, capacity, and parcel inventory; manages staff assignments |
| A-07 | Customer (Sender) | Sends parcels; tracks shipments; files complaints | Views order status and tracking history; files complaints; receives COD disbursements |
| A-08 | Recipient | Receives parcels; may pay COD amount; signs for delivery | Receives delivery; pays COD (if applicable); signs delivery receipt |

## 3. Business Data Entities & Attributes

| Entity | Core Identity | Key Attributes | Enums (Predefined Options) |
|--------|---------------|----------------|---------------------------|
| Employee | Employee ID | Full Name, Email, Phone Number, Position (FK to EmployeePosition), Assigned Warehouse (FK to Warehouse), Status | Status: active, inactive, on_leave, terminated |
| EmployeePosition | Position Code | Position Name, Description | Position Code: RECEPTION_CLERK, WAREHOUSE_STAFF, DRIVER, CUSTOMER_SERVICE_REP, ACCOUNTANT, WAREHOUSE_MANAGER |
| Customer | Customer ID | Full Name or Company Name, Email, Phone Number, Default Address, Customer Type, Membership Tier (FK to MembershipTier), Created Date | Customer Type: individual, online_shop, business |
| MembershipTier | Tier Name | Discount Rate (%), COD Cycle (daily, weekly), Minimum Orders (12mo), Minimum Shipping Fee (12mo) | Tier Name: standard, silver, gold, diamond |
| Warehouse | Warehouse Code | Warehouse Name, Address, Province/City, Region, Warehouse Type, Maximum Capacity (parcels), Current Parcel Count, Manager (FK to Employee), Status | Region: North, Central, South. Type: origin, transit, destination. Status: active, temporarily_closed, under_maintenance |
| Order | Order ID (Tracking Number) | Sender Customer (FK), Recipient Name, Recipient Phone, Recipient Address, Recipient Province/City, Goods Type, Actual Weight (kg), Length (cm), Width (cm), Height (cm), Number of Packages, Declared Goods Value, Pickup Method, Delivery Method, COD Required (boolean), COD Amount, Special Notes, Receiving Warehouse (FK), Status, Created Date, Last Updated | Goods Type: documents, electronics, fragile_items, food, bulky_items, general_goods. Pickup Method: drop_off_at_warehouse, door_to_door_pickup. Delivery Method: door_to_door_delivery, warehouse_pickup. Status: awaiting_pickup, picked_up, in_transit, arrived_at_destination_warehouse, out_for_delivery, delivered_successfully, delivery_failed, returning_to_sender, returned_to_sender, cancelled |
| ShippingRate | Rate ID | Origin Region, Destination Region, Goods Type, Weight Bracket Min (kg), Weight Bracket Max (kg), Base Fee | Region: North, Central, South. Goods Type: documents, electronics, fragile_items, food, bulky_items, general_goods |
| Surcharge | Surcharge ID | Surcharge Type, Amount, Description, Is Active | Type: fragile_items_surcharge, bulky_items_surcharge, door_to_door_pickup_surcharge, after_hours_delivery_surcharge, cargo_insurance_surcharge |
| OrderSurcharge | (Order ID + Surcharge ID) | Applied Amount | — |
| Driver | Driver ID (FK to Employee) | Assigned Warehouse (FK), Service Area (Province/City), Vehicle Type, License Plate Number, Driver Status, Max Orders Per Day | Vehicle Type: motorcycle, small_truck, large_truck. Driver Status: available, picking_up, delivering, on_leave |
| DriverAssignment | Assignment ID | Order (FK), Driver (FK), Assignment Type, Assigned Date/Time | Assignment Type: pickup, delivery |
| TrackingEntry | Tracking ID | Order (FK), Origin Warehouse (FK), Destination Warehouse (FK), Transporting Driver (FK), Departure Time, Arrival Time, Leg Status, Notes | Leg Status: in_transit, arrived, delayed, incident |
| DeliveryAttempt | Attempt ID | Order (FK), Driver (FK), Attempt Number (1–3), Attempt Date, Result, Signed By (if successful), Failure Reason (if failed), Notes | Result: successful, failed. Failure Reason: unreachable_by_phone, recipient_absent, wrong_address, recipient_refused |
| CODCollection | Collection ID | Order (FK), Driver (FK), Amount Collected, Collection Date, Reconciliation Status | Reconciliation Status: pending, reconciled, disputed |
| CODDisbursement | Disbursement ID | Customer (FK), Total COD Amount, COD Service Fee, Actual Amount Transferred, Transfer Method, Transfer Date, Status | Transfer Method: bank_transfer, e_wallet, cash. Status: pending, completed, failed |
| CODDisbursementOrder | (Disbursement ID + Order ID) | — | — |
| Complaint | Complaint ID | Order (FK), Customer (FK), Complaint Type, Detailed Description, Creation Date, Assigned Handler (FK to Employee), Status, Resolution Result, Compensation Amount | Type: damaged_goods, lost_goods, wrong_delivery, late_delivery, driver_conduct, incorrect_shipping_fee. Status: new, in_progress, awaiting_evidence, resolved, compensated, rejected |
| ComplaintImage | Image ID | Complaint (FK), Image URL/Path, Upload Date | — |

## 4. Business Rules

| ID | Rule |
|----|------|
| BR-01 | Employee positions are limited to: reception_clerk, warehouse_staff, driver, customer_service_rep, accountant, warehouse_manager. |
| BR-02 | Employee statuses: active, inactive, on_leave, terminated. |
| BR-03 | Each employee is assigned to exactly one warehouse (FK to Warehouse). |
| BR-04 | Customer types: individual, online_shop, business. |
| BR-05 | Membership tiers: standard, silver, gold, diamond — in ascending order of benefits. |
| BR-06 | Membership tier is determined by the system via periodic batch recalculation based on total number of orders and total accumulated shipping fees within the most recent 12 months. Thresholds are defined per tier in MembershipTier. |
| BR-07 | Customers with a higher membership tier receive a greater discount rate on total shipping fees. The discount percentage is defined in MembershipTier. |
| BR-08 | Warehouse regions: North, Central, South. |
| BR-09 | Warehouse types: origin, transit, destination. |
| BR-10 | Warehouse statuses: active, temporarily_closed, under_maintenance. |
| BR-11 | A warehouse manager (FK to Employee) must have the position of warehouse_manager. |
| BR-12 | Goods types for orders: documents, electronics, fragile_items, food, bulky_items, general_goods. |
| BR-13 | Pickup methods: drop_off_at_warehouse, door_to_door_pickup. |
| BR-14 | Delivery methods: door_to_door_delivery, warehouse_pickup. |
| BR-15 | Order status transitions allowed: awaiting_pickup → picked_up | cancelled; picked_up → in_transit; in_transit → arrived_at_destination_warehouse; arrived_at_destination_warehouse → out_for_delivery; out_for_delivery → delivered_successfully | delivery_failed; delivery_failed → out_for_delivery (reschedule, max 3 attempts) | returning_to_sender (after 3rd failure); returning_to_sender → returned_to_sender. Cancellation allowed only from awaiting_pickup status. |
| BR-16 | Shipping fee is calculated based on the rate table defined by origin region, destination region, goods type, and weight bracket. |
| BR-17 | Weight brackets for the rate table: 0–0.5 kg, 0.5–1 kg, 1–3 kg, 3–5 kg, 5–10 kg, over 10 kg. |
| BR-18 | If volumetric weight (Length × Width × Height ÷ 5000) exceeds actual weight, the system uses volumetric weight for fee calculation. |
| BR-19 | Surcharge types that may apply: fragile_items_surcharge, bulky_items_surcharge, door_to_door_pickup_surcharge, after_hours_delivery_surcharge, cargo_insurance_surcharge. Surcharges are stored in the Surcharge table with configurable amounts. |
| BR-20 | The total shipping fee = (base fee from rate table + sum of applicable surcharges) × (1 − membership discount rate). |
| BR-21 | Driver vehicle types: motorcycle, small_truck, large_truck. |
| BR-22 | Driver statuses: available, picking_up, delivering, on_leave. |
| BR-23 | The system auto-assigns a driver for door-to-door pickup and for last-mile delivery based on service area match, availability, and max orders per day. |
| BR-24 | A driver may only be assigned if their service area matches the pickup/delivery address province/city. |
| BR-25 | A driver with status on_leave or who has reached the maximum orders per day cannot accept additional assignments. |
| BR-26 | Tracking leg statuses: in_transit, arrived, delayed, incident. |
| BR-27 | Each tracking entry records a parcel movement between two warehouses (or from warehouse to driver for delivery). |
| BR-28 | Maximum 3 delivery attempts per order. |
| BR-29 | After 3 failed delivery attempts, the order status transitions to returning_to_sender. |
| BR-30 | Delivery failure reasons: unreachable_by_phone, recipient_absent, wrong_address, recipient_refused. |
| BR-31 | For COD orders, the driver collects payment and the system records the collected amount upon successful delivery. |
| BR-32 | COD reconciliation is performed daily by the accountant, comparing driver-collected amounts against amounts drivers submit back. |
| BR-33 | COD disbursement to sender customers occurs on a cycle determined by the customer's membership tier: daily for diamond/gold, weekly for silver/standard. |
| BR-34 | COD disbursement statuses: pending, completed, failed. |
| BR-35 | Complaint types: damaged_goods, lost_goods, wrong_delivery, late_delivery, driver_conduct, incorrect_shipping_fee. |
| BR-36 | Complaint statuses: new, in_progress, awaiting_evidence, resolved, compensated, rejected. |
| BR-37 | The compensation amount on a complaint must not exceed the declared goods value on the related order. |
| BR-38 | A complaint must reference exactly one order and be filed by the sender customer. |
| BR-39 | The system must maintain historical records of all orders, tracking entries, delivery attempts, COD collections, COD disbursements, and complaints indefinitely for reporting purposes. |
