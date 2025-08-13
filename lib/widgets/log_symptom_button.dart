import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/symptom_model.dart';
import 'package:srikandi_sehat_app/provider/symptom_get_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_post_provider.dart';
import 'package:srikandi_sehat_app/widgets/action_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';

class SymptomLogButton extends StatelessWidget {
  const SymptomLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomProvider>(
      builder: (context, symptomProvider, _) {
        return ActionButton(
          icon: Icons.edit_note,
          label: 'Gejala',
          color: Colors.teal,
          isActive: !symptomProvider.isLoading,
          onPressed: () => _showLogSymptomsBottomSheet(context),
          loading: symptomProvider.isLoading,
          loadingWidget: const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _showLogSymptomsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _SymptomLogBottomSheet(),
    );
  }
}

class _SymptomLogBottomSheet extends StatefulWidget {
  const _SymptomLogBottomSheet();

  @override
  State<_SymptomLogBottomSheet> createState() => _SymptomLogBottomSheetState();
}

class _SymptomLogBottomSheetState extends State<_SymptomLogBottomSheet> {
  final TextEditingController _notesController = TextEditingController();
  final List<Map<String, dynamic>> _selectedSymptoms = [];
  int? _dismenoreaSeverity;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleSymptom(Symptom symptom, bool selected) {
    setState(() {
      if (selected) {
        _selectedSymptoms.add({
          'symptom_id': symptom.id,
          if (symptom.id == 4) 'option_id': 1, // Default severity
        });
        if (symptom.id == 4) {
          _dismenoreaSeverity = 1;
        }
      } else {
        _selectedSymptoms.removeWhere((s) => s['symptom_id'] == symptom.id);
        if (symptom.id == 4) {
          _dismenoreaSeverity = null;
        }
      }
    });
  }

  void _updateDismenoreaSeverity(int severity) {
    setState(() {
      _dismenoreaSeverity = severity;
      final index = _selectedSymptoms.indexWhere((s) => s['symptom_id'] == 4);
      if (index >= 0) {
        _selectedSymptoms[index]['option_id'] = severity;
      }
    });
  }

  Future<void> _submitSymptoms(BuildContext context) async {
    if (_selectedSymptoms.isEmpty) {
      CustomAlert.show(
        context,
        'Pilih minimal satu gejala',
        type: AlertType.warning,
      );
      return;
    }

    final provider = Provider.of<SymptomLogProvider>(context, listen: false);
    final symptomProvider = Provider.of<SymptomProvider>(
      context,
      listen: false,
    );

    final result = await provider.logSymptoms(
      loggedAt: DateTime.now().toIso8601String(),
      note: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      symptoms: _selectedSymptoms,
    );

    if (!context.mounted) return;

    if (result.success) {
      Navigator.pop(context);
      CustomAlert.show(
        context,
        result.message ?? 'Gejala berhasil dicatat!',
        type: AlertType.success,
      );

      // Refresh symptom data
      await symptomProvider.fetchSymptoms();
    } else if (result.error != null) {
      CustomAlert.show(context, result.error!, type: AlertType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final symptomProvider = Provider.of<SymptomProvider>(context);
    final symptoms = symptomProvider.symptoms;
    final isLoading = symptomProvider.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catat Gejala Hari Ini',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih Gejala:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (symptoms.isEmpty)
              const Text('Tidak ada gejala tersedia')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.any(
                    (s) => s['symptom_id'] == symptom.id,
                  );
                  return FilterChip(
                    label: Text(symptom.name),
                    selected: isSelected,
                    onSelected: (selected) => _toggleSymptom(symptom, selected),
                  );
                }).toList(),
              ),
            if (_selectedSymptoms.any((s) => s['symptom_id'] == 4)) ...[
              const SizedBox(height: 20),
              Text(
                'Tingkat Dismenorea (1-5):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [1, 2, 3, 4, 5].map((severity) {
                  return ChoiceChip(
                    label: Text(severity.toString()),
                    selected: _dismenoreaSeverity == severity,
                    onSelected: (_) => _updateDismenoreaSeverity(severity),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Consumer<SymptomLogProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => _submitSymptoms(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
