import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../patient_member/domain/entities/patient_member_entity.dart';
import '../controllers/service_booking_controller.dart';

class ServiceBookingPatientPickerPage extends StatefulWidget {
  const ServiceBookingPatientPickerPage({super.key});

  @override
  State<ServiceBookingPatientPickerPage> createState() =>
      _ServiceBookingPatientPickerPageState();
}

class _ServiceBookingPatientPickerPageState
    extends State<ServiceBookingPatientPickerPage> {
  late final ServiceBookingController controller;
  PatientMemberEntity? selectedMember;
  bool isApplying = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ServiceBookingController>();
    selectedMember = controller.selectedPatientMember.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.patientMembers.isEmpty) {
        controller.loadPatientMembers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF8FAFD);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor =
        isDark ? AppColors.darkMutedText : AppColors.lightMutedText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        centerTitle: false,
        title: const Text(
          'Pilih Pasien',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadPatientMembers,
              child: Obx(() {
                if (controller.isLoadingMembers.value &&
                    controller.patientMembers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final error = controller.memberErrorMessage.value;
                if (error != null && controller.patientMembers.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 96),
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 52,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mutedColor),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: controller.loadPatientMembers,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  );
                }

                final members = controller.patientMembers.toList();
                final effectiveSelected = _effectiveSelectedMember;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    Text(
                      'Siapa yang akan berobat?',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih profil pasien yang membutuhkan layanan kesehatan saat ini.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 14.5,
                        height: 1.42,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (members.isEmpty)
                      _EmptyPatientState(onAdd: _openPatientMemberPage)
                    else ...[
                      ...members.map(
                        (member) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PatientChoiceCard(
                            member: member,
                            selected: effectiveSelected?.id == member.id,
                            onTap: () {
                              setState(() => selectedMember = member);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AddFamilyButton(onPressed: _openPatientMemberPage),
                    ],
                  ],
                );
              }),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed:
                      _effectiveSelectedMember == null || isApplying
                          ? null
                          : _apply,
                  child: isApplying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Lanjut',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _apply() async {
    final member = _effectiveSelectedMember;
    if (member == null) {
      return;
    }

    setState(() => isApplying = true);
    await controller.selectPatientMember(member);
    if (mounted) {
      setState(() => isApplying = false);
    }
    Get.back<void>();
  }

  Future<void> _openPatientMemberPage() async {
    await Get.toNamed(AppRoutes.patientMembers);
    await controller.loadPatientMembers();
    if (!mounted) {
      return;
    }

    final selectedId = selectedMember?.id;
    if (selectedId == null) {
      return;
    }

    for (final member in controller.patientMembers) {
      if (member.id == selectedId) {
        setState(() => selectedMember = member);
        return;
      }
    }
  }

  PatientMemberEntity? get _effectiveSelectedMember =>
      selectedMember ?? controller.selectedPatientMember.value;
}

class _PatientChoiceCard extends StatelessWidget {
  const _PatientChoiceCard({
    required this.member,
    required this.selected,
    required this.onTap,
  });

  final PatientMemberEntity member;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasLocation = member.latitude != null && member.longitude != null;
    final borderColor = selected ? AppColors.primary : AppColors.lightBorder;
    final relationship = _relationshipLabel(member.relationship);
    final subtitle = member.isPrimary ? 'Diri Sendiri' : 'Keluarga';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                _initials(member.name),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RelationshipBadge(
                        label: member.isPrimary ? 'Utama' : relationship,
                        isPrimary: member.isPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (member.address.trim().isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.lightMutedText,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _address(member),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.lightText,
                              fontSize: 12.5,
                              height: 1.28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!hasLocation) ...[
                    const SizedBox(height: 8),
                    const _IncompleteAddressWarning(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: selected ? 1 : 0,
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _relationshipLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'self') {
      return 'Utama';
    }

    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'P';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _address(PatientMemberEntity member) {
    final parts = <String>[
      member.address,
      member.city,
      if (member.postalCode.trim().isNotEmpty) '(${member.postalCode})',
    ]
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.join(', ');
  }
}

class _RelationshipBadge extends StatelessWidget {
  const _RelationshipBadge({
    required this.label,
    required this.isPrimary,
  });

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.success.withValues(alpha: 0.22)
            : const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? const Color(0xFF087D55) : AppColors.lightText,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IncompleteAddressWarning extends StatelessWidget {
  const _IncompleteAddressWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Alamat Tidak Lengkap\nKoordinat peta belum ditentukan.',
              style: TextStyle(
                color: Color(0xFFB42318),
                fontSize: 12,
                height: 1.32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFamilyButton extends StatelessWidget {
  const _AddFamilyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC3CAD8),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            SizedBox(height: 8),
            Text(
              'Tambah Anggota Keluarga',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPatientState extends StatelessWidget {
  const _EmptyPatientState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(
          Icons.group_add_rounded,
          color: AppColors.primary,
          size: 54,
        ),
        const SizedBox(height: 12),
        const Text(
          'Belum ada profil pasien',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tambahkan profil keluarga dulu untuk melanjutkan pesanan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.lightMutedText),
        ),
        const SizedBox(height: 18),
        _AddFamilyButton(onPressed: onAdd),
      ],
    );
  }
}
