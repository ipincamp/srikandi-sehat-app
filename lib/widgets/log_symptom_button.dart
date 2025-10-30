import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/symptom_model.dart';
import 'package:app/provider/symptom_history_detail_provider.dart';
import 'package:app/provider/symptom_log_get_provider.dart';
import 'package:app/provider/symptom_log_post_provider.dart';
import 'package:app/screens/user/symptom_history_detail_screen.dart';
import 'package:app/utils/date_format.dart';
import 'package:app/widgets/action_button.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/custom_form.dart';

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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const _SymptomLogBottomSheet(),
      ),
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
          if (symptom.id == 4) 'option_id': 1, // Default to mild severity
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
      // Check mounted before showing alert, just in case
      if (!mounted) return;
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
    // Simpan NavigatorState SEBELUM await dan pop
    final navigator = Navigator.of(context);
    // Simpan ScaffoldMessengerState jika perlu alert setelah pop
    // final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Panggil API untuk log gejala
    final result = await provider.logSymptoms(
      loggedAt: DateTime.now().toLocalIso8601String(),
      note: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      symptoms: _selectedSymptoms,
    );

    // Periksa apakah widget masih mounted setelah await
    if (!mounted) return;

    if (result.success) {
      // Tutup bottom sheet MENGGUNAKAN navigator yang disimpan
      navigator.pop();

      // Tampilkan notifikasi sukses MENGGUNAKAN scaffoldMessenger yang disimpan
      /*
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Gejala berhasil dicatat!'),
          backgroundColor: Colors.green,
        ),
      );
      */
      // Tampilkan notifikasi sukses MENGGUNAKAN CustomAlert
      if (mounted) {
        // <--- Cek mounted lagi sebelum panggil CustomAlert
        CustomAlert.show(
          context, // Gunakan context asli dari BottomSheet
          result.message ?? 'Gejala berhasil dicatat!',
          type: AlertType.success,
        );
      }

      // Refresh data gejala (tidak perlu context)
      await symptomProvider.fetchSymptoms();

      // Navigasi ke detail jika ada ID, MENGGUNAKAN navigator yang disimpan
      if (result.id != null) {
        navigator.push(
          // Gunakan navigator yang disimpan
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              // context baru dari builder
              create: (_) => SymptomDetailProvider(),
              child: SymptomDetailScreen(symptomId: result.id!),
            ),
          ),
        );
      }
    } else if (result.error != null) {
      // Tampilkan error MENGGUNAKAN scaffoldMessenger yang disimpan
      /*
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(result.error!), backgroundColor: Colors.red),
      );
      */
      // Jika CustomAlert:
      if (mounted) {
        CustomAlert.show(context, result.error!, type: AlertType.error);
      }
    }
  }

  // Get icon and color for each symptom
  IconData _getSymptomIcon(int symptomId) {
    switch (symptomId) {
      case 1:
        return Icons.healing;
      case 2:
        return Icons.sick;
      case 3:
        return Icons.female;
      case 4: // Dismenorea
        return Icons.emoji_emotions;
      default:
        return Icons.medical_services;
    }
  }

  Color _getSymptomColor(int symptomId) {
    switch (symptomId) {
      case 1: // Kram perut
        return Colors.red;
      case 2: // Sakit kepala
        return Colors.green;
      case 3: // Nyeri payudara
        return Colors.pinkAccent;
      case 4: // Dismenorea
        return Colors.deepPurple;
      default:
        return const Color(0xFF90A4AE);
    }
  }

  // Helper function to get emoji and mood text based on severity level
  Widget _getMoodWidget(int severity, bool isSelected) {
    String emoji;
    String moodText;
    Color moodColor;

    switch (severity) {
      case 1:
        emoji = '😊';
        moodText = 'Senang';
        moodColor = Colors.orange;
        break;
      case 2:
        emoji = '🙂';
        moodText = 'Biasa';
        moodColor = Colors.lightGreen;
        break;
      case 3:
        emoji = '😔';
        moodText = 'Galau';
        moodColor = Colors.purpleAccent;
        break;
      case 4:
        emoji = '😢';
        moodText = 'Sedih';
        moodColor = Colors.blue;
        break;
      case 5:
        emoji = '😠';
        moodText = 'Marah';
        moodColor = Colors.red;
        break;
      default:
        emoji = '❓';
        moodText = 'Tidak Diketahui';
        moodColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? moodColor.withOpacity(0.2) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: moodColor, width: 2)
            : Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            moodText,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? moodColor : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catat Gejala Hari Ini',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[800],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Symptoms selection
            Text(
              'Pilih Gejala:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.pink[700],
              ),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.pink))
            else if (symptoms.isEmpty)
              const Text('Tidak ada gejala tersedia')
            else
              Column(
                children: [
                  // First row of symptoms
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: symptoms
                          .sublist(0, (symptoms.length / 2).ceil())
                          .map((symptom) {
                            final isSelected = _selectedSymptoms.any(
                              (s) => s['symptom_id'] == symptom.id,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        : const SizedBox.shrink(),
                                    Icon(
                                      _getSymptomIcon(symptom.id),
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : _getSymptomColor(symptom.id),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      symptom.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : _getSymptomColor(symptom.id),
                                      ),
                                    ),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) =>
                                    _toggleSymptom(symptom, selected),
                                selectedColor: _getSymptomColor(symptom.id),
                                backgroundColor: _getSymptomColor(
                                  symptom.id,
                                ).withOpacity(0.1),
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                  // Second row of symptoms
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: symptoms
                          .sublist((symptoms.length / 2).ceil())
                          .map((symptom) {
                            final isSelected = _selectedSymptoms.any(
                              (s) => s['symptom_id'] == symptom.id,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        : const SizedBox.shrink(),
                                    Icon(
                                      _getSymptomIcon(symptom.id),
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : _getSymptomColor(symptom.id),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      symptom.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : _getSymptomColor(symptom.id),
                                      ),
                                    ),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) =>
                                    _toggleSymptom(symptom, selected),
                                selectedColor: _getSymptomColor(symptom.id),
                                backgroundColor: _getSymptomColor(
                                  symptom.id,
                                ).withOpacity(0.1),
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),

            // Dismenorea severity selector
            if (_selectedSymptoms.any((s) => s['symptom_id'] == 4)) ...[
              const SizedBox(height: 20),
              Text(
                'Tingkat Mood:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.pink[700],
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [1, 2, 3, 4, 5].map((severity) {
                    final isSelected = _dismenoreaSeverity == severity;
                    return GestureDetector(
                      onTap: () => _updateDismenoreaSeverity(severity),
                      child: Container(
                        width: 70,
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _getMoodWidget(severity, isSelected),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Keterangan: 1 (Ringan) - 5 (Berat)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Notes field
            const SizedBox(height: 20),
            CustomFormField(
              label: 'Catatan',
              placeholder: 'Masukkan catatan (opsional)',
              controller: _notesController,
              isMandatory: false,
              type: CustomFormFieldType.text,
              prefixIcon: Icons.note,
            ),

            // Submit button
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Simpan Gejala',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
