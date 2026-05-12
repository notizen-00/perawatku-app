import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/doctor_entity.dart';
import '../controllers/doctor_controller.dart';
import '../models/doctor_chat_arguments.dart';

enum _DoctorPriceSort { lowest, highest }

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final DoctorController controller = Get.find<DoctorController>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  _DoctorPriceSort _selectedSort = _DoctorPriceSort.lowest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokter')),
      body: Obx(() {
        if (controller.isLoading.value && controller.doctors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.doctors.isEmpty) {
          return _DoctorStateMessage(
            title: 'Dokter belum bisa dimuat',
            description: controller.errorMessage.value!,
            actionLabel: 'Coba lagi',
            onTap: controller.loadDoctors,
          );
        }

        if (controller.doctors.isEmpty) {
          return const _DoctorStateMessage(
            title: 'Belum ada dokter',
            description: 'Daftar dokter akan muncul di halaman ini.',
          );
        }

        final filteredDoctors = _buildFilteredDoctors(controller.doctors);

        return RefreshIndicator(
          onRefresh: () => controller.loadDoctors(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DoctorSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _DoctorPriceFilter(
                selectedSort: _selectedSort,
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (filteredDoctors.isEmpty)
                const _DoctorStateMessage(
                  title: 'Dokter tidak ditemukan',
                  description:
                      'Coba ubah kata kunci pencarian atau filter harga.',
                )
              else
                ...List.generate(
                  filteredDoctors.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == filteredDoctors.length - 1 ? 0 : 12,
                    ),
                    child: _DoctorCard(doctor: filteredDoctors[index]),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  List<DoctorEntity> _buildFilteredDoctors(List<DoctorEntity> doctors) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = doctors.where((doctor) {
      final specialization = doctor.profile?.specialization ?? '';
      final doctorName = doctor.name.toLowerCase();
      final specializationName = specialization.toLowerCase();

      return query.isEmpty ||
          doctorName.contains(query) ||
          specializationName.contains(query);
    }).toList();

    filtered.sort((a, b) {
      final aFee = _parseConsultationFee(a.profile?.consultationFee);
      final bFee = _parseConsultationFee(b.profile?.consultationFee);

      if (_selectedSort == _DoctorPriceSort.lowest) {
        return aFee.compareTo(bFee);
      }

      return bFee.compareTo(aFee);
    });

    return filtered;
  }

  int _parseConsultationFee(String? rawFee) {
    if (rawFee == null || rawFee.trim().isEmpty) {
      return 0;
    }

    final digitsOnly = rawFee.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }
}

class _DoctorSearchBar extends StatelessWidget {
  const _DoctorSearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari nama atau spesialis dokter',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: isDark ? const Color(0xFF12211F) : AppColors.softWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
    );
  }
}

class _DoctorPriceFilter extends StatelessWidget {
  const _DoctorPriceFilter({
    required this.selectedSort,
    required this.onChanged,
  });

  final _DoctorPriceSort selectedSort;
  final ValueChanged<_DoctorPriceSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _FilterChipButton(
          label: 'Termurah',
          selected: selectedSort == _DoctorPriceSort.lowest,
          onTap: () => onChanged(_DoctorPriceSort.lowest),
        ),
        _FilterChipButton(
          label: 'Termahal',
          selected: selectedSort == _DoctorPriceSort.highest,
          onTap: () => onChanged(_DoctorPriceSort.highest),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFFFF0B8),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF8A6200) : AppColors.lightText,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected ? const Color(0xFFFACC15) : AppColors.lightBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = doctor.profile;
    final photoUrl = _resolvePhotoUrl(profile?.photoUrl);
    final specialization = (profile?.specialization ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE7E1D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 72,
              height: 72,
              child: photoUrl == null
                  ? Container(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      alignment: Alignment.center,
                      child: const Icon(Icons.person_rounded, size: 34),
                    )
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person_rounded, size: 34),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (specialization.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SpecializationBadge(label: specialization),
                ],
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatRupiahFromString(
                    profile!.consultationFee.toString(),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.doctorConsultation,
                          arguments: DoctorChatArguments(
                            doctor: doctor,
                            doctorName: doctor.name,
                            specialization: specialization.isEmpty
                                ? null
                                : specialization,
                            partnerUserId: profile?.userId ?? doctor.id,
                            doctorPhotoUrl: profile?.photoUrl,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFACC15),
                        foregroundColor: const Color(0xFF3B2F00),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Chat',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _resolvePhotoUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) {
      return null;
    }

    if (uri.hasScheme) {
      return uri.toString();
    }

    final normalizedPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '${AppConfig.baseUrl}$normalizedPath';
  }
}

class _SpecializationBadge extends StatelessWidget {
  const _SpecializationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DoctorStateMessage extends StatelessWidget {
  const _DoctorStateMessage({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onTap, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
