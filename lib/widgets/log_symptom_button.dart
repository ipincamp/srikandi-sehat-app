import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';

class LogSymptomButton extends StatelessWidget {
  const LogSymptomButton({super.key});

  Future<void> _submitLogSymptom({
    required BuildContext context,
    required Set<int> selectedSymptomIds,
    required int? selectedMood,
    required String notes,
  }) async {
    final symptomLogProvider =
        Provider.of<SymptomLogProvider>(context, listen: false);
    final symptomProvider =
        Provider.of<SymptomProvider>(context, listen: false);

    final selectedSymptomNames = symptomProvider.symptoms
        .where((s) => selectedSymptomIds.contains(s.id))
        .map((s) => s.name)
        .toList();

    final success = await symptomLogProvider.logSymptoms(
      symptoms: selectedSymptomNames,
      moodScore: selectedSymptomIds.contains(2) ? selectedMood : null,
      notes: notes.isNotEmpty ? notes : null,
      logDate: DateTime.now().toIso8601String().split('T').first,
    );

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Gejala berhasil dicatat!' : 'Gagal mencatat gejala.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final symptomProvider =
            Provider.of<SymptomProvider>(context, listen: false);
        await symptomProvider.fetchSymptoms();
        if (context.mounted) {
          _showLogSymptomsBottomSheet(context);
        }
      },
      icon: const Icon(Icons.edit_note, color: Colors.white),
      label: const Text('Gejala', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showLogSymptomsBottomSheet(BuildContext context) {
    final symptomProvider =
        Provider.of<SymptomProvider>(context, listen: false);
    final symptoms = symptomProvider.symptoms;
    final TextEditingController _notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        Set<int> selectedSymptomIds = {};
        int? selectedMood;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bc).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final isMoodSwingSelected = selectedSymptomIds.contains(2);

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catat Gejala Hari Ini',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 20),
                    if (symptoms.isNotEmpty)
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: symptoms.map((symptom) {
                          final isSelected =
                              selectedSymptomIds.contains(symptom.id);
                          return ChoiceChip(
                            label: Text(symptom.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedSymptomIds.add(symptom.id as int);
                                } else {
                                  selectedSymptomIds.remove(symptom.id);
                                  if (symptom.id == 2) selectedMood = null;
                                }
                              });
                            },
                            selectedColor: Colors.pink,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.pink,
                            ),
                            backgroundColor: Colors.pink.shade50,
                          );
                        }).toList(),
                      )
                    else
                      const Center(child: Text('Tidak ada data gejala')),
                    const SizedBox(height: 20),
                    if (isMoodSwingSelected) ...[
                      Text('Mood (1–4)',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMoodOption(
                              1,
                              'Marah',
                              Icons.sentiment_very_dissatisfied,
                              Colors.red,
                              selectedMood, (val) {
                            setState(() => selectedMood = val);
                          }),
                          _buildMoodOption(
                              2,
                              'Sedih',
                              Icons.sentiment_dissatisfied,
                              Colors.blueGrey,
                              selectedMood, (val) {
                            setState(() => selectedMood = val);
                          }),
                          _buildMoodOption(3, 'Biasa', Icons.sentiment_neutral,
                              Colors.grey, selectedMood, (val) {
                            setState(() => selectedMood = val);
                          }),
                          _buildMoodOption(
                              4,
                              'Senang',
                              Icons.sentiment_satisfied_alt,
                              Colors.green,
                              selectedMood, (val) {
                            setState(() => selectedMood = val);
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    CustomFormField(
                      placeholder: 'Masukkan keluhan anda',
                      label: 'Catatan',
                      type: CustomFormFieldType.text,
                      controller: _notesController,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _submitLogSymptom(
                            context: context,
                            selectedSymptomIds: selectedSymptomIds,
                            selectedMood: selectedMood,
                            notes: _notesController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Simpan Log',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMoodOption(
    int value,
    String label,
    IconData icon,
    Color color,
    int? selectedValue,
    void Function(int) onSelect,
  ) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Column(
        children: [
          Icon(icon,
              size: 40, color: isSelected ? color : color.withOpacity(0.4)),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : color.withOpacity(0.4),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
