// The employee's own copies of important documents — PAN, citizenship,
// contract, certificates. Photos stay on the device (file paths only),
// and the wallet screen asks for App Lock authentication to open.
//
// Frontend-only: kept in memory, so it clears on restart and on logout
// like everything else. A real version would store these encrypted.

import 'package:flutter/cupertino.dart';

enum WalletDocType { pan, citizenship, contract, certificate, other }

String walletDocTypeLabel(WalletDocType t) => switch (t) {
  WalletDocType.pan => 'PAN Card',
  WalletDocType.citizenship => 'Citizenship Certificate',
  WalletDocType.contract => 'Employment Contract',
  WalletDocType.certificate => 'Certificate',
  WalletDocType.other => 'Other Document',
};

IconData walletDocTypeIcon(WalletDocType t) => switch (t) {
  WalletDocType.pan => CupertinoIcons.creditcard_fill,
  WalletDocType.citizenship => CupertinoIcons.person_crop_rectangle_fill,
  WalletDocType.contract => CupertinoIcons.doc_text_fill,
  WalletDocType.certificate => CupertinoIcons.rosette,
  WalletDocType.other => CupertinoIcons.folder_fill,
};

class WalletDocument {
  final String id;
  final WalletDocType type;
  final String title;
  final String? number;
  final String? imagePath;
  final DateTime addedAt;

  const WalletDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.addedAt,
    this.number,
    this.imagePath,
  });
}

/// Shows only the last 4 characters of an ID number — enough to tell
/// documents apart at a glance without exposing the whole number to
/// anyone glancing at the screen.
String maskIdNumber(String number) {
  final trimmed = number.trim();
  if (trimmed.length <= 4) return trimmed;
  return '•••• ${trimmed.substring(trimmed.length - 4)}';
}

class DocumentWalletState extends ChangeNotifier {
  final List<WalletDocument> _docs = _seed();
  int _nextId = 100;

  static List<WalletDocument> _seed() => [
    WalletDocument(
      id: 'seed-pan',
      type: WalletDocType.pan,
      title: 'PAN Card',
      number: '601234567',
      addedAt: DateTime(2024, 1, 12),
    ),
    WalletDocument(
      id: 'seed-contract',
      type: WalletDocType.contract,
      title: 'Employment Contract 2024',
      addedAt: DateTime(2024, 1, 12),
    ),
  ];

  List<WalletDocument> get documents => List.unmodifiable(_docs);

  void add({
    required WalletDocType type,
    required String title,
    String? number,
    String? imagePath,
  }) {
    _docs.insert(
      0,
      WalletDocument(
        id: 'doc-${_nextId++}',
        type: type,
        title: title,
        number: (number == null || number.trim().isEmpty)
            ? null
            : number.trim(),
        imagePath: imagePath,
        addedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void remove(String id) {
    _docs.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void reset() {
    _docs
      ..clear()
      ..addAll(_seed());
    _nextId = 100;
    notifyListeners();
  }
}
