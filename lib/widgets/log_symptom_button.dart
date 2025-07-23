import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_post_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_get_detail.dart';
import 'package:srikandi_sehat_app/screens/user/symptom_detail_screen.dart';
import 'package:srikandi_sehat_app/widgets/action_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';

class LogSymptomButton extends StatelessWidget {
  const LogSymptomButton({super.key});

  Future<void> _submitLogSymptom({
    required BuildContext context,
    required List<String> selectedSymptoms,
    required int? selectedMood,
    required String notes,
  }) async {
    final symptomLogProvider =
        Provider.of<SymptomLogProvider>(context, listen: false);

    // Client-side validation
    if (selectedSymptoms.isEmpty) {
      CustomAlert.show(
        context,
        'Silakan pilih minimal satu gejala.',
        type: AlertType.warning,
      );
      return;
    }

    if (selectedSymptoms.contains('Mood Swing') && selectedMood == null) {
      CustomAlert.show(
        context,
        'Silakan pilih mood untuk gejala Mood Swing.',
        type: AlertType.warning,
      );
      return;
    }

    try {
      final result = await symptomLogProvider.logSymptoms(
        symptoms: selectedSymptoms,
        moodScore:
            selectedSymptoms.contains('Mood Swing') ? selectedMood : null,
        notes: notes.trim().isNotEmpty ? notes.trim() : null,
        logDate: DateTime.now().toIso8601String().split('T').first,
      );

      if (!context.mounted) return;

      // Close the bottom sheet
      Navigator.pop(context);

      if (result.success) {
        // Show success message
        CustomAlert.show(
          context,
          result.message ?? 'Gejala berhasil dicatat!',
          type: AlertType.success,
        );

        await Future.delayed(const Duration(milliseconds: 1500));

        if (context.mounted) {
          if (result.id != null) {
            // Clear any previous state in the detail provider
            final detailProvider = Provider.of<SymptomDetailProvider>(
              context,
              listen: false,
            );
            detailProvider.clear();

            // Navigate to detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: detailProvider,
                  child: SymptomDetailScreen(symptomId: result.id!),
                ),
              ),
            );
          } else {
            Navigator.pushNamed(context, '/symptom-history');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        CustomAlert.show(
          context,
          'Terjadi kesalahan tidak terduga. Silakan coba lagi.',
          type: AlertType.error,
        );
      }
    }
  }

  IconData _getSymptomIcon(String symptomName) {
    final lower = symptomName.toLowerCase();
    if (lower.contains('dismenorea')) return Icons.healing;
    if (lower.contains('mood')) return Icons.mood;
    if (lower.contains('5l')) return Icons.water_drop;
    if (lower.contains('kram')) return Icons.sick;
    if (lower.contains('mual')) return Icons.sick_outlined;
    if (lower.contains('pusing')) return Icons.blur_on;
    return Icons.medical_services;
  }

  Color _getSymptomColor(String symptomName) {
    final lower = symptomName.toLowerCase();
    if (lower.contains('dismenorea')) return Colors.pink;
    if (lower.contains('mood')) return Colors.purple;
    if (lower.contains('5l')) return Colors.blue;
    if (lower.contains('kram')) return Colors.orange;
    return Colors.pink;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomProvider>(
      builder: (context, symptomProvider, _) {
        // Create a non-nullable callback
        VoidCallback? onPressed;
        if (!symptomProvider.isLoading) {
          onPressed = () async {
            if (symptomProvider.symptoms.isEmpty) {
              await context.read<SymptomProvider>().fetchSymptoms();
            }
            if (context.mounted) {
              _showLogSymptomsBottomSheet(context);
            }
          };
        }

        return ActionButton(
          icon: Icons.edit_note,
          label: 'Gejala',
          color: Colors.teal,
          isActive: !symptomProvider.isLoading,
          onPressed: onPressed ?? () {}, // Provide empty callback when null
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

  Future<void> _showLogSymptomsBottomSheet(BuildContext context) async {
    final symptomProvider =
        Provider.of<SymptomProvider>(context, listen: false);
    final symptomLogProvider =
        Provider.of<SymptomLogProvider>(context, listen: false);

    // Clear any previous errors
    symptomLogProvider.clearError();

    // Fallback: fetch data if empty and not loading
    if (symptomProvider.symptoms.isEmpty && !symptomProvider.isLoading) {
      await symptomProvider.fetchSymptoms();
    }

    final symptoms = symptomProvider.symptoms;
    final TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext bc) {
        return _SymptomLogBottomSheet(
          symptoms: symptoms,
          notesController: notesController,
          onSubmit: _submitLogSymptom,
          getSymptomIcon: _getSymptomIcon,
          getSymptomColor: _getSymptomColor,
        );
      },
    );
  }
}

// Separate widget for the bottom sheet to improve maintainability
class _SymptomLogBottomSheet extends StatefulWidget {
  final List symptoms;
  final TextEditingController notesController;
  final Function({
    required BuildContext context,
    required List<String> selectedSymptoms,
    required int? selectedMood,
    required String notes,
  }) onSubmit;
  final IconData Function(String) getSymptomIcon;
  final Color Function(String) getSymptomColor;

  const _SymptomLogBottomSheet({
    required this.symptoms,
    required this.notesController,
    required this.onSubmit,
    required this.getSymptomIcon,
    required this.getSymptomColor,
  });

  @override
  State<_SymptomLogBottomSheet> createState() => _SymptomLogBottomSheetState();
}

class _SymptomLogBottomSheetState extends State<_SymptomLogBottomSheet> {
  List<String> selectedSymptoms = [];
  int? selectedMood;

  bool get isMoodSwingSelected => selectedSymptoms.contains('Mood Swing');
  bool get canSubmit =>
      selectedSymptoms.isNotEmpty &&
      (!isMoodSwingSelected || selectedMood != null);

  @override
  void dispose() {
    widget.notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomLogProvider>(
      builder: (context, provider, _) {
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
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildSymptomSelection(),
                if (isMoodSwingSelected) ...[
                  const SizedBox(height: 20),
                  _buildMoodSelection(),
                ],
                const SizedBox(height: 20),
                _buildNotesField(),
                const SizedBox(height: 16),
                _buildSubmitButton(provider),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Catat Gejala Hari Ini',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildSymptomSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Gejala:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        if (widget.symptoms.isEmpty)
          _buildEmptyState()
        else
          _buildSymptomChips(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Tidak ada data gejala'),
      ),
    );
  }

  Widget _buildSymptomChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.symptoms.map((symptom) {
        final isSelected = selectedSymptoms.contains(symptom.name);
        final symptomColor = widget.getSymptomColor(symptom.name);

        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.getSymptomIcon(symptom.name),
                size: 18,
                color: isSelected ? Colors.white : symptomColor,
              ),
              const SizedBox(width: 6),
              Text(
                symptom.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : symptomColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedSymptoms.add(symptom.name);
              } else {
                selectedSymptoms.remove(symptom.name);
                // Reset mood if Mood Swing is deselected
                if (symptom.name == 'Mood Swing') {
                  selectedMood = null;
                }
              }
            });
          },
          selectedColor: symptomColor,
          checkmarkColor: Colors.white,
          backgroundColor: symptomColor.withOpacity(0.1),
          side: BorderSide(
            color: isSelected ? symptomColor : symptomColor.withOpacity(0.3),
            width: 1.5,
          ),
          showCheckmark: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        );
      }).toList(),
    );
  }

  Widget _buildMoodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Mood (1–4): *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMoodOption(
                1, 'Marah', Icons.sentiment_very_dissatisfied, Colors.red),
            _buildMoodOption(
                2, 'Sedih', Icons.sentiment_dissatisfied, Colors.blueGrey),
            _buildMoodOption(3, 'Biasa', Icons.sentiment_neutral, Colors.grey),
            _buildMoodOption(
                4, 'Senang', Icons.sentiment_satisfied_alt, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodOption(int value, String label, IconData icon, Color color) {
    final isSelected = value == selectedMood;
    return GestureDetector(
      onTap: () => setState(() => selectedMood = value),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: color, width: 2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? color : color.withOpacity(0.4),
            ),
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
      ),
    );
  }

  Widget _buildNotesField() {
    return CustomFormField(
      placeholder: 'Masukkan keluhan anda (opsional)',
      label: 'Catatan',
      isMandatory: false,
      type: CustomFormFieldType.text,
      controller: widget.notesController,
    );
  }

  Widget _buildSubmitButton(SymptomLogProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (canSubmit && !provider.isLoading)
            ? () => widget.onSubmit(
                  context: context,
                  selectedSymptoms: selectedSymptoms,
                  selectedMood: selectedMood,
                  notes: widget.notesController.text,
                )
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? Colors.pink : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Simpan Log',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
    );
  }
}
