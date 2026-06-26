import 'package:flutter/material.dart';
import '../models/terms_preset.dart';
import '../storage/local_db.dart';
import '../utils/ids.dart';

class TermsFormScreen extends StatefulWidget {
  final TermsPreset? existing;
  const TermsFormScreen({super.key, this.existing});

  @override
  State<TermsFormScreen> createState() => _TermsFormScreenState();
}

class _TermsFormScreenState extends State<TermsFormScreen> {
  final _nameCtl = TextEditingController();
  final _paymentCtl = TextEditingController();
  final _unloadingCtl = TextEditingController();
  final _minQtyCtl = TextEditingController();
  final _transportCtl = TextEditingController();
  final _liabilityCtl = TextEditingController();
  final _detentionCtl = TextEditingController();
  final _deliveryCtl = TextEditingController();
  final _claimCtl = TextEditingController();
  final _validityCtl = TextEditingController();
  final _jurisdictionCtl = TextEditingController();
  final _testReportCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final t = widget.existing ?? TermsPreset(id: '');
    _nameCtl.text = widget.existing == null ? '' : t.name;
    _paymentCtl.text = t.paymentTerms;
    _unloadingCtl.text = t.unloadingScope;
    _minQtyCtl.text = t.minQtyNote;
    _transportCtl.text = t.transportNote;
    _liabilityCtl.text = t.liabilityNote;
    _detentionCtl.text = t.detentionHours.toString();
    _deliveryCtl.text = t.deliveryDays.toString();
    _claimCtl.text = t.claimWindowDays.toString();
    _validityCtl.text = t.validityDays.toString();
    _jurisdictionCtl.text = t.jurisdiction;
    _testReportCtl.text = t.testReportNote;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtl,
      _paymentCtl,
      _unloadingCtl,
      _minQtyCtl,
      _transportCtl,
      _liabilityCtl,
      _detentionCtl,
      _deliveryCtl,
      _claimCtl,
      _validityCtl,
      _jurisdictionCtl,
      _testReportCtl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preset name is required')),
      );
      return;
    }
    final preset = TermsPreset(
      id: widget.existing?.id ?? generateId(),
      name: _nameCtl.text.trim(),
      paymentTerms: _paymentCtl.text.trim(),
      unloadingScope: _unloadingCtl.text.trim(),
      minQtyNote: _minQtyCtl.text.trim(),
      transportNote: _transportCtl.text.trim(),
      liabilityNote: _liabilityCtl.text.trim(),
      detentionHours: int.tryParse(_detentionCtl.text.trim()) ?? 4,
      deliveryDays: int.tryParse(_deliveryCtl.text.trim()) ?? 21,
      claimWindowDays: int.tryParse(_claimCtl.text.trim()) ?? 1,
      validityDays: int.tryParse(_validityCtl.text.trim()) ?? 7,
      jurisdiction: _jurisdictionCtl.text.trim(),
      testReportNote: _testReportCtl.text.trim(),
    );
    await LocalDB.instance.saveTermsPreset(preset);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _field(String label, TextEditingController ctl, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Terms Preset' : 'Edit Terms Preset')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _field('Preset Name *', _nameCtl),
          const Divider(height: 24),
          _field('1. Payment Terms', _paymentCtl, maxLines: 2),
          _field('Unloading & laying scope (e.g. Client / Seller)', _unloadingCtl),
          _field('Minimum quantity note (optional)', _minQtyCtl),
          const Divider(height: 24),
          _field('2. Transport note', _transportCtl, maxLines: 2),
          _field('Liability note (after unloading)', _liabilityCtl, maxLines: 2),
          _field('Detention free hours', _detentionCtl, keyboardType: TextInputType.number),
          const Divider(height: 24),
          _field('3. Delivery period (days after PO & advance)', _deliveryCtl, keyboardType: TextInputType.number),
          _field('Claim window (working days after receipt)', _claimCtl, keyboardType: TextInputType.number),
          const Divider(height: 24),
          _field('4. Validity (days from issue date)', _validityCtl, keyboardType: TextInputType.number),
          const Divider(height: 24),
          _field('5. Jurisdiction (for disputes)', _jurisdictionCtl),
          _field('Test report note', _testReportCtl, maxLines: 2),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _save, child: const Text('Save Preset')),
        ],
      ),
    );
  }
}
