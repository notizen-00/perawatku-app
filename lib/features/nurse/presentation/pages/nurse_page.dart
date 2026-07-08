import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/nurse_controller.dart';
import '../widgets/nurse_list_card.dart';
import '../widgets/state_message.dart';

class NursePage extends GetView<NurseController> {
  const NursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perawat')),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.loadNurses(),
              controller.loadServices(),
              controller.loadPatientMembers(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Perawat terdekat',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (controller.isLoading.value && controller.nurses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage.value != null &&
                  controller.nurses.isEmpty)
                StateMessage(
                  title: 'Perawat belum bisa dimuat',
                  description: controller.errorMessage.value!,
                  actionLabel: 'Coba lagi',
                  onTap: controller.loadNurses,
                )
              else if (controller.nurses.isEmpty)
                const StateMessage(
                  title: 'Belum ada perawat',
                  description:
                      'Data perawat yang tersedia akan tampil di halaman ini.',
                )
              else
                ...controller.nurses.map(
                  (nurse) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NurseListCard(nurse: nurse),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
