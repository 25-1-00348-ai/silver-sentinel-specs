# Business Logic

## Project Details
- Company/Team Name: Dasaka
- Project Code Name: Silver Sentinel
- Project Short Code: SS
- Short Description: A crowdsourced transit app sharing live bus    schedules, fares, and occupancy.
- Long Description: Dasaka is a crowdsourced mobile transit app that helps commuters know when a bus is coming, how much the fare is, and how full the bus is before they board. In many areas, bus schedules are unpublished, fares are inconsistent, and riders can only guess when the next bus will arrive or whether there will be a seat. Dasaka solves this by turning the riders themselves into the data source.

Contributors report bus schedules, fares, and occupancy levels (for example, seats available, standing room only, or full) from the road. The app combines these reports to show commuters live, up-to-date information per route and stop. Moderators review reports and remove inaccurate or abusive entries to keep the information reliable, and administrators manage routes, settings, and periodic analytics.

Commuters can browse routes, schedules, and fares without logging in, while signing in with Google lets them contribute reports and keep their preferences. The MVP focuses on a small set of features: route and stop listings, live schedule updates, fare information, occupancy reporting, and report moderation. The app collects only the minimum data needed, protects location data, avoids per-user trails, and follows the Data Privacy Act.

By making transit information free, current, and community-driven, Dasaka helps commuters save time, plan trips with confidence, and avoid overcrowded buses, without requiring bus operators to install any special equipment.
  

## User Levels
> Note: Modify/rename the list of users based on the actual users that you expect to use the system.

| User Level | Description |
| ----------------------- | ----------- |
| A. System Administrator | Maintains/overrides system/server configurations and performs regular backups. |
| B. Administrator | Manages the general settings of the system, manages bus routes, stops, and fare data, and generates periodic system analytics and reports. |
| C. Moderator | Reviews crowdsourced reports on schedules, fares, and occupancy, and approves, edits, or removes inaccurate or abusive entries. Can suspend contributors who repeatedly submit false reports. |
| D. Contributor | Logged-in commuters who view live transit information and submit reports on bus arrivals, fares, and occupancy levels. Can save favorite routes and stops. |
| E. Guest | Users who do not log in, but view limited contents on the app/web, such as routes, stops, schedules, and fares. |


## System Requirements
1. The app shall allow the users to authenticate using Google Sign-In integration.
2. The app shall allow the users to browse bus routes and stops, and view schedules and fares, without logging in.
3. The app shall allow the users to view live bus arrival times and occupancy levels per route and stop.
4. The app shall allow the users to submit reports on bus arrivals, fares, and occupancy levels.
5. The app shall allow the users to save favorite routes and stops for quick access.
6. The app shall allow the users to review, approve, edit, or remove crowdsourced reports and suspend users who submit false reports.
7. The app shall allow the users to manage routes, stops, and fare data, and generate periodic analytics and reports.

## Required Solution Layers
1. Security and privacy by design. Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, and consent for any data resale.
2. Crowdsourced data quality. Report validation, moderator review, duplicate and spam detection, and confidence scoring based on how many riders report the same information.
3. Real-time data delivery. Live updates of bus arrivals and occupancy, with timestamps on every report and a fallback to the last known schedule when no recent reports exist.
4. Role-based access control. Access to features and data is limited by user level (A to E), and Guests see read-only content.
5. Low-bandwidth and mobile-first design. Lightweight screens and data usage so the app works on slow or unstable mobile networks and low-end Android phones.

## MVP Features and Access
> See the User Levels table for reference.

| Feature | Access |
| --------------------- | ----------- |
| 1. Browse routes, stops, schedules, and fares | A,B,C,D,E |
| 2. Google Sign-In and saved favorite routes/stops | A,B,C,D |
| 3. View live bus arrivals and occupancy | A,B,C,D |
| 4. Submit reports on arrivals, fares, and occupancy | A,B,C,D |
| 5. Review and moderate crowdsourced reports | A,B,C |
| 6. Manage routes, stops, fares, and generate analytics | A,B |
| 7. System configuration and backups | A |

## Notes
- Dasaka is a mobile-first app (Android client), with a web client for viewing routes and schedules. The Python API and Supabase database are shared by both clients.
- Live arrivals and occupancy (Feature 3) are for logged-in users only. Guests see static routes, schedules, and fares.
- All data comes from riders. The app does not rely on bus operator systems, GPS hardware, or official feeds in the MVP.
- Every report is timestamped. Reports older than a set time are shown as stale, and the app falls back to the last known schedule.
- Out of scope for the MVP: in-app ticketing and payments, trip planning across multiple routes, push notifications, chat or social features, and bus operator accounts.