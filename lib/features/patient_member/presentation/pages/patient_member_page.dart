import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/helpers/app_snackbar.dart';
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
              const _SectionTitle(
                title: 'Data utama',
                subtitle: 'Nama wajib diisi. Data lain boleh dikosongkan.',
              ),
              _Field(
                controller: controller.nameController,
                label: 'Nama pasien',
                required: true,
              ),
              _DropdownField(
                controller: controller.relationshipController,
                label: 'Hubungan',
                options: const <String>[
                  'self',
                  'suami',
                  'istri',
                  'anak',
                  'kakek',
                  'nenek',
                ],
                onChanged: controller.setRelationship,
              ),
              Row(
                children: [
                  Expanded(child: _DateField(controller: controller)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      controller: controller.ageController,
                      label: 'Umur',
                      optional: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _DropdownField(
                controller: controller.genderController,
                label: 'Jenis kelamin',
                options: const <String>['laki-laki', 'perempuan'],
                onChanged: controller.setGender,
              ),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: controller.phoneController,
                      label: 'Telepon',
                      optional: true,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      controller: controller.bloodTypeController,
                      label: 'Golongan darah',
                      optional: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _SectionTitle(
                title: 'Alamat layanan',
                subtitle:
                    'Alamat lengkap dan titik peta wajib diisi agar mitra datang ke lokasi yang tepat.',
              ),
              const SizedBox(height: 10),
              _Field(
                controller: controller.addressLabelController,
                label: 'Label alamat',
                optional: true,
                hint: 'Rumah, Kos, Rumah Kakek',
              ),
              _Field(
                controller: controller.addressController,
                label: 'Alamat lengkap',
                required: true,
                maxLines: 3,
              ),
              _AreaPickerSection(controller: controller),
              _Field(
                controller: controller.postalCodeController,
                label: 'Kode pos',
                optional: true,
              ),
              _MapCoordinateField(controller: controller),
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: const Text(
                  'Data opsional lainnya',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'Kontak darurat, alergi, catatan medis, dan penerima.',
                ),
                children: [
                  _Field(
                    controller: controller.emergencyContactNameController,
                    label: 'Nama kontak darurat',
                    optional: true,
                  ),
                  _Field(
                    controller: controller.emergencyContactPhoneController,
                    label: 'Telepon kontak darurat',
                    optional: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _Field(
                    controller: controller.allergiesController,
                    label: 'Alergi',
                    optional: true,
                  ),
                  _Field(
                    controller: controller.medicalNotesController,
                    label: 'Catatan medis',
                    optional: true,
                    maxLines: 3,
                  ),
                  _Field(
                    controller: controller.recipientNameController,
                    label: 'Nama penerima',
                    optional: true,
                  ),
                  _Field(
                    controller: controller.recipientPhoneController,
                    label: 'Telepon penerima',
                    optional: true,
                    keyboardType: TextInputType.phone,
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
                          final isCreating = controller.editingMember.value == null;
                          final saved = await controller.saveMember();
                          if (!saved) {
                            return;
                          }

                          Get.back<void>();
                          Future<void>.delayed(
                            const Duration(milliseconds: 180),
                            () => AppSnackbar.success(
                              isCreating
                                  ? 'Profil ditambahkan'
                                  : 'Profil diperbarui',
                              'Data pasien keluarga sudah tersimpan.',
                            ),
                          );
                        },
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    controller.isSaving.value ? 'Menyimpan...' : 'Simpan',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.lightMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    this.required = false,
    this.optional = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(
          label: label,
          hint: hint,
          required: required,
          optional: optional,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.controller});

  final PatientMemberController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller.dateOfBirthController,
        readOnly: true,
        onTap: () async {
          final now = DateTime.now();
          final current = DateTime.tryParse(controller.dateOfBirthController.text);
          final selected = await showDatePicker(
            context: context,
            initialDate: current ?? DateTime(now.year - 25, now.month, now.day),
            firstDate: DateTime(now.year - 150),
            lastDate: now,
          );
          if (selected != null) {
            controller.setDateOfBirth(selected);
          }
        },
        decoration: _inputDecoration(
          label: 'Tanggal lahir',
          hint: 'YYYY-MM-DD',
          optional: true,
        ).copyWith(
          suffixIcon: const Icon(Icons.calendar_month_rounded),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.controller,
    required this.label,
    required this.options,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final selected = options.contains(value.text) ? value.text : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: selected,
            isExpanded: true,
            decoration: _inputDecoration(label: label, optional: true),
            items: options
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}

class _AreaPickerSection extends StatelessWidget {
  const _AreaPickerSection({required this.controller});

  final PatientMemberController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          _AreaDropdownField(
            label: 'Provinsi',
            value: controller.selectedProvince.value,
            items: controller.provinces,
            isLoading: controller.isLoadingProvinces.value,
            onRefresh: controller.loadProvinces,
            onChanged: controller.selectProvince,
          ),
          Row(
            children: [
              Expanded(
                child: _AreaDropdownField(
                  label: 'Kota/Kabupaten',
                  value: controller.selectedRegency.value,
                  items: controller.regencies,
                  isLoading: controller.isLoadingRegencies.value,
                  enabled: controller.selectedProvince.value != null,
                  emptyHint: 'Pilih provinsi dulu',
                  onChanged: controller.selectRegency,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AreaDropdownField(
                  label: 'Kecamatan',
                  value: controller.selectedDistrict.value,
                  items: controller.districts,
                  isLoading: controller.isLoadingDistricts.value,
                  enabled: controller.selectedRegency.value != null,
                  emptyHint: 'Pilih kota dulu',
                  onChanged: controller.selectDistrict,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaDropdownField extends StatelessWidget {
  const _AreaDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
    this.enabled = true,
    this.emptyHint,
    this.onRefresh,
  });

  final String label;
  final IndonesiaAreaOption? value;
  final List<IndonesiaAreaOption> items;
  final ValueChanged<IndonesiaAreaOption?> onChanged;
  final bool isLoading;
  final bool enabled;
  final String? emptyHint;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final selected = items.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<IndonesiaAreaOption>(
        value: selected,
        isExpanded: true,
        decoration: _inputDecoration(
          label: label,
          required: true,
          hint: emptyHint,
        ).copyWith(
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : onRefresh == null
              ? null
              : IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<IndonesiaAreaOption>(
                value: item,
                child: Text(item.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: enabled && !isLoading ? onChanged : null,
      ),
    );
  }
}

class _MapCoordinateField extends StatelessWidget {
  const _MapCoordinateField({required this.controller});

  final PatientMemberController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.latitudeController,
      builder: (context, latitudeValue, _) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.longitudeController,
          builder: (context, longitudeValue, _) {
            final label = latitudeValue.text.trim().isEmpty ||
                    longitudeValue.text.trim().isEmpty
                ? 'Belum ada titik peta'
                : '${latitudeValue.text}, ${longitudeValue.text}';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Titik peta *',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.lightMutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openLocationPicker(context),
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Pilih'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openLocationPicker(BuildContext context) {
    final latitude = double.tryParse(controller.latitudeController.text);
    final longitude = double.tryParse(controller.longitudeController.text);
    final initial = latitude != null && longitude != null
        ? LatLng(latitude, longitude)
        : const LatLng(-8.1724, 113.7007);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LocationPickerSheet(
        initialLocation: initial,
        onSelected: (point) {
          controller.setCoordinates(
            latitude: point.latitude,
            longitude: point.longitude,
          );
        },
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({
    required this.initialLocation,
    required this.onSelected,
  });

  final LatLng initialLocation;
  final ValueChanged<LatLng> onSelected;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late LatLng selectedLocation = widget.initialLocation;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.76;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8DEE7),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih titik lokasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap area peta untuk menggeser marker.',
                        style: TextStyle(color: AppColors.lightMutedText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: selectedLocation,
                initialZoom: 15,
                onTap: (_, point) {
                  setState(() => selectedLocation = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.medic.patient.app',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 48,
                      height: 48,
                      point: selectedLocation,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.error,
                        size: 46,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${selectedLocation.latitude.toStringAsFixed(6)}, '
                    '${selectedLocation.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    widget.onSelected(selectedLocation);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Pakai titik ini'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  String? hint,
  bool required = false,
  bool optional = false,
}) {
  return InputDecoration(
    labelText: required
        ? '$label *'
        : optional
            ? '$label (opsional)'
            : label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF7F9FC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
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
