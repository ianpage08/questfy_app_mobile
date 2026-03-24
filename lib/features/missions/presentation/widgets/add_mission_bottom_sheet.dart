import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:questfy_app_mobile/features/missions/data/models/mission.dart';
import 'package:intl/intl.dart'; // Recomendo adicionar 'intl' no pubspec para formatar datas
import '../../../../core/theme/app.colors.dart';
import '../../data/providers/mission_provider.dart';

class AddMissionBottomSheet extends StatefulWidget {
  const AddMissionBottomSheet({super.key});

  @override
  State<AddMissionBottomSheet> createState() => _AddMissionBottomSheetState();
}

class _AddMissionBottomSheetState extends State<AddMissionBottomSheet> {
  String _selectedEmoji = '🚀';
  final List<String> _emojis = [
    '🚀',
    '🎯',
    '📚',
    '💪',
    '💧',
    '🥗',
    '🧠',
    '💰',
    '🏠',
  ];
  final _titleController = TextEditingController();
  MissionType _selectedType = MissionType.infinite;
  DateTime? _selectedDeadline;

  // Função para abrir o seletor de data
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Nova Missão",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedType == MissionType.challenge)
                Text(
                  "Especial",
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Título
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: "O que você vai fazer?",
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ícones
          const Text(
            "Escolha um ícone",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _emojis.length,
              itemBuilder: (context, index) {
                final emoji = _emojis[index];
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedEmoji = emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Tipos
          const Text(
            "Frequência / Tipo",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MissionType.values.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      type.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    selected: isSelected,
                    onSelected: (val) => setState(() {
                      _selectedType = type;
                      if (type != MissionType.challenge)
                        _selectedDeadline = null;
                    }),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Seletor de Data para DESAFIO
          if (_selectedType == MissionType.challenge) ...[
            const SizedBox(height: 20),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDeadline == null
                        ? AppColors.cardBorder
                        : AppColors.accent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDeadline == null
                          ? "Definir data final"
                          : "Até: ${DateFormat('dd/MM/yyyy').format(_selectedDeadline!)}",
                      style: TextStyle(
                        color: _selectedDeadline == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: _selectedDeadline == null
                          ? AppColors.textSecondary
                          : AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // Botão Criar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final title = _titleController.text.trim();

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Dê um título para sua missão!"),
                    ),
                  );
                  return;
                }

                if (_selectedType == MissionType.challenge &&
                    _selectedDeadline == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Escolha uma data para o desafio!"),
                    ),
                  );
                  return;
                }

                context.read<MissionProvider>().addMission(
                  title: title,
                  icon: _selectedEmoji,
                  type: _selectedType,
                  xp: _selectedType == MissionType.challenge ? 50 : 10,
                  deadline: _selectedDeadline, // Importante enviar o prazo
                );

                HapticFeedback.heavyImpact();
                Navigator.pop(context);
              },
              child: const Text(
                "Criar Missão",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
