# KarmaHR

A mobile HR Management System (HRMS) app for employees, built with Flutter.

## About

KarmaHR lets employees check attendance, apply for leave, submit HR requests,
recognize coworkers, browse the company directory, and more — all from one
app. Built as a learning project, styled entirely with Cupertino (iOS-native
widgets) in a red/white KarmaHR theme, with full Light/Dark mode support.

There's no backend yet — all data lives in shared `provider` state (or static
demo data) and resets when the app restarts. Login is a placeholder: entering
any Staff ID/password takes you straight into the app.

## Features

- **Welcome & Login** — animated splash screen, Staff ID/password sign-in
  (no real auth yet), Forgot Password/SSO placeholders
- **Dashboard** — greeting, live attendance card, leave/work-hour stats,
  quick actions, important tasks preview, today's events
- **Attendance** — check-in/out, today's status, monthly summary, history
- **Leave** — apply for leave (full day / half day / hours), track request
  status
- **Leave & Balances** — total/used/remaining balance cards plus the same
  apply-leave flow and full history
- **HR Requests** — time correction, salary advance, ID card reissue,
  address/contact update, general inquiry — each with its own form fields
- **My Requests** — combined view of all submitted Leave + HR requests and
  their status
- **Tasks** — assigned tasks with status, priority, and progress
- **Kudos Wall** — give peer recognition (category + message + points),
  react and comment on posts
- **Anonymous Feedback** — submit suggestions, workplace concerns, manager/
  team feedback, policy feedback, or other — never linked to an employee
  identity
- **Employee Directory** — searchable coworker list with call/email actions
- **Payslips** — monthly list with earnings/deductions breakdown
- **Notices** — categorized company announcements
- **HR Calendar** — Nepali (Bikram Sambat) calendar with holiday, leave,
  attendance, and event markers, with filters
- **Events** — upcoming events countdown, "Add to Calendar" (device
  calendar)
- **Profile** — employment details (read-only) + editable phone number
  (routes through an HR request for approval)
- **Settings** — Light / Dark / System theme switcher

## Project structure

```
lib/
├── main.dart
├── data/
│   ├── calendar_data.dart
│   └── employee_directory_data.dart
├── state/
│   ├── attendance_state.dart
│   ├── feedback_state.dart
│   ├── hr_request_state.dart
│   ├── kudos_state.dart
│   ├── leave_state.dart
│   └── theme_state.dart
├── theme/
│   └── app_colors.dart
└── screens/
    ├── welcome_screen.dart
    ├── login_screen.dart
    ├── main_nav_screen.dart          # bottom tab bar hub
    ├── dashboard_screen.dart
    ├── apps_screen.dart              # grid hub linking to all modules
    ├── leave_screen.dart
    ├── leave_balances_screen.dart
    ├── request_screen.dart           # HR Requests
    ├── my_requests_screen.dart
    ├── kudos_screen.dart
    ├── give_kudos_screen.dart
    ├── kudos_preview_screen.dart
    ├── anonymous_feedback_screen.dart
    ├── employee_directory_screen.dart
    ├── payslip_screen.dart
    ├── notices_screen.dart
    ├── holiday_calendar_screen.dart
    ├── events_screen.dart
    ├── profile_screen.dart
    ├── settings_screen.dart
    └── apps/
        ├── attendance/
        ├── tasks/
        └── widgets/                  # shared: status badge, progress bar,
                                       # app module card, stat tile, etc.
```

## Getting started

```bash
flutter pub get
flutter run
```

Requires Xcode + iOS Simulator (or Android Studio) set up locally.
