# KarmaHR

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
inherits the previous user's data. Login is a placeholder: entering any Staff
ID/password takes you straight into the app.

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

## Testing

```bash
flutter test
```

236 tests:

- **Unit** — Nepal rules (fiscal year, leave policy, tax + caps, leave
  planner, bonus, overtime), PDFs, state classes.
- **Screen** — individual widget tests.
- **QA smoke test** (`test/qa/all_screens_smoke_test.dart`) — renders
  every screen with the real providers at 320pt (light), 320pt (dark,
  130% text) and 430pt, on a tall viewport so every list row is built.
  Flutter's test font draws characters about twice as wide as San
  Francisco, so this is a stress test for large accessibility text sizes.
- **Feature flows** (`test/qa/feature_flows_test.dart`) — expense
  validation, overtime limit block, safety check-in, pulse, RSVP, leave
  planner, Dashboard attention card, startup reminders, and logout reset.

## Project structure

```
lib/
├── main.dart
├── data/
│   ├── calendar_data.dart
│   ├── current_employee.dart          # employee details + salary, one place
│   ├── employee_directory_data.dart
│   └── notices_data.dart
├── domain/
│   ├── nepal/                         # pure-Dart Nepal HR rules
│   │   ├── fiscal_year.dart
│   │   ├── leave_policy.dart
│   │   ├── payroll_calculator.dart
│   │   └── tax_slabs.dart
│   └── pdf_documents.dart             # payslip + salary certificate PDFs
├── state/
│   ├── app_lock_state.dart
│   ├── attendance_actions.dart        # shared check-in/out + reminders
│   ├── attendance_state.dart
│   ├── feedback_state.dart
│   ├── hr_request_state.dart
│   ├── kudos_state.dart
│   ├── leave_balance_state.dart
│   ├── leave_state.dart
│   ├── notification_state.dart        # in-app inbox + notifyUser()
│   ├── push_notification_state.dart   # device notifications + scheduling
│   └── theme_state.dart
├── theme/
│   └── app_colors.dart
└── screens/
    ├── welcome_screen.dart, login_screen.dart
    ├── app_lock_gate.dart, app_lock_screen.dart
    ├── main_nav_screen.dart           # bottom tab bar hub
    ├── dashboard_screen.dart
    ├── apps_screen.dart               # grid hub + search entry point
    ├── insights_screen.dart           # charts
    ├── notifications_screen.dart      # inbox + NotificationBell
    ├── global_search_screen.dart
    ├── leave_screen.dart, leave_balances_screen.dart
    ├── request_screen.dart, my_requests_screen.dart
    ├── kudos_screen.dart, give_kudos_screen.dart, kudos_preview_screen.dart
    ├── anonymous_feedback_screen.dart
    ├── employee_directory_screen.dart
    ├── payslip_screen.dart
    ├── notices_screen.dart
    ├── holiday_calendar_screen.dart, events_screen.dart
    ├── profile_screen.dart, settings_screen.dart
    └── apps/
        ├── attendance/, tasks/
        └── widgets/                   # shared: skeleton, refreshable list,
                                       # staggered entrance, PDF actions,
                                       # async state view, badges, cards
```

## Roadmap / what's next

Remaining ideas, frontend-only:

1. Optional/floating holidays (province/community-specific), and a fuller
   holiday calendar (multi-day Dashain/Tihar) so bridge suggestions have
   more to work with.
2. Full English ⇄ नेपाली localization (`flutter_localizations`, `intl`) —
   the layouts are already stress-tested for longer text.
3. AI features — receipt/document OCR (on-device), voice-filled forms, and
   an HR assistant chatbot grounded in the app's own data.

Then: **backend integration** — replacing the demo `fetch*` functions,
`simulatedRefresh()`, the calendar-based working-days estimate, and the
hardcoded current employee.

## Getting started

```bash
flutter pub get
flutter run
```

Requires Xcode (or Android Studio) set up locally.
