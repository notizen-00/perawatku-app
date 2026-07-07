import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/patient_member_entity.dart';
import '../controllers/patient_member_controller.dart';

class PatientMemberPage extends StatelessWidget {
  const PatientMemberPage({super.key});

  static const List<String> relationships = <String>[
    '',
    'self',
    'suami',
    'istri',
    'anak',
    'kakek',
    'nenek',
  ];

  PatientMemberController get controller => Get.find<PatientMemberController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Profil Pasien Keluarga'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.lightText,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadMembers,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => controller.loadMembers(),
              decoration: InputDecoration(
                hintText: 'Cari nama, hubungan, telepon, alamat',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: controller.loadMembers,
                  icon: const Icon(Icons.tune_rounded),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: relationships.map((relationship) {
                    final selected =
                        controller.selectedRelationship.value == relationship;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: selected,
                        label: Text(relationship.isEmpty ? 'Semua' : relationship),
                        onSelected: (_) =>
                            controller.applyRelationshipFilter(relationship),
                        selectedColor: AppColors.primary.withValues(alpha: 0.16),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.lightText,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : const Color(0xFFE5EAF0),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final error = controller.errorMessage.value;
              if (error != null && error.isNotEmpty) {
                return _EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Belum bisa memuat data',
                  subtitle: error,
                  actionLabel: 'Coba lagi',
                  onAction: controller.loadMembers,
                );
              }

              if (controller.members.isEmpty) {
                return _EmptyState(
                  icon: Icons.group_add_rounded,
                  title: 'Belum ada profil pasien',
                  subtitle:
                      'Tambahkan profil untuk diri sendiri, pasangan, anak, atau keluarga lain.',
                  actionLabel: 'Tambah profil',
                  onAction: () => _openForm(context),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.members.length} profil tersimpan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...controller.members.map(
                    (member) => _MemberCard(
                      member: member,
                      onEdit: () => _openForm(context, member: member),
                      onPrimary: () => controller.setPrimary(member),
                      onDelete: () => _confirmDelete(context, member),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {PatientMemberEntity? member}) {
    if (member == null) {
      controller.startCreate();
    } else {
      controller.startEdit(member);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MemberForm(controller: controller),
    );
  }

  void _confirmDelete(BuildContext context, PatientMemberEntity member) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Hapus profil?'),
        content: Text('Profil ${member.name} akan dihapus dari akun pasien.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Get.back<void>();
              await controller.deleteMember(member);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.onEdit,
    required this.onPrimary,
    required this.onDelete,
  });

  final PatientMemberEntity member;
  final VoidCallback onEdit;
  final VoidCallback onPrimary;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      if (member.relationship.isNotEmpty) member.relationship,
      if (member.age != null) '${member.age} tahun',
      if (member.gender.isNotEmpty) member.gender,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.13),
                child: Text(
                  member.name.isEmpty ? 'P' : member.name[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (member.isPrimary)
                          const _Badge(label: 'Utama', color: AppColors.success),
                      ],
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.lightMutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'primary') onPrimary();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!member.isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Text('Jadikan utama'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
          if (member.phone.isNotEmpty || member.bloodType.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (member.phone.isNotEmpty)
                  _InfoPill(icon: Icons.call_rounded, label: member.phone),
                if (member.bloodType.isNotEmpty)
                  _InfoPill(
                    icon: Icons.bloodtype_rounded,
                    label: 'Gol. ${member.bloodType}',
                  ),
              ],
            ),
          ],
          if (member.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              member.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.lightMutedText),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberForm extends StatelessWidget {
  const _MemberForm({required this.controller});

  final PatientMemberController controller;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DEE7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                controller.editingMember.value == null
                    ? 'Tambah Profil Pasien'
                    : 'Edit Profil Pasien',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              _Field(controller: controller.nameController, label: 'Nama *'),
              _Field(controller: controller.relationshipController, label: 'Hubungan'),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: controller.dateOfBirthController,
                      label: 'Tanggal lahir',
                      hint: 'YYYY-MM-DD',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      controller: controller.ageController,
                      label: 'Umur',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _Field(
                controller: controller.genderController,
                label: 'Jenis kelamin',
                hint: 'laki-laki / perempuan',
              ),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: controller.phoneController,
                      label: 'Telepon',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      controller: controller.bloodTypeController,
                      label: 'Golongan darah',
                    ),
                  ),
                ],
              ),
              _Field(
                controller: controller.emergencyContactNameController,
                label: 'Nama kontak darurat',
              ),
              _Field(
                controller: controller.emergencyContactPhoneController,
                label: 'Telepon kontak darurat',
                keyboardType: TextInputType.phone,
              ),
              _Field(controller: controller.allergiesController, label: 'Alergi'),
              _Field(
                controller: controller.medicalNotesController,
                label: 'Catatan medis',
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              const Text(
                'Alamat layanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              _Field(controller: controller.addressLabelController, label: 'Label alamat'),
              _Field(controller: controller.recipientNameController, label: 'Nama penerima'),
              _Field(
                controller: controller.recipientPhoneController,
                label: 'Telepon penerima',
                keyboardType: TextInputType.phone,
              ),
              _Field(
                controller: controller.addressController,
                label: 'Alamat lengkap',
                maxLines: 3,
              ),
              _Field(controller: controller.provinceController, label: 'Provinsi'),
              Row(
                children: [
                  Expanded(child: _Field(controller: controller.cityController, label: 'Kota')),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(controller: controller.districtController, label: 'Kecamatan')),
                ],
              ),
              _Field(controller: controller.postalCodeController, label: 'Kode pos'),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: controller.latitudeController,
                      label: 'Latitude',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      controller: controller.longitudeController,
                      label: 'Longitude',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Obx(
                () => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: controller.isPrimaryForm.value,
                  onChanged: (value) => controller.isPrimaryForm.value = value,
                  title: const Text(
                    'Jadikan profil utama',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => FilledButton.icon(
                  onPressed: controller.isSaving.value
                      ? null
                      : () async {
                          final saved = await controller.saveMember();
                          if (saved) Get.back<void>();
                        },
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(controller.isSaving.value ? 'Menyimpan...' : 'Simpan'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F4),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Icon(icon, size: 54, color: AppColors.primary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.lightMutedText),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
