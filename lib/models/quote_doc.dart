import 'line_item.dart';
import 'terms_preset.dart';

enum DocType { quotation, invoice }

enum DocStatus {
  draft,
  sent,
  accepted,
  rejected,
  converted,
  paid,
  partiallyPaid,
  overdue,
}

class QuoteDoc {
  String id;
  DocType type;
  String refNo;
  DateTime date;
  DateTime? dueDate;
  String clientId;
  String termsId;
  TermsPreset? termsSnapshot;

  List<LineItem> lineItems;
  List<String> headerNotes;
  List<String> specNotes;
  String introText; // optional override; blank = auto-generate like the original template
  String siteLocation; // optional; folded into the auto-generated intro line

  double gstPercent;
  bool includePO;
  String poInName;
  double poPercent;
  double amountPaid;

  DocStatus status;

  QuoteDoc({
    required this.id,
    required this.type,
    required this.refNo,
    required this.date,
    this.dueDate,
    this.clientId = '',
    this.termsId = '',
    this.termsSnapshot,
    List<LineItem>? lineItems,
    List<String>? headerNotes,
    List<String>? specNotes,
    this.introText = '',
    this.siteLocation = '',
    this.gstPercent = 18,
    this.includePO = false,
    this.poInName = '',
    this.poPercent = 0,
    this.amountPaid = 0,
    this.status = DocStatus.draft,
  })  : lineItems = lineItems ?? [],
        headerNotes = headerNotes ?? [],
        specNotes = specNotes ?? [];

  double get subtotal => lineItems.fold(0.0, (sum, li) => sum + li.amount);
  double get gstAmount => subtotal * (gstPercent / 100);
  double get total => subtotal + gstAmount;
  double get balanceDue => total - amountPaid;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'refNo': refNo,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'clientId': clientId,
        'termsId': termsId,
        'termsSnapshot': termsSnapshot?.toMap(),
        'lineItems': lineItems.map((e) => e.toMap()).toList(),
        'headerNotes': headerNotes,
        'specNotes': specNotes,
        'introText': introText,
        'siteLocation': siteLocation,
        'gstPercent': gstPercent,
        'includePO': includePO,
        'poInName': poInName,
        'poPercent': poPercent,
        'amountPaid': amountPaid,
        'status': status.name,
      };

  factory QuoteDoc.fromMap(Map<dynamic, dynamic> m) => QuoteDoc(
        id: m['id'],
        type: DocType.values.firstWhere((e) => e.name == m['type'], orElse: () => DocType.quotation),
        refNo: m['refNo'] ?? '',
        date: DateTime.parse(m['date']),
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
        clientId: m['clientId'] ?? '',
        termsId: m['termsId'] ?? '',
        termsSnapshot: m['termsSnapshot'] != null
            ? TermsPreset.fromMap(Map<dynamic, dynamic>.from(m['termsSnapshot']))
            : null,
        lineItems: (m['lineItems'] as List? ?? []).map((e) => LineItem.fromMap(e)).toList(),
        headerNotes: List<String>.from(m['headerNotes'] ?? []),
        specNotes: List<String>.from(m['specNotes'] ?? []),
        introText: m['introText'] ?? '',
        siteLocation: m['siteLocation'] ?? '',
        gstPercent: (m['gstPercent'] ?? 18).toDouble(),
        includePO: m['includePO'] ?? false,
        poInName: m['poInName'] ?? '',
        poPercent: (m['poPercent'] ?? 0).toDouble(),
        amountPaid: (m['amountPaid'] ?? 0).toDouble(),
        status: DocStatus.values.firstWhere((e) => e.name == m['status'], orElse: () => DocStatus.draft),
      );
}
