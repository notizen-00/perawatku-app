import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/account_controller.dart';

class AccountPage extends StatelessWidget {
  AccountPage({super.key});

  final AccountController controller = Get.isRegistered<AccountController>()
      ? Get.find<AccountController>()
      : Get.put(AccountController(Get.find<StorageService>()));

  static const List<String> _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _formatDate(String? raw, {bool withTime = false}) {
    if (raw == null || raw.isEmpty) {
      return '-';
    }

    try {
      final dateTime = DateTime.parse(raw).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _monthNames[dateTime.month];
      final year = dateTime.year.toString();

      if (!withTime) {
        return '$day $month $year';
      }

      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute';
    } catch (_) {
      return raw;
    }
  }

  String _initialsOf(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'PS';
    }

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'PS';
    }

    return parts.map((part) => part[0].toUpperCase()).join();
  }

  String _emailStatusText(String? verifiedAt) {
    return verifiedAt == null || verifiedAt.isEmpty
        ? 'Email belum diverifikasi'
        : 'Email terverifikasi';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : const Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Obx(
          () {
            final user = controller.user.value;
            final patient = user?.patientProfile;
            final emailVerified =
                user?.emailVerifiedAt != null && user!.emailVerifiedAt!.isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AccountHero(
                    isDark: isDark,
                    title: 'Profil Kesehatan',
                    subtitle:
                        'Kelola identitas pasien, keamanan akun, dan ringkasan informasi medis Anda.',
                  ),
                  Transform.translate(
                    offset: const Offset(0, -46),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileCard(
                            isDark: isDark,
                            initials: _initialsOf(user?.name),
                            name: user?.name ?? 'Pasien',
                            email: user?.email ?? '-',
                            phone: user?.phone ?? '-',
                            emailVerified: emailVerified,
                            statusText: _emailStatusText(user?.emailVerifiedAt),
                          ),
                          const SizedBox(height: 18),
                          _HealthAlertCard(
                            isDark: isDark,
                            title: emailVerified
                                ? 'Data kesehatan Anda sudah sinkron'
                                : 'Verifikasi email untuk mengamankan akun',
                            subtitle: emailVerified
                                ? 'Profil pasien siap dipakai untuk konsultasi dan pemesanan layanan.'
                                : 'Selesaikan verifikasi agar notifikasi hasil konsultasi dan jadwal medis tetap masuk.',
                            actionLabel: emailVerified ? 'Terlindungi' : 'Verifikasi',
                            icon: emailVerified
                                ? Icons.verified_user_rounded
                                : Icons.mark_email_unread_rounded,
                            highlightColor: emailVerified
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Preferensi Pasien',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuSection(
                            isDark: isDark,
                            items: [
                              _MenuItemData(
                                icon: Icons.groups_2_rounded,
                                title: 'Profil keluarga',
                                subtitle:
                                    'Kelola profil suami, istri, anak, kakek, nenek, dan pasien lain',
                                badge: 'CRUD',
                                badgeColor: AppColors.primary,
                                onTap: () =>
                                    Get.toNamed(AppRoutes.patientMembers),
                              ),
                              _MenuItemData(
                                icon: Icons.health_and_safety_rounded,
                                title: 'Keamanan akun',
                                subtitle: emailVerified
                                    ? 'Email aktif dan akun sudah terlindungi'
                                    : 'Lengkapi verifikasi email Anda',
                                badge: emailVerified ? 'Aman' : 'Perlu aksi',
                                badgeColor: emailVerified
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              _MenuItemData(
                                icon: Icons.medication_liquid_rounded,
                                title: 'Alergi & obat',
                                subtitle: (patient?.allergies ?? '').trim().isEmpty
                                    ? 'Belum ada alergi yang dicatat'
                                    : patient!.allergies,
                              ),
                              _MenuItemData(
                                icon: Icons.bloodtype_rounded,
                                title: 'Golongan darah',
                                subtitle: (patient?.bloodType ?? '').trim().isEmpty
                                    ? 'Belum dilengkapi'
                                    : patient!.bloodType,
                              ),
                              _MenuItemData(
                                icon: Icons.contact_phone_rounded,
                                title: 'Kontak darurat',
                                subtitle:
                                    '${(patient?.emergencyContactName ?? '').trim().isEmpty ? '-' : patient!.emergencyContactName} • ${(patient?.emergencyContactPhone ?? '').trim().isEmpty ? '-' : patient!.emergencyContactPhone}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Ringkasan Kesehatan',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuSection(
                            isDark: isDark,
                            items: [
                              _MenuItemData(
                                icon: Icons.cake_rounded,
                                title: 'Tanggal lahir',
                                subtitle: _formatDate(patient?.dateOfBirth),
                              ),
                              _MenuItemData(
                                icon: Icons.person_outline_rounded,
                                title: 'Jenis kelamin',
                                subtitle: (patient?.gender ?? '').trim().isEmpty
                                    ? 'Belum dilengkapi'
                                    : patient!.gender,
                              ),
                              _MenuItemData(
                                icon: Icons.home_rounded,
                                title: 'Alamat pasien',
                                subtitle: (patient?.address ?? '').trim().isEmpty
                                    ? 'Belum ada alamat tersimpan'
                                    : patient!.address,
                              ),
                              _MenuItemData(
                                icon: Icons.description_rounded,
                                title: 'Catatan medis',
                                subtitle:
                                    (patient?.medicalNotes ?? '').trim().isEmpty
                                        ? 'Belum ada catatan medis'
                                        : patient!.medicalNotes,
                              ),
                              _MenuItemData(
                                icon: Icons.history_rounded,
                                title: 'Terakhir diperbarui',
                                subtitle:
                                    _formatDate(user?.updatedAt, withTime: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.logout,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text(
                                'Keluar dari akun',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({
    required this.isDark,
    required this.title,
    required this.subtitle,
  });

  final bool isDark;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkText : const Color(0xFF113331);

    return Container(
      height: 236,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 72),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0F2A28), Color(0xFF115E58), Color(0xFF56C6A9)]
              : const [Color(0xFFDDF6C8), Color(0xFF8EE59B), Color(0xFF3FCB73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -34,
            left: -12,
            child: _HeroBubble(
              size: 112,
              color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.24),
            ),
          ),
          Positioned(
            bottom: -58,
            left: -8,
            child: _HeroBubble(
              size: 144,
              color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.18),
            ),
          ),
          Positioned(
            top: 10,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF59BDE8),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Positioned(
            top: 52,
            right: 0,
            child: Container(
              width: 108,
              height: 126,
              decoration: BoxDecoration(
                color: const Color(0xFF0E89B8),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9AE5FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  const Positioned(
                    top: 26,
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF4DAFD7),
                      size: 42,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    child: Container(
                      width: 26,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 92,
            top: 78,
            child: _FloatingIcon(
              icon: Icons.shield_rounded,
              background: const Color(0xFFEEF8FF),
              foreground: const Color(0xFF2E8DC2),
            ),
          ),
          Positioned(
            right: 14,
            top: 150,
            child: _FloatingIcon(
              icon: Icons.lock_rounded,
              background: const Color(0xFFBDEFFF),
              foreground: const Color(0xFF0E6D93),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.isDark,
    required this.initials,
    required this.name,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.statusText,
  });

  final bool isDark;
  final String initials;
  final String name;
  final String email;
  final String phone;
  final bool emailVerified;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final mutedColor =
        isDark ? AppColors.darkMutedText : AppColors.lightMutedText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : AppColors.softWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFF13BE41),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      emailVerified
                          ? Icons.verified_rounded
                          : Icons.error_rounded,
                      color: emailVerified
                          ? AppColors.success
                          : AppColors.warning,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: emailVerified ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthAlertCard extends StatelessWidget {
  const _HealthAlertCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.highlightColor,
  });

  final bool isDark;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2423) : const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF3E1B6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF965A16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: isDark ? AppColors.darkText : const Color(0xFF7B5B2F),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111717) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE8E0CF),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  icon,
                  size: 44,
                  color: highlightColor,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -2,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFC95A)),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: Color(0xFFE28A00),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.isDark,
    required this.items,
  });

  final bool isDark;
  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12211F) : AppColors.softWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _MenuTile(item: item, isDark: isDark),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE8ECF1),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.isDark,
  });

  final _MenuItemData item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor =
        isDark ? AppColors.darkMutedText : AppColors.lightMutedText;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        child: Row(
        children: [
          Icon(
            item.icon,
            size: 28,
            color: isDark ? Colors.white70 : const Color(0xFF4B4E52),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    if (item.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (item.badgeColor ?? AppColors.primary)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.badge!,
                          style: TextStyle(
                            color: item.badgeColor ?? AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: isDark ? Colors.white70 : const Color(0xFF61656A),
          ),
        ],
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: foreground),
    );
  }
}

class _HeroBubble extends StatelessWidget {
  const _HeroBubble({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;
}
