// Open jobs and the people who applied for them. HR adds jobs and
// applicants, and moves each applicant along. COMPANY data: logout does not
// reset it.

import 'package:flutter/foundation.dart';

enum ApplicantStage { applied, screening, interview, offer, hired, rejected }

class JobPost {
  final String id;
  final String title;
  final String department;
  final int openings;
  final bool isOpen;

  const JobPost({
    required this.id,
    required this.title,
    required this.department,
    required this.openings,
    this.isOpen = true,
  });

  JobPost withOpen(bool open) => JobPost(
    id: id,
    title: title,
    department: department,
    openings: openings,
    isOpen: open,
  );
}

class Applicant {
  final String id;
  final String jobId;
  final String name;
  final String email;
  final ApplicantStage stage;

  const Applicant({
    required this.id,
    required this.jobId,
    required this.name,
    required this.email,
    this.stage = ApplicantStage.applied,
  });

  /// Still being considered: not hired and not turned down.
  bool get isActive =>
      stage != ApplicantStage.hired && stage != ApplicantStage.rejected;

  Applicant withStage(ApplicantStage stage) =>
      Applicant(id: id, jobId: jobId, name: name, email: email, stage: stage);
}

class HiringState extends ChangeNotifier {
  final List<JobPost> _jobs = [
    const JobPost(
      id: 'j1',
      title: 'Senior Accountant',
      department: 'Finance',
      openings: 1,
    ),
    const JobPost(
      id: 'j2',
      title: 'Flutter Developer',
      department: 'Information Technology',
      openings: 2,
    ),
    const JobPost(
      id: 'j3',
      title: 'Office Assistant',
      department: 'Operations',
      openings: 1,
      isOpen: false,
    ),
  ];

  final List<Applicant> _applicants = [
    const Applicant(
      id: 'a1',
      jobId: 'j1',
      name: 'Sunita Pandey',
      email: 'sunita.pandey@example.com',
      stage: ApplicantStage.interview,
    ),
    const Applicant(
      id: 'a2',
      jobId: 'j1',
      name: 'Rajan Bhattarai',
      email: 'rajan.bhattarai@example.com',
    ),
    const Applicant(
      id: 'a3',
      jobId: 'j2',
      name: 'Kriti Tamang',
      email: 'kriti.tamang@example.com',
      stage: ApplicantStage.screening,
    ),
    const Applicant(
      id: 'a4',
      jobId: 'j2',
      name: 'Anil Gurung',
      email: 'anil.gurung@example.com',
      stage: ApplicantStage.offer,
    ),
    const Applicant(
      id: 'a5',
      jobId: 'j3',
      name: 'Pooja Thapa',
      email: 'pooja.thapa@example.com',
      stage: ApplicantStage.hired,
    ),
  ];

  var _nextId = 100;

  /// Open jobs first, then by title.
  List<JobPost> get jobs => _jobs.toList()
    ..sort((a, b) {
      if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
      return a.title.compareTo(b.title);
    });

  JobPost? jobById(String id) {
    for (final j in _jobs) {
      if (j.id == id) return j;
    }
    return null;
  }

  List<Applicant> applicantsFor(String jobId) =>
      _applicants.where((a) => a.jobId == jobId).toList();

  /// People still in the running for [jobId].
  int activeCount(String jobId) =>
      applicantsFor(jobId).where((a) => a.isActive).length;

  /// A job needs a title and department and at least one opening.
  JobPost? addJob(String title, String department, int openings) {
    final t = title.trim();
    final d = department.trim();
    if (t.isEmpty || d.isEmpty || openings < 1) return null;
    final job = JobPost(
      id: 'j${_nextId++}',
      title: t,
      department: d,
      openings: openings,
    );
    _jobs.add(job);
    notifyListeners();
    return job;
  }

  void setOpen(String jobId, bool open) {
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i < 0 || _jobs[i].isOpen == open) return;
    _jobs[i] = _jobs[i].withOpen(open);
    notifyListeners();
  }

  /// An applicant needs a name; an unknown job is refused.
  Applicant? addApplicant(String jobId, String name, String email) {
    final n = name.trim();
    if (n.isEmpty || jobById(jobId) == null) return null;
    final a = Applicant(
      id: 'a${_nextId++}',
      jobId: jobId,
      name: n,
      email: email.trim(),
    );
    _applicants.add(a);
    notifyListeners();
    return a;
  }

  /// applied, screening, interview, offer, hired. Hired and rejected are
  /// the end of the line.
  void advance(String applicantId) {
    final i = _applicants.indexWhere((a) => a.id == applicantId);
    if (i < 0 || !_applicants[i].isActive) return;
    _applicants[i] = _applicants[i].withStage(
      ApplicantStage.values[_applicants[i].stage.index + 1],
    );
    notifyListeners();
  }

  void reject(String applicantId) {
    final i = _applicants.indexWhere((a) => a.id == applicantId);
    if (i < 0 || !_applicants[i].isActive) return;
    _applicants[i] = _applicants[i].withStage(ApplicantStage.rejected);
    notifyListeners();
  }
}
