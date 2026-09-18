// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/hr_request_state.dart';
import '../theme/app_colors.dart';

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
                    child: const Center(
                      child: Text(
                        'BS',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Bishwas Sigdel',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Employee ID: MB-24071',
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
              children: const [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.briefcase_fill),
                  title: Text('HR Associate'),
                  subtitle: Text('Job Title'),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.building_2_fill),
                  title: Text('Human Resources'),
                  subtitle: Text('Department'),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.person_2),
                  title: Text('Suresh Karki'),
                  subtitle: Text('Manager'),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.calendar_today),
                  title: Text('January 12, 2024'),
                  subtitle: Text('Joining Date'),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.doc_text),
                  title: Text('Full-Time'),
                  subtitle: Text('Employment Type'),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.location_solid),
                  title: Text('Kathmandu Head Office'),
                  subtitle: Text('Work Location'),
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
  void _showEditPhoneSheet(BuildContext context) {
    final controller = TextEditingController(text: _officialPhone);

    showCupertinoModalPopup(
      context: context,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          color: AppColors.surface.resolveFrom(sheetContext),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                    const Text(
                      'Update Phone Number',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final newPhone = controller.text.trim();
                        if (newPhone.isNotEmpty && newPhone != _officialPhone) {
                          context.read<HrRequestState>().submitRequest(
                            HrRequest(
                              category: RequestCategory.addressUpdate,
                              status: RequestStatus.pending,
                              notes:
                                  'Phone number update requested from Profile.',
                              newPhone: newPhone,
                            ),
                          );
                        }
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  placeholder: 'Enter new phone number',
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6.resolveFrom(
                      sheetContext,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
