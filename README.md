# KarmaHR

[![CI](https://github.com/Bishwassigdel/karmahr/actions/workflows/ci.yml/badge.svg)](https://github.com/Bishwassigdel/karmahr/actions/workflows/ci.yml)

A mobile HR Management System (HRMS) app for employees, built with Flutter.

## About

KarmaHR lets employees check attendance, apply for leave, submit HR requests,
recognize coworkers, browse the company directory, and more — all from one
app. Built as a learning project, styled entirely with Cupertino (iOS-native
widgets) in a red/white KarmaHR theme, with full Light/Dark mode support.

There's no backend yet — **frontend-only is the current phase on purpose**;
backend integration comes after the frontend is feature-complete. All data
lives in shared `provider` state (or static demo data): it resets on app
restart, and logging out explicitly wipes every provider's session data too
(attendance, leave/HR requests, kudos, anonymous feedback, notifications) and
re-locks the app, so the next person signing in on the same device never
inherits the previous user's data. Login is a placeholder: any Staff
ID/password works, and a **demo role picker** (Employee / Manager / HR) on
the login screen decides which portal opens.

## Features

- **Welcome & Login** — animated splash screen, Staff ID/password sign-in
  (no real auth yet), Forgot Password/SSO placeholders
- **App Lock** — optional Face ID / Touch ID / device-passcode gate on
  launch and after logout (Settings → Security)
- **Dashboard** — time-of-day greeting, live attendance card, leave/work-hour
  stats, quick actions, tasks preview, today's events, and a notification
  bell with an unread badge
- **Notifications** — in-app inbox (always records events) plus optional real
  device notifications: a check-out reminder scheduled 9 hours after
  check-in, "Remind Me" for calendar events, and confirmations when leave,
  HR requests, or kudos are submitted
- **Insights** — charts: leave used per type this fiscal year (real data),
  weekly attendance trend (demo data), and a kudos leaderboard (real data)
- **Global Search** — one search box across Directory, Notices, and My
  Requests (Apps → search icon)
- **Attendance** — check-in/out, today's status, monthly summary, history
- **Leave** — apply for leave (full day / half day / hours), track status
- **Leave & Balances** — balances computed live for the current **Nepali
  fiscal year (Shrawan–Ashad)** by a real leave-policy engine, with a
  per-type breakdown and "days will lapse at Ashad-end" warnings
- **HR Requests** — time correction, salary advance, ID card reissue,
  address/contact update, general inquiry
- **My Requests** — all Leave + HR requests and their status
- **Tasks** — assigned tasks with status, priority, and progress
- **Kudos Wall** — peer recognition (category + message + points), reactions
  and comments
- **Anonymous Feedback** — never linked to an employee identity
- **Employee Directory** — searchable coworker list with call/email actions
- **Payslips** — computed by a real payroll + tax engine (PF, TDS via
  progressive slabs), exportable as a PDF (share or print)
- **Salary Certificate** — Profile → Documents: a formal PDF letter for bank
  loans, visas, and verification, watermarked as a draft until HR signs it
- **Notices** — categorized company announcements
- **HR Calendar** — Nepali (Bikram Sambat) calendar with holiday, leave,
  attendance, and event markers
- **Events** — upcoming events countdown, Remind Me, and Add to Calendar
- **Profile** — employment details + editable phone number (routed through
  an HR request for approval)
- **Settings** — theme (Light / Dark / System), App Lock, Push Notifications
  (with a test-notification button)

### Added in the latest batch

- **Leave Planner** — pick a trip and see what it really costs in leave
  (Saturdays and public holidays are free), against your Home Leave
  balance, plus "long break" bridge suggestions (e.g. 1 day of leave next
  to a festival = 3–4 days off). Opens the leave form pre-filled.
- **Tax Planner** — CIT and life-insurance sliders show tax saved and
  take-home live, and say when you pass a deduction limit.
- **Expense Claims** — receipt photo, category, and payout via eSewa,
  Khalti or bank; Nepali mobile-number validation for wallet IDs.
- **Who's Out** — coworkers on leave today and this week (Dashboard strip
  + full screen).
- **Shifts & Overtime** — this week's schedule with holidays, overtime
  requests with a live pay estimate; requests over the daily/weekly limit
  are blocked.
- **Document Wallet** — PAN, citizenship, contract, certificates; asks for
  Face ID / passcode every time it opens when App Lock is on.
- **Onboarding checklist**, **Training & badges** (overdue courses are
  announced in the inbox once per login), **Goals / OKRs** on the Nepali
  fiscal quarter next to kudos received, **Pulse & Polls** (anonymous).
- **Safety Check-in** — earthquake "I'm Safe / I Need Help" with team
  tally and one-tap Police 100 / Fire 101 / Ambulance 102; practice drills.
- **Emergency & Insurance** — emergency contacts and a health-insurance
  card, from Profile.
- **Events** — filter (All / Holidays / Company), company events with RSVP
  and timed Add to Calendar, birthdays & work anniversaries, long breaks.
- **Dashboard** — safety alert, real Home Leave balance and hours today,
  quick actions, Who's Out, weekly pulse, "Needs your attention",
  Dashain countdown with estimated festival bonus, today's real events.
- **Apps** grid grouped into sections (Time & Leave, Pay & Money,
  Requests, Growth, People & Culture, Safety & Documents).

**Polish:** shimmer skeleton loaders (Tasks, Attendance), pull-to-refresh
(Tasks, Attendance, Notices, Payslips), staggered list entrances that respect
the OS Reduce Motion setting, a Hero transition from a notice's card into its
detail screen, and picker wheels that only commit on **Done**.

## Architecture notes

### Nepal domain layer (`lib/domain/nepal/`)

Pure Dart (no Flutter imports, fully unit-testable) — Nepal-specific HR rules
as data instead of numbers scattered across screens. This is the seam a
backend will eventually replace.

- **`fiscal_year.dart`** — Nepal's leave/payroll year runs Shrawan 1 →
  Ashad-end (BS). Handles Ashad's variable length (31 or 32 days) without a
  lookup table.
- **`leave_policy.dart`** — one table of each leave type's rule (flat grant
  vs. accrual, carry-forward cap, paid/unpaid, document requirement).
- **`tax_slabs.dart`** + **`payroll_calculator.dart`** — progressive income
  tax (single/married), PF/SSF, CIT/insurance → monthly TDS and net pay,
  with deduction caps applied.
- **`leave_planner.dart`** — leave-day cost of a trip and bridge-day
  detection (Saturday is the only weekly holiday).
- **`festival_bonus.dart`**, **`overtime.dart`** — Dashain bonus estimate;
  overtime pay (1.5×) and daily/weekly limits.

⚠️ **The leave-policy numbers, tax slabs, deduction caps, overtime rules
and Dashain bonus rule are placeholders**, flagged with
`NOTE(hr-review)` / `NOTE(finance-review)` comments. They are modeled on
Labour Act 2074 and IRD's slab structure but **not verified** against the
current Act, IRD notice, or KarmaHR's bylaw. Get sign-off before relying on
them.

`lib/state/leave_balance_state.dart` combines fiscal year + policy +
submitted requests into balances. "Days worked" is **estimated from the
calendar** (no real attendance history yet) — the one function a backend
should replace.

### Portals and roles

KarmaHR is one app with three portals, chosen by the signed-in role
(`UserRole` in `lib/state/auth_state.dart`):

| Role | Portal | Status |
|---|---|---|
| Employee | The employee app: tabs **Home** (check-in, needs-you, "What's happening" feed), **Time Off** (balances, Request button, planner, holiday calendar, history), **Time**, **Requests** (every request type in one list), **More** (My Info, Apps, Settings, Log Out). **My Info** is one tabbed profile: Job · Contact · Pay · Docs · Emergency | Done |
| Manager | The employee app **plus a Team tab** (managers still take leave and check in) | Team tab is a placeholder; approvals come next |
| HR | The HR portal (`lib/screens/hr/`). Phone: tabs Home (titled KarmaHR, with the notification bell), Employees, Leave, Payroll, More (Notices, Reports, Settings, Log Out). Wide screens: a sidebar with all nine sections | All nine sections built on demo data (see "HR portal" below) |
| Executive | The Executive portal (`lib/screens/owner/`). Phone: tabs **Overview**, **Departments**, **People**, **Money**, **More** (Activity, Settings, Log Out). Wide screens: the shared sidebar. Departments are scored on progress; the Executive can drill from company to department to branch to person | Built on a made-up 290-person company (demo data) |

`portalHomeFor(role)` in `lib/screens/portal_home.dart` maps a role to its
first screen. `confirmLogout()` in `lib/screens/logout.dart` is the one
logout for every portal. The role picker on the login screen is **demo
only**: once the backend exists, the role comes from the login response.

### Executive portal

Built for a big company: it shows **answers first** and the detail behind
them, mostly read-only (HR has the tools to act).

| Tab | What the Executive sees |
|---|---|
| Overview | Headcount against plan, progress score, attendance, payroll this month against last, people who left in the last year. Under it **Needs attention** (a department behind, high attrition, a department short of people, weak branch attendance, plus the HR portal's live items: requests waiting over 3 days, expiring documents, payroll not approved), then every department **lowest score first** |
| Departments | A scorecard per department with a branch filter; tap for the score, its four parts, headcount over 12 months, the split by branch, attrition and joiners, and a way to the people |
| People | Everyone, searchable, filtered by department and branch, built as you scroll; each person's tenure, attendance, goals, review, training and leave balance |
| Money | Payroll this month (in lakh and crore), change on last month, average per employee, 12-month trend, split by department and by branch |
| Activity | What is waiting on a decision (longest first) and the audit log |

**Department progress score** = 35% goals on track + 25% reviews completed
+ 20% training completed + 20% attendance (each 0 to 100). 75 and above is on
track, 60 to 74 needs watching, below 60 is behind. The app explains this
on the Departments tab.

**Privacy rules built in.** A group of fewer than 5 people is never broken
down (it would identify someone). Pay is hidden on a person's page until the
Executive asks; asking first confirms, and **every view of someone's pay is written
to the audit log**.

**The demo company.** `lib/data/company_demo.dart` makes about 290 people in
5 branches and 8 departments, with 12 months of history, from a fixed seed
(identical on every run and platform). It exists so the charts have
something to show; the real HR data has 9 people. With a backend, the same
shapes come from the server and the screens do not change. The HR items on
Overview and Activity are the HR portal's real, live data.

### HR portal

Nine sections; the same screens serve a phone (bottom tabs; More holds
Attendance, Reviews, Hiring, Notices and Reports) and a wide window
(sidebar).

| Section | What HR can do |
|---|---|
| Overview | See what needs action (requests to review, documents expiring, payroll not yet approved), headcount, upcoming birthdays and anniversaries, who's out |
| Employees | Search and filter; a **list** or an **org chart**; open a record (Job, Contact, Pay, Docs, Tasks tabs); add, edit, deactivate; **import many from CSV**; make appointment, experience and salary-certificate **PDF letters**; keep each person's **documents** with expiry dates; tick **onboarding and offboarding** checklists |
| Leave & Holidays | **Approvals** inbox for leave, expense, overtime and HR requests; read-only leave **Policy**; company **Holidays** next to the public holidays |
| Payroll | Pick a BS month, run it with the Nepal tax and SSF rules, approve (freezes the figures), mark paid. Export the **register, bank transfer file, TDS report and SSF report** as CSV, and share each person's **payslip as a PDF** |
| Attendance | Who came, was late, was absent or on leave, for any of the last 14 days; Saturday shows as the weekly holiday |
| Reviews | Start a review cycle for everyone and move each person through self review, manager review and completed |
| Hiring | Post jobs, add applicants, move them through the stages, and add a hired applicant as an employee with their details filled in |
| Notices | Write, publish and delete company notices; employees see them at once |
| Reports | Headcount by department and type, request counts, latest payroll, documents expiring soon, CSV exports, and the **audit log** (filter by kind, export) |

**Company data vs your own data.** Employee records, documents, checklists,
the approvals inbox, payroll, reviews, hiring, notices, company holidays and
the audit log belong to the company, not to whoever is signed in, so logout
does **not** reset them (your own leave, expenses and so on still reset).
That is why an employee HR adds shows in the employee Directory, and a
notice HR publishes shows in every employee's Notices, with no backend. The
audit log records every HR change (who, what, when) and is never cleared.

**Known limits (frontend only).** The approvals inbox holds demo requests
from other people; a decision does not change an employee's own request
list yet (that needs the shared backend table). Attendance is generated
from each person's ID and the date, not recorded. Company holidays HR adds
are not yet shown in the employee calendar, and leave policy is read-only.
Review ratings and comments (the employee's and manager's part) are not
built; HR only tracks the steps. PDF letters are unsigned drafts, and the
employer SSF share (20%), tax, SSF and leave numbers are unverified
placeholders (see "Nepal domain layer").

### Translations (English ⇄ नेपाली)

Text lives in `lib/l10n/app_en.arb` (English, the template) and
`lib/l10n/app_ne.arb` (Nepali). Users switch in **Settings → Language**,
and the choice is kept across launches (`LocaleState`).

To add a string:
1. Add the key to **both** `.arb` files.
2. Run `flutter gen-l10n` (or just `flutter run`, which runs it too).
3. Use it: `Text(context.l10n.myKey)`. Import `lib/l10n/l10n.dart`.

Translated so far: login, tab bar, Settings, logout, and the Manager/HR
portal screens. **Every new screen is written with translations from the
start**; the older employee screens are converted gradually, and until
then show English.

### Single sources of truth

- **`lib/data/current_employee.dart`** — the employee's details and salary
  structure. The payslip screen and the salary certificate both read it, so
  a certificate can never state a different salary than the payslips (a test
  enforces this).
- **`lib/state/attendance_actions.dart`** — the one check-in/out action both
  the Dashboard and the Attendance module call.
- **`lib/state/session.dart`** — `resetSession()`: every per-user state
  reset on logout, in one place. Adding a new per-user state means adding
  one line there.
- **`appProviders()`** in `main.dart` — the one provider list, shared by
  the app and the tests.
- **`notifyUser()`** in `notification_state.dart` — "tell the user
  something": always records in the inbox, and also fires a device
  notification only if push is enabled.

### Notes for later

- **PDF fonts:** PDFs use built-in Latin fonts. All exported content is
  Latin-script today; before adding Devanagari text, bundle a Devanagari TTF
  (e.g. Noto Sans Devanagari) — see the note in `lib/domain/pdf_documents.dart`.
- **iOS plugins use Swift Package Manager** (no CocoaPods). When adding a
  plugin, check it ships a `Package.swift`; one that doesn't makes Flutter
  fall back to CocoaPods, which fails on this Xcode project's
  `$(RECOMMENDED_IPHONEOS_DEPLOYMENT_TARGET)` setting.
- **Android:** `minSdk` is 24 (local_auth), and core library desugaring is
  enabled (required by flutter_local_notifications).
- **Timezone:** never call `toNepaliDateTime()`, `NepaliDateTime.now()`
  or `.add()` on a BS date directly. Those nepali_utils calls go wrong
  outside Nepal time (daylight saving makes them land a day off). Use
  `bsFromAd()`, `bsToday()` and `bsAddDays()` from
  `lib/domain/nepal/bs_dates.dart`. CI runs the date tests in New York time
  to catch this.

## Testing

```bash
flutter test
```

782 tests:

- **Unit** — Nepal rules (fiscal year, leave policy, tax + caps, leave
  planner, bonus, overtime), PDFs, state classes.
- **Screen** — individual widget tests.
- **QA smoke test** (`test/qa/all_screens_smoke_test.dart`) — renders
  every screen with the real providers at 320pt (light), 320pt (dark,
  130% text), 430pt, and 320pt in Nepali, on a tall viewport so every
  list row is built.
  Flutter's test font draws characters about twice as wide as San
  Francisco, so this is a stress test for large accessibility text sizes.
- **Feature flows** (`test/qa/feature_flows_test.dart`) — expense
  validation, overtime limit block, safety check-in, pulse, RSVP, leave
  planner, Dashboard attention card, startup reminders, and logout reset.
- **Roles and language** (`test/qa/roles_and_language_test.dart`) — each
  demo role opens the right portal, logout signs out, and switching to
  नेपाली changes the text.

**CI:** `.github/workflows/ci.yml` runs `flutter analyze` and `flutter test`
on GitHub Actions for every push and pull request to `development` or
`main`. It runs with `TZ=Asia/Kathmandu` to match real devices (see the
timezone note above).

## Project structure

```
.github/workflows/ci.yml               # analyze + tests on every push/PR
lib/
├── main.dart                          # appProviders(): one provider list
├── l10n/                              # app_en.arb + app_ne.arb (+ generated)
│   └── l10n.dart                      # context.l10n helper
├── data/                              # demo data (replaced by backend later)
│   ├── calendar_data.dart             # BS calendar markers, holidays
│   ├── current_employee.dart          # employee details + salary, one place
│   ├── attendance_demo.dart           # demo attendance, from ID + date
│   ├── company_demo.dart              # the 290-person demo company (Executive portal)
│   ├── employee_directory_data.dart
│   ├── notices_data.dart
│   └── team_data.dart                 # team leave, celebrations, events
├── domain/
│   ├── employee_validation.dart       # shared rules for the form + CSV import
│   ├── org_chart.dart                 # manager names -> reporting tree
│   ├── owner_insights.dart            # what needs attention, lakh/crore, privacy rule
│   ├── nepal/                         # pure-Dart Nepal HR rules
│   │   ├── bs_dates.dart              # timezone-safe AD <-> BS helpers
│   │   ├── festival_bonus.dart
│   │   ├── fiscal_year.dart
│   │   ├── leave_planner.dart
│   │   ├── leave_policy.dart
│   │   ├── overtime.dart
│   │   ├── payroll_calculator.dart
│   │   └── tax_slabs.dart
│   └── pdf_documents.dart             # payslip + salary certificate PDFs
├── state/                             # Provider ChangeNotifiers
│   ├── session.dart                   # resetSession() on logout
│   ├── auth_state.dart                # signed-in role (UserRole)
│   ├── locale_state.dart              # English / नेपाली
│   ├── app_lock_state.dart, theme_state.dart
│   ├── attendance_state.dart, attendance_actions.dart
│   ├── leave_state.dart, leave_balance_state.dart
│   ├── hr_request_state.dart, expense_state.dart, overtime_state.dart
│   ├── notification_state.dart        # in-app inbox + notifyUser()
│   ├── push_notification_state.dart   # device notifications + scheduling
│   ├── kudos_state.dart, feedback_state.dart, survey_state.dart
│   ├── goals_state.dart, training_state.dart, onboarding_state.dart
│   ├── document_wallet_state.dart, emergency_info_state.dart
│   ├── safety_state.dart, event_rsvp_state.dart
│   └── (company data, never reset on logout) employee_records_state,
│       employee_documents_state, checklist_state, hr_inbox_state,
│       payroll_state, reviews_state, hiring_state, notices_state,
│       company_holidays_state, audit_log_state
├── theme/
│   └── app_colors.dart
└── screens/
    ├── welcome_screen.dart, login_screen.dart   # + demo role picker
    ├── portal_home.dart, logout.dart  # role → portal; shared logout
    ├── manager/team_screen.dart       # Manager portal (Team tab)
    ├── more_screen.dart               # employee More tab (My Info, apps, settings)
    ├── time_off_screen.dart           # Time Off hub
    ├── requests_screen.dart           # Requests hub (leave, expense, overtime, HR)
    ├── profile_screen.dart            # My Info (tabbed)
    ├── owner/                         # Executive portal
    │   ├── owner_portal_screen.dart   # wide: sidebar; phone: OwnerPhoneShell
    │   ├── owner_phone_shell.dart     # phone tabs + More
    │   ├── owner_overview / departments / department / people / person
    │   │   / money / activity _screen.dart
    │   └── owner_widgets.dart         # progress colours, percent bar, trend chart
    ├── hr/                            # HR portal
    │   ├── hr_portal_screen.dart      # wide: sidebar; phone: HrPhoneShell
    │   ├── hr_phone_shell.dart        # phone tab bar + HrSectionPage
    │   ├── hr_more_screen.dart        # HR More tab
    │   ├── hr_section.dart            # the nine sections (enum)
    │   ├── hr_section_view.dart       # each section's body, one place
    │   ├── hr_nav_scope.dart          # lets Home open another section
    │   ├── hr_overview_screen.dart    # needs-your-action, headcount, events
    │   ├── hr_employees_screen.dart   # list, search, filter
    │   ├── hr_employee_detail_screen.dart / hr_employee_form_screen.dart
    │   ├── hr_leave_screen.dart       # Approvals · Policy · Holidays tabs
    │   ├── hr_approvals_view.dart / hr_policy_view.dart / hr_holidays_view.dart
    │   ├── hr_payroll_screen.dart     # run, approve, mark paid, CSV
    │   ├── hr_notices_screen.dart / hr_notice_form_screen.dart
    │   ├── hr_reports_screen.dart     # headcount, requests, payroll, audit
    │   ├── hr_bar_row.dart            # shared bar-chart row
    │   ├── hr_document_sheet.dart     # add a document (+ type labels)
    │   ├── hr_attendance_screen.dart  # company-wide daily attendance
    │   ├── hr_reviews_screen.dart / hr_review_cycle_screen.dart
    │   └── hr_hiring_screen.dart / hr_job_screen.dart
    ├── app_lock_gate.dart, app_lock_screen.dart
    ├── main_nav_screen.dart           # employee bottom tab bar
    ├── dashboard_screen.dart, apps_screen.dart (opened from More), insights_screen.dart
    ├── notifications_screen.dart, global_search_screen.dart
    ├── leave_screen.dart, leave_balances_screen.dart, leave_planner_screen.dart
    ├── request_screen.dart, my_requests_screen.dart
    ├── expense_claims_screen.dart, shifts_overtime_screen.dart
    ├── payslip_screen.dart, tax_planner_screen.dart
    ├── team_availability_screen.dart, employee_directory_screen.dart
    ├── events_screen.dart, holiday_calendar_screen.dart, notices_screen.dart
    ├── kudos_screen.dart, give_kudos_screen.dart, kudos_preview_screen.dart
    ├── anonymous_feedback_screen.dart, pulse_survey_screen.dart
    ├── goals_screen.dart, training_screen.dart, onboarding_screen.dart
    ├── document_wallet_screen.dart, emergency_info_screen.dart
    ├── safety_checkin_screen.dart, settings_screen.dart
    └── apps/
        ├── attendance/, tasks/
        └── widgets/                   # ui_kit (TileInfo, FormRow, pickers,
                                       # dialogs), skeleton, refreshable list,
                                       # PDF actions, badges, cards,
                                       # karma_logo, portal_sidebar (shared)
test/
├── domain/                            # Nepal rules unit tests
├── state/                             # state class tests
├── screens/                           # widget tests
└── qa/                                # all-screens smoke test + feature flows
```

## Roadmap / what's next

Done: the employee portal and all nine HR sections (frontend, demo data).
The Manager role is **postponed**: HR approves everything for now.

1. **Design polish pass** — one card style, one heading style, consistent
   spacing across all screens.
2. Translate the older employee screens to Nepali.
3. Have a Nepali HR professional and a CA verify the placeholder leave,
   tax, SSF, overtime and bonus rules (`NOTE(hr-review)` /
   `NOTE(finance-review)`), then make tax slabs and holidays HR-editable.
4. **Backend** (Supabase recommended): real login with the role from the
   server, the shared tables behind the company data above, file storage,
   push notifications, and server-side payroll.
5. AI features — HR assistant, receipt scanning, smart request filling.
6. Optional/floating holidays and multi-day Dashain/Tihar in the holiday
   calendar.

## Getting started

```bash
git clone https://github.com/Bishwassigdel/karmahr.git
cd karmahr
flutter pub get
flutter run
```

Requires Xcode (or Android Studio) set up locally.

## Git workflow

- **`development`** — day-to-day work. Commit and push here:
  ```bash
  git add .
  git commit -m "Describe your change"
  git push
  ```
- **`main`** — stable code, and the default branch. It's protected by a
  ruleset: no direct pushes, no force pushes, no deletion. Changes arrive
  only through a pull request, and the `analyze-and-test` CI check must pass.

To release `development` to `main`: on GitHub, **Pull requests → New pull
request**, base `main` ← compare `development`, wait for the ✅ check, then
**Merge**. Afterwards, sync locally:

```bash
git checkout main && git pull && git checkout development
```
