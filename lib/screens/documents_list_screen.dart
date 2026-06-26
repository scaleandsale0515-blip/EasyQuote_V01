import 'package:flutter/material.dart';
import '../models/quote_doc.dart';
import '../models/client.dart';
import '../storage/local_db.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'document_form_screen.dart';
import 'document_preview_screen.dart';

class DocumentsListScreen extends StatefulWidget {
  final DocType docType;
  const DocumentsListScreen({super.key, required this.docType});

  @override
  State<DocumentsListScreen> createState() => _DocumentsListScreenState();
}

class _DocumentsListScreenState extends State<DocumentsListScreen> {
  List<QuoteDoc> _docs = [];
  Map<String, Client> _clientsById = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final all = LocalDB.instance.getDocuments().where((d) => d.type == widget.docType).toList();
    all.sort((a, b) => b.date.compareTo(a.date));
    final clients = LocalDB.instance.getClients();
    setState(() {
      _docs = all;
      _clientsById = {for (final c in clients) c.id: c};
    });
  }

  Future<void> _openNew() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DocumentFormScreen(docType: widget.docType)),
    );
    _reload();
  }

  Future<void> _openExisting(QuoteDoc d) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DocumentPreviewScreen(docId: d.id)),
    );
    _reload();
  }

  Future<void> _confirmDelete(QuoteDoc d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('Remove "${d.refNo}" from this device. This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await LocalDB.instance.deleteDocument(d.id);
      _reload();
    }
  }

  Color _statusColor(DocStatus s) {
    switch (s) {
      case DocStatus.draft:
        return const Color(0xFF8B8678);
      case DocStatus.sent:
        return AppColors.blueprint;
      case DocStatus.accepted:
      case DocStatus.paid:
        return AppColors.ok;
      case DocStatus.rejected:
      case DocStatus.overdue:
        return AppColors.danger;
      case DocStatus.converted:
      case DocStatus.partiallyPaid:
        return AppColors.rebar;
    }
  }

  String _statusLabel(DocStatus s) {
    switch (s) {
      case DocStatus.draft:
        return 'Draft';
      case DocStatus.sent:
        return 'Sent';
      case DocStatus.accepted:
        return 'Accepted';
      case DocStatus.rejected:
        return 'Rejected';
      case DocStatus.converted:
        return 'Converted';
      case DocStatus.paid:
        return 'Paid';
      case DocStatus.partiallyPaid:
        return 'Partially Paid';
      case DocStatus.overdue:
        return 'Overdue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isQuotation = widget.docType == DocType.quotation;
    return Scaffold(
      appBar: AppBar(title: Text(isQuotation ? 'Quotations' : 'Invoices')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNew,
        child: const Icon(Icons.add),
      ),
      body: _docs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isQuotation ? Icons.request_quote_outlined : Icons.receipt_long_outlined,
                        size: 48, color: AppColors.line),
                    const SizedBox(height: 12),
                    Text('No ${isQuotation ? 'quotations' : 'invoices'} yet',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Tap + to create one.', style: TextStyle(color: AppColors.inkSoft)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final d = _docs[idx];
                final client = _clientsById[d.clientId];
                return Card(
                  child: ListTile(
                    title: Text(d.refNo, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${client?.companyName ?? '—'}  •  ${formatDate(d.date)}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    onTap: () => _openExisting(d),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(formatRupees(d.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: _statusColor(d.status)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _statusLabel(d.status),
                                style: TextStyle(fontSize: 10, color: _statusColor(d.status), fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          onPressed: () => _confirmDelete(d),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
