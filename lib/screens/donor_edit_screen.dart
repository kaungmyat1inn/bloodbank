import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../widgets/responsive.dart';

/// Edit an existing donor's profile fields (name, blood type, address, phone,
/// Viber). Donation history is managed separately and is not touched here.
class DonorEditScreen extends StatefulWidget {
  const DonorEditScreen({super.key, required this.donor});

  final Donor donor;

  @override
  State<DonorEditScreen> createState() => _DonorEditScreenState();
}

class _DonorEditScreenState extends State<DonorEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.donor.name);
  late final TextEditingController _addressCtrl =
      TextEditingController(text: widget.donor.address);
  late final TextEditingController _phoneCtrl =
      TextEditingController(text: widget.donor.phone);
  late final TextEditingController _viberCtrl =
      TextEditingController(text: widget.donor.viber);
  late String? _bloodType =
      kBloodTypes.contains(widget.donor.bloodType) ? widget.donor.bloodType : null;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _viberCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('သွေးအမျိုးအစား ရွေးချယ်ပါ')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<DonorService>().updateDonorInfo(
            donorId: widget.donor.id,
            name: _nameCtrl.text,
            bloodType: _bloodType!,
            address: _addressCtrl.text,
            phone: _phoneCtrl.text,
            viber: _viberCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ပြင်ဆင်မှု သိမ်းပြီးပါပြီ')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('မအောင်မြင်ပါ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ပြင်ဆင်ရန် • အဖွဲ့ဝင်အမှတ် ${widget.donor.memberId}'),
      ),
      body: SingleChildScrollView(
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
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'အမည်'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'အမည်ထည့်ပါ' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _bloodType,
                      decoration:
                          const InputDecoration(labelText: 'သွေးအမျိုးအစား'),
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'ဖုန်းနံပါတ်ထည့်ပါ'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _viberCtrl,
                      decoration: const InputDecoration(labelText: 'Viber'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
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
                      label: Text(_saving ? 'သိမ်းနေသည်...' : 'သိမ်းမည်'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
