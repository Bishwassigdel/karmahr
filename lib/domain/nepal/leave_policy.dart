// Leave rules as DATA, not logic scattered across screens.
//
// Every number in `leavePolicies` below is a PLACEHOLDER modeled loosely
// on Nepal's Labour Act 2074 provisions and common private-sector
// practice — it has NOT been verified against the Act's current text or
// against KarmaHR's actual company bylaw. Treat every value here as
// "needs sign-off from HR/legal" before this app is used to make a real
// decision. When that happens, this is the ONLY file that needs editing —
// no UI screen should ever hardcode a leave-day number again.

/// One leave type's entitlement rules for a fiscal year.
class LeavePolicy {
  /// Matches the strings used in LeaveState/LeaveRequest.leaveType, e.g.
  /// 'Home Leave'. Kept as the map key (below) rather than an enum so new
  /// leave types can be added without touching this class.
  final String type;

  /// Flat number of days granted at the start of the fiscal year,
  /// regardless of days worked. Used for leave types like Sick or
  /// Mourning leave. Null if this type instead accrues (see below).
  final double? annualGrant;

  /// For accrual-based types (e.g. Home Leave): one day is earned for
  /// every N days worked. Null if this type is a flat annual grant.
  final double? accrualPerWorkedDays;

  /// Maximum unused days that survive into the next fiscal year; any
  /// balance above this lapses at Ashad-end. 0 means "use it or lose it
  /// entirely"; double.infinity means "no cap".
  final double carryForwardCap;

  /// Whether the employee is paid for these days.
  final bool paid;

  /// Whether a supporting document (e.g. a medical certificate) is
  /// expected once a single request exceeds [documentThresholdDays].
  final bool requiresDocument;
  final int documentThresholdDays;

  /// Whether this leave type can be used while still on probation.
  final bool allowedDuringProbation;

  const LeavePolicy({
    required this.type,
    this.annualGrant,
    this.accrualPerWorkedDays,
    this.carryForwardCap = 0,
    this.paid = true,
    this.requiresDocument = false,
    this.documentThresholdDays = 3,
    this.allowedDuringProbation = true,
  }) : assert(
         (annualGrant == null) != (accrualPerWorkedDays == null),
         'A LeavePolicy must set exactly one of annualGrant or '
         'accrualPerWorkedDays — a leave type is either a flat grant or '
         'an accrual, not both and not neither.',
       );

  bool get isAccrualBased => accrualPerWorkedDays != null;
}

/// NOTE(hr-review): verify every number below against Labour Act 2074
/// and the company bylaw before relying on this for real decisions.
const Map<String, LeavePolicy> leavePolicies = {
  'Home Leave': LeavePolicy(
    type: 'Home Leave',
    // ~1 day earned per 20 days worked → roughly 18 days/year for a
    // full year worked, matching common Labour Act guidance.
    accrualPerWorkedDays: 20,
    carryForwardCap: 90,
    paid: true,
  ),
  'Sick Leave': LeavePolicy(
    type: 'Sick Leave',
    annualGrant: 12,
    carryForwardCap: 45,
    paid: true,
    requiresDocument: true,
    documentThresholdDays: 3,
  ),
  'Maternity Leave': LeavePolicy(
    type: 'Maternity Leave',
    annualGrant: 98,
    carryForwardCap: 0,
    paid: true,
    allowedDuringProbation: false,
  ),
  'Maternity Care Leave': LeavePolicy(
    type: 'Maternity Care Leave',
    annualGrant: 15,
    carryForwardCap: 0,
    paid: true,
    allowedDuringProbation: false,
  ),
  'Mourning Leave': LeavePolicy(
    type: 'Mourning Leave',
    annualGrant: 13,
    carryForwardCap: 0,
    paid: true,
  ),
  'Substitute Leave': LeavePolicy(
    type: 'Substitute Leave',
    annualGrant: 0,
    carryForwardCap: 0,
    paid: true,
  ),
  'Unpaid Leave': LeavePolicy(
    type: 'Unpaid Leave',
    annualGrant: double.infinity,
    carryForwardCap: 0,
    paid: false,
  ),
};

/// Looks up a policy by leave-type name, or null if it's not a known
/// type (callers should treat unknown types as "no cap tracked").
LeavePolicy? policyFor(String leaveType) => leavePolicies[leaveType];
