import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../widgets/responsive.dart';

class DonorRegisterScreen extends StatefulWidget {
  const DonorRegisterScreen({super.key});

  @override
  State<DonorRegisterScreen> createState() => _DonorRegisterScreenState();
}

class _DonorRegisterScreenState extends State<DonorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _viberCtrl = TextEditingController();
  String? _bloodType;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _viberCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('သွေးအမျိုးအစား ရွေးချယ်ပါ')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = context.read<DonorService>();
      final memberId = await service.registerDonor(
        name: _nameCtrl.text,
        bloodType: _bloodType!,
        address: _addressCtrl.text,
        phone: _phoneCtrl.text,
        viber: _viberCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('စာရင်းသွင်းပြီးပါပြီ • အဖွဲ့ဝင်အမှတ် $memberId')),
      );
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _addressCtrl.clear();
      _phoneCtrl.clear();
      _viberCtrl.clear();
      setState(() => _bloodType = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('မအောင်မြင်ပါ: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MaxWidthBox(
        maxWidth: 640,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'သွေးလှူရှင်အသစ် စာရင်းသွင်းမည်',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'အမည်'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'အမည်ထည့်ပါ' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _bloodType,
                    decoration: const InputDecoration(labelText: 'သွေးအမျိုးအစား'),
                    items: [
                      for (final type in kBloodTypes)
                        DropdownMenuItem(value: type, child: Text(type)),
                    ],
                    onChanged: (v) => setState(() => _bloodType = v),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(labelText: 'လိပ်စာ'),
                    minLines: 2,
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'လိပ်စာထည့်ပါ' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'ဖုန်းနံပါတ်'),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'ဖုန်းနံပါတ်ထည့်ပါ' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _viberCtrl,
                    decoration: const InputDecoration(labelText: 'Viber'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'သိမ်းနေသည်...' : 'စာရင်းသွင်းမည်'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
