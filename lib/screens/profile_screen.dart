// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/calendar_data.dart';
import '../data/current_employee.dart';
import '../domain/pdf_documents.dart';
import '../state/hr_request_state.dart';
import '../state/notification_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/pdf_actions.dart';
import 'apps/widgets/ui_kit.dart';
import 'document_wallet_screen.dart';
import 'emergency_info_screen.dart';

// 2. PROFILE SCREEN
//
// Job Title, Department, Manager, Joining Date, Employment Type, and
// Work Location stay read-only — those are HR/company-controlled in
// a real system, not self-editable. Phone Number IS editable:
// submitting a change reuses the existing "Address/Contact Update"
// HR request flow instead of a separate approval system, so it shows
// up correctly in Request History and My Requests too.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // The "official" phone number on file — stays fixed until HR
  // actually approves a change (which, with no backend/Manager
  // portal yet, doesn't happen automatically). What the employee
  // sees reflects reality: their request is pending, not yet applied.
  static const _officialPhone = '+977 97xxxxxxxx';

  @override
  Widget build(BuildContext context) {
    final hrRequests = context.watch<HrRequestState>().requests;

    // The most recent still-pending phone update, if any — used to
    // show a "Pending HR Approval" note instead of silently dropping
    // the fact that a request was submitted.
    final pendingPhoneRequests = hrRequests
        .where(
          (r) =>
              r.category == RequestCategory.addressUpdate &&
              r.status == RequestStatus.pending &&
              r.newPhone != null,
        )
        .toList();
    final pendingPhone = pendingPhoneRequests.isEmpty
        ? null
        : pendingPhoneRequests.first.newPhone;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Profile')),

      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 24),

            // 3. AVATAR + NAME + EMPLOYEE ID
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.karmaRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        currentEmployee.name
                            .split(' ')
                            .map((w) => w[0])
                            .take(2)
                            .join(),
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    currentEmployee.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Employee ID: ${currentEmployee.employeeId}',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 4. EMPLOYMENT INFO — unchanged, stays read-only.
            CupertinoListSection.insetGrouped(
              header: const Text('EMPLOYMENT'),
              // From the shared profile — the same object the payslip and
              // salary certificate PDFs print, so they can't disagree.
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.briefcase_fill),
                  title: Text(currentEmployee.jobTitle),
                  subtitle: const Text('Job Title'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.building_2_fill),
                  title: Text(currentEmployee.department),
                  subtitle: const Text('Department'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person_2),
                  title: Text(currentEmployee.manager),
                  subtitle: const Text('Manager'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.calendar_today),
                  title: Text(
                    '${adMonths[currentEmployee.joiningDate.month - 1]} '
                    '${currentEmployee.joiningDate.day}, '
                    '${currentEmployee.joiningDate.year}',
                  ),
                  subtitle: const Text('Joining Date'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.doc_text),
                  title: Text(currentEmployee.employmentType),
                  subtitle: const Text('Employment Type'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.location_solid),
                  title: Text(currentEmployee.workLocation),
                  subtitle: const Text('Work Location'),
                ),
              ],
            ),

            // 5. CONTACT INFO — Phone Number is now editable.
            CupertinoListSection.insetGrouped(
              header: const Text('CONTACT'),
              footer: pendingPhone == null
                  ? null
                  : Text(
                      'Pending HR approval: $pendingPhone',
                      style: const TextStyle(
                        color: CupertinoColors.systemOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              children: [
                const CupertinoListTile(
                  leading: Icon(CupertinoIcons.mail),
                  title: Text('bishwas.sigdel@karmahr.com'),
                  subtitle: Text('Work Email'),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.phone),
                  title: const Text(_officialPhone),
                  subtitle: const Text('Phone Number'),
                  trailing: pendingPhone != null
                      ? const Icon(
                          CupertinoIcons.clock,
                          color: CupertinoColors.systemOrange,
                          size: 20,
                        )
                      : CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showEditPhoneSheet(context),
                          child: const Text('Edit'),
                        ),
                ),
              ],
            ),

            // 5b. DOCUMENTS — self-service letters that used to mean
            // emailing HR and waiting days.
            CupertinoListSection.insetGrouped(
              header: const Text('DOCUMENTS'),
              footer: const Text(
                'Salary certificates are generated instantly as a PDF, '
                'marked as a draft until HR signs and seals them.',
              ),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.doc_richtext),
                  title: const Text('Salary Certificate'),
                  subtitle: const Text('For bank loans, visas & verification'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => showPdfActions(
                    context,
                    title: 'Salary Certificate',
                    filename:
                        'salary-certificate-${currentEmployee.employeeId}.pdf',
                    build: () => buildSalaryCertificatePdf(),
                  ),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.folder_fill),
                  title: const Text('Document Wallet'),
                  subtitle: const Text('PAN, citizenship, contract & more'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const DocumentWalletScreen(),
                    ),
                  ),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.heart_circle_fill),
                  title: const Text('Emergency & Insurance'),
                  subtitle: const Text('Emergency contacts & health card'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const EmergencyInfoScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 6. EDIT PHONE SHEET
  //
  // Doesn't update anything directly — submits an "Address/Contact
  // Update" HR request, same as if the employee had filled out the
  // full HR Requests form. This is the ONLY way the phone number on
  // file changes, since there's no backend to apply it instantly.
  Future<void> _showEditPhoneSheet(BuildContext context) async {
    final entered = await showCupertinoModalPopup<String>(
      context: context,
      builder: (_) => const _EditPhoneSheet(initial: _officialPhone),
    );
    if (entered == null || !context.mounted) return;

    final newPhone = entered.trim();
    if (newPhone.isEmpty || newPhone == _officialPhone) return;

    // A Nepali mobile (NTC/Ncell/Smart): 10 digits starting 96/97/98,
    // optionally written with +977. Previously ANY text — even "abc" —
    // was filed as an HR request.
    final digits = newPhone.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(\+977)?9[678]\d{8}$').hasMatch(digits)) {
      await showMessage(
        context,
        title: 'Check the Number',
        message:
            'Enter a 10-digit mobile number starting with 96, 97 or 98 '
            '(optionally with +977).',
      );
      return;
    }
    if (!context.mounted) return;

    context.read<HrRequestState>().submitRequest(
      HrRequest(
        category: RequestCategory.addressUpdate,
        status: RequestStatus.pending,
        notes: 'Phone number update requested from Profile.',
        newPhone: newPhone,
      ),
    );
    notifyUser(
      context,
      kind: AppNotificationKind.hrRequest,
      title: 'Phone number update submitted',
      body: 'Your new number takes effect once HR approves it.',
    );
  }
}

// Owns its TextEditingController, so it's disposed only when the sheet is
// truly gone. It used to be created inside _showEditPhoneSheet and never
// disposed at all — one leaked controller per time the sheet opened.
class _EditPhoneSheet extends StatefulWidget {
  final String initial;

  const _EditPhoneSheet({required this.initial});

  @override
  State<_EditPhoneSheet> createState() => _EditPhoneSheetState();
}

class _EditPhoneSheetState extends State<_EditPhoneSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: AppColors.surface.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Expanded(
                    child: Text(
                      'Update Phone Number',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context, _controller.text),
                    child: const Text('Submit'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.phone,
                placeholder: 'Enter new phone number',
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
