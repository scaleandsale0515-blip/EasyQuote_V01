import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../models/quote_doc.dart';
import '../storage/local_db.dart';
import '../theme/app_theme.dart';
import '../pdf/pdf_builder.dart';
import 'document_form_screen.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String docId;
  const DocumentPreviewScreen({super.key, required this.docId});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  QuoteDoc? _doc;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final all = LocalDB.instance.getDocuments();
    final found = all.where((d) => d.id == widget.docId);
    setState(() => _doc = found.isEmpty ? null : found.first);
  }

  Future<Uint8List> _generate(PdfPageFormat format) async {
    final doc = _doc;
    if (doc == null) return Uint8List(0);
    final profile = LocalDB.instance.getProfile();
    final clients = LocalDB.instance.getClients();
    final client = clients.where((c) => c.id == doc.clientId);
    if (client.isEmpty) {
      _error = 'This document\'s client no longer exists.';
      return Uint8List(0);
    }
    try {
      return await DocumentPdfBuilder.build(profile: profile, client: client.first, doc: doc);
    } catch (e) {
      _error = 'PDF generation failed: $e';
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: const Center(child: Text('Document not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.refNo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DocumentFormScreen(docType: doc.type, existing: doc),
                ),
              );
              _load();
            },
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ),
            )
          : PdfPreview(
              build: _generate,
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: '${doc.refNo.replaceAll('/', '-')}.pdf',
              initialPageFormat: PdfPageFormat.a4,
            ),
    );
  }
}
