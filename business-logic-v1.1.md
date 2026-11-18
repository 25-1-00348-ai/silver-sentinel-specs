# Business Logic

## Project Details
- Company/Team Name: Dasaka
- Project Code Name: Silver Sentinel
- Project Short Code: SS
- Short Description: A crowdsourced transit app sharing live bus schedules, fares, and occupancy.
- Long Description: Dasaka is a crowdsourced mobile transit app that helps commuters know when a bus is coming, how much the fare is, and how full the bus is before they board. In many areas, bus schedules are unpublished, fares are inconsistent, and riders can only guess when the next bus will arrive or whether there will be a seat. Dasaka solves this by turning the riders themselves into the data source.

Contributors report bus schedules, fares, and occupancy levels (for example, seats available, standing room only, or full) from the road. The app combines these reports to show commuters live, up-to-date information per route and stop. Moderators review reports and remove inaccurate or abusive entries to keep the information reliable, and administrators manage routes, settings, and periodic analytics.

Commuters can browse routes, schedules, fares, and live arrivals and occupancy without logging in, while signing in with Google lets them contribute reports and keep their preferences. The MVP focuses on a small set of features: route and stop listings, live schedule updates, fare information, occupancy reporting, report confirmation, and report moderation. The app collects only the minimum data needed, protects location data, avoids per-user trails, and follows the Data Privacy Act.

By making transit information free, current, and community-driven, Dasaka helps commuters save time, plan trips with confidence, and avoid overcrowded buses, without requiring bus operators to install any special equipment.

- Positioning: For daily bus commuters in areas without published transit data, Dasaka is the free, low-data app that tells you when the next bus is likely to come, what it costs, and whether you will get a seat, using reports from fellow riders instead of operator hardware.
- Pilot area: The Ormoc to Baybay corridor, in both directions (Ormoc to Baybay and Baybay to Ormoc). Each direction is treated as its own route with its own ordered stops, schedules, and fares. Expand to other areas only after the pilot targets (see Notes) are met.


## User Levels
> Note: Modify/rename the list of users based on the actual users that you expect to use the system.

| User Level | Description |
| ----------------------- | ----------- |
| A. System Administrator | Maintains/overrides system/server configurations and performs regular backups. |
| B. Administrator | Manages the general settings of the system, manages bus routes, stops, baseline schedules, and fare data, and generates periodic system analytics and reports. |
| C. Moderator | Reviews flagged and low-confidence crowdsourced reports on schedules, fares, and occupancy, and approves, edits, or removes inaccurate or abusive entries. Can suspend and reinstate contributors who repeatedly submit false reports. |
| D. Contributor | Logged-in commuters who view live transit information and submit and confirm reports on bus arrivals, fares, and occupancy levels. Can save favorite routes and stops and delete their own account. |
| E. Guest | Users who do not log in, but view read-only contents on the app/web, such as routes, stops, schedules, fares, and live arrivals and occupancy. Cannot report, confirm, or save. |


## System Requirements
1. The app shall allow the users to authenticate using Google Sign-In integration.
2. The app shall allow the users to browse bus routes and stops, and view schedules and fares, without logging in.
3. The app shall allow the users to view live bus arrival times and occupancy levels per route and stop, with the age, confidence, and status (Unconfirmed or Verified) of each entry.
4. The app shall allow the users to submit reports on bus arrivals, fares, and occupancy levels using fixed buttons, and select the type of bus they are riding.
5. The app shall allow the users to confirm ("Still true"), dispute ("Wrong"), or flag another rider's report.
6. The app shall allow the users to save favorite routes and stops for quick access.
7. The app shall allow the users to review, approve, edit, or remove crowdsourced reports and suspend users who submit false reports.
8. The app shall allow the users to manage routes, stops, and fare data, and generate periodic analytics and reports.
9. The app shall allow the users to delete their own account and data.

## Required Solution Layers
1. Security and privacy by design. Data Privacy Act compliance, location protection, retention limits, no per-user trails, and aggregation thresholds.
   - A consent screen and plain-language privacy notice are shown at first sign-in. Data resale is not part of the MVP.
   - Phone location is read once, only when a report is submitted, to check proximity (no continuous tracking, which also saves battery). Coordinates are not stored or logged.
   - Reports show the bus or stop, never the reporter. They are linked to an internal user id only for abuse control and are never shown to other users.
   - Retention: raw reports are deleted after 90 days and only aggregates are kept. Aggregates are shown only when backed by 5 or more reports. Accounts are deleted within 30 days of request. The audit log is kept for 1 year.
2. Crowdsourced data quality. Report validation, moderator review, duplicate and spam detection, and confidence scoring based on how many riders report the same information.
   - Report types are fixed buttons with no free text. Arrival: arrived now, delayed, or not coming. Occupancy: seats available, standing room only, or full. Fare: origin stop, destination stop, amount, and regular or discounted class.
   - Bus type: every report includes the type of bus the Contributor is riding, chosen from a fixed list (for example, Ordinary or Air-conditioned) set by the Administrator for the pilot area. It is a required single-select field on the report screen, placed right after the route. It is not free text.
   - Only Contributors can report. Limits: one report per route per type per 5 minutes, and 30 reports per day. A report is rejected if the phone is not within about 300 m of the stop or route.
   - Location check: a location reading with accuracy worse than about 50 m is ignored and the Contributor is asked to retry. If GPS is off, denied, or still unusable, the Contributor can pick their stop from the list instead. Because there is no phone location to compare, the 300 m check is skipped for these reports. They are tagged "location not verified", count at weight 1 with no trust bonus, and follow the same rate limits.
   - Time check: the server sets the report timestamp on receipt. Reports describe what is happening now; a report queued offline for more than 5 minutes is discarded (see Layer 3).
   - Reports publish immediately and are moderated after the fact.
   - Confidence is the number of distinct riders who reported or confirmed the same value within the freshness window, weighted by contributor trust. It is shown as Low (1), Medium (2), or High (3 or more).
   - Status labels: Low confidence is shown as "Unconfirmed"; Medium and High are shown as "Verified".
   - Confirm and dispute: "Still true" counts as a confirmation and "Wrong" as a dispute. Flag is separate and is for abusive or spam reports. Disputes do not remove a report automatically; they send it to the moderation queue.
   - One current value: each route and stop keeps one current value per report type. Fares are kept per bus type, so an Ordinary fare and an Air-conditioned fare on the same route are separate values. Arrival and occupancy entries show the bus type as a label. A new report updates it, and it expires at the end of its freshness window.
   - Conflicting reports: show the majority value. If tied, show the most recent and mark confidence Low.
   - Update prompt: when a Contributor opens a route or stop whose arrival or occupancy entry is older than half its freshness window, the app asks "Still true?" with the confirm and dispute buttons. In-app only, no push notifications.
   - A new fare becomes current at Medium confidence or when an Administrator confirms it. An Administrator value always overrides.
   - Contributor trust: new contributors have weight 1, gain +1 (cap 3) after 5 reports are confirmed by others, and drop to 0 when a report is hidden as false. Three hidden reports in 30 days auto-suspends the contributor pending moderator review. Repeat spammers stay suspended.
   - Moderation queue: reports flagged by users, disputed by 2 or more riders, or from low-trust contributors. Moderators keep, edit, or hide reports and suspend or reinstate contributors, with a target of 24 hours for flagged items. All moderator and administrator actions are written to an audit log. Suspended users see the reason and an email contact for appeal.
   - Before launch, Administrators seed the Ormoc-Baybay routes (both directions), ordered stops per direction, bus types, baseline schedules, and known fares (form or CSV import).
3. Real-time data delivery. Live updates of bus arrivals and occupancy, with timestamps on every report and a fallback to the last known schedule when no recent reports exist.
   - Updates are fetched on screen open, on pull-to-refresh, and by polling every 30-60 seconds while the screen is active. No push or websockets in the MVP.
   - Every entry shows its age (for example, "reported 3 min ago").
   - Send status: after tapping send, the report screen shows Sending, Sent, or Not sent. A report is never shown as confirmed unless the server accepted it. A Not sent report can be retried, and one held in the offline queue is shown as Waiting for signal.
   - Freshness windows: occupancy 15 minutes, arrivals 30 minutes, fares 30 days. Older entries are labeled Stale and fall back to the baseline schedule or last known fare, each shown with its age.
   - Offline reporting: if there is no signal, the app holds the report on the device and sends it when signal returns, only if it is still within 5 minutes. Older queued reports are discarded. The proximity check runs when the report is sent.
4. Role-based access control. Access to features and data is limited by user level (A to E), enforced by the API, and Guests see read-only content.
5. Low-bandwidth and mobile-first design. Lightweight screens and data usage so the app works on slow or unstable mobile networks and low-end Android phones.
   - Key screens use about 100 KB or less of API payload and are usable on 3G.
   - Reporting target: a Contributor can submit a report in 15 seconds or less, using fixed buttons and a few taps.
   - Last viewed routes, stops, and schedules are cached on the device and shown with a "last updated" label when offline.
6. Local fit. The UI is in English with a Filipino/Bisaya string table (labels only). Fares show the regular price and the discounted price (student, senior, PWD).

## MVP Features and Access
> See the User Levels table for reference.

| Feature | Access |
| --------------------- | ----------- |
| 1. Browse routes, stops, schedules, and fares, with search by route or stop | A,B,C,D,E |
| 2. View live bus arrivals and occupancy, with confidence, status, and age | A,B,C,D,E |
| 3. Google Sign-In, consent, saved favorite routes/stops, and account deletion | A,B,C,D |
| 4. Submit reports on arrivals, fares, and occupancy (fixed buttons, bus type selection, offline queue) | A,B,C,D |
| 5. Confirm ("Still true"), dispute ("Wrong"), or flag reports | A,B,C,D |
| 6. Review and moderate crowdsourced reports, suspend/reinstate contributors, and audit log | A,B,C |
| 7. Manage routes, stops, bus types, fares, and baseline schedules (form and CSV), and view basic analytics | A,B |
| 8. System configuration, secrets, and backups | A |

Basic analytics are limited to: daily active users, reports per day per route, share of routes with a fresh report in the last 30 minutes, confirmation rate, and hidden-report rate, as a table or CSV export.

## Notes
- Service coverage in the MVP is limited to the Ormoc-Baybay corridor, both directions. Routes, stops, and reports outside this corridor are not supported.
- Dasaka is a mobile-first app (Android client), with a web client for viewing routes, schedules, fares, and live info. Reporting is Android only in the MVP. The Python API and Supabase database are shared by both clients. The API enforces roles and clients never access the database directly.
- Live arrivals and occupancy (Feature 2) are visible to Guests as read-only. Signing in is required only to contribute.
- All data comes from riders and Administrator seeding. The app does not rely on bus operator systems, GPS hardware, or official feeds in the MVP.
- Every report is timestamped. Reports older than their freshness window are shown as stale, and the app falls back to the last known schedule.
- Location is captured per report only (no live tracking while riding). The bus is represented by its route and stop entries, not by a moving marker.
- Pilot success targets: at least 60% of pilot routes (counting each direction) have a fresh report during peak hours; at least 80% of fresh reports are confirmed or never disputed; median screen load under 3 s on 3G; median time to submit a report of 15 s or less; at least 100 weekly active riders and 20 active contributors; flagged reports handled within 24 hours.
- Out of scope for the MVP: in-app ticketing and payments, trip planning across multiple routes, push notifications and alerts, chat or social features, bus operator accounts, live map and GPS tracking, free-text reports and photos, leaderboards, points, badges and rewards, data resale, ads, premium plans and partner discounts, driver and bus ratings, emergency button, anonymous mode, other transport types (jeepney, van, tricycle), pattern analytics such as usual delays, and languages beyond English and Filipino/Bisaya.
