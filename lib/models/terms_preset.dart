/// A saved Terms & Conditions preset — matches the 5-clause structure used
/// in the existing quotation/invoice template.
class TermsPreset {
  String id;
  String name; // preset label, e.g. "Standard Precast Terms"
  String paymentTerms;
  String unloadingScope;
  String minQtyNote;
  String transportNote;
  String liabilityNote;
  int detentionHours;
  int deliveryDays;
  int claimWindowDays;
  int validityDays;
  String jurisdiction;
  String testReportNote;

  TermsPreset({
    required this.id,
    this.name = 'Standard',
    this.paymentTerms = '100% advance along with PO.',
    this.unloadingScope = 'Client',
    this.minQtyNote = '',
    this.transportNote = 'Quoted rates are not inclusive of transport.',
    this.liabilityNote =
        'Our responsibility shall cease immediately after unloading of the material and no claim shall be entertained thereafter.',
    this.detentionHours = 4,
    this.deliveryDays = 21,
    this.claimWindowDays = 1,
    this.validityDays = 7,
    this.jurisdiction = 'Ahmedabad',
    this.testReportNote = 'Any test report of product required by buyer will be charged extra as actual.',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'paymentTerms': paymentTerms,
        'unloadingScope': unloadingScope,
        'minQtyNote': minQtyNote,
        'transportNote': transportNote,
        'liabilityNote': liabilityNote,
        'detentionHours': detentionHours,
        'deliveryDays': deliveryDays,
        'claimWindowDays': claimWindowDays,
        'validityDays': validityDays,
        'jurisdiction': jurisdiction,
        'testReportNote': testReportNote,
      };

  factory TermsPreset.fromMap(Map<dynamic, dynamic> m) => TermsPreset(
        id: m['id'],
        name: m['name'] ?? 'Standard',
        paymentTerms: m['paymentTerms'] ?? '',
        unloadingScope: m['unloadingScope'] ?? '',
        minQtyNote: m['minQtyNote'] ?? '',
        transportNote: m['transportNote'] ?? '',
        liabilityNote: m['liabilityNote'] ?? '',
        detentionHours: (m['detentionHours'] ?? 4).toInt(),
        deliveryDays: (m['deliveryDays'] ?? 21).toInt(),
        claimWindowDays: (m['claimWindowDays'] ?? 1).toInt(),
        validityDays: (m['validityDays'] ?? 7).toInt(),
        jurisdiction: m['jurisdiction'] ?? '',
        testReportNote: m['testReportNote'] ?? '',
      );
}
