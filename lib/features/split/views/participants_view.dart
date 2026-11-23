import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/member_avatar.dart';
import '../../bill/models/bill.dart';
import '../../voice/widgets/voice_split_sheet.dart';
import '../viewmodels/split_flow_viewmodel.dart';
import '../widgets/flow_bottom_bar.dart';

class ParticipantsView extends StatefulWidget {
  const ParticipantsView({super.key});

  @override
  State<ParticipantsView> createState() => _ParticipantsViewState();
}

class _ParticipantsViewState extends State<ParticipantsView> {
  final vm = Get.find<SplitFlowViewModel>();
  final _name = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    vm.addParticipant(_name.text);
    _name.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('who_is_splitting'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_none),
            tooltip: 'voice_split'.tr,
            onPressed: () async {
              final result = await VoiceSplitSheet.show(vm.bill.value.items.map((i) => i.name).toList());
              if (result != null) vm.applyVoice(result);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _name,
                focusNode: _focus,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: 'add_person'.tr),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(onPressed: _add, icon: const Icon(Icons.person_add_alt_1), tooltip: 'add_person'.tr),
            IconButton(
              onPressed: () async {
                // System picker: no READ_CONTACTS permission needed, only the chosen name is read.
                final contact = await FlutterContacts.native.showPicker();
                final name = contact?.displayName;
                if (name != null && name.trim().isNotEmpty) vm.addParticipant(name);
              },
              icon: const Icon(Icons.contacts_outlined),
              tooltip: 'add_from_contacts'.tr,
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            final b = vm.bill.value;
            return Column(children: [
              for (final p in b.participants)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: MemberAvatar(id: p.id, name: p.name),
                  title: Text(p.name),
                  subtitle: b.payerId == p.id ? Text('paid_the_bill'.tr) : null,
                  onTap: () => vm.setPayer(p.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'remove'.tr,
                    onPressed: () => vm.removeParticipant(p.id),
                  ),
                ),
              if (b.participants.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text('tap_to_set_payer'.tr, style: theme.textTheme.bodySmall),
                ),
            ]);
          }),
          const Divider(height: AppSpacing.xl),
          Text('split_method'.tr, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Obx(() => SegmentedButton<SplitMethod>(
                segments: [
                  ButtonSegment(value: SplitMethod.equal, label: Text('method_equal'.tr), icon: const Icon(Icons.drag_handle)),
                  ButtonSegment(value: SplitMethod.itemwise, label: Text('method_itemwise'.tr), icon: const Icon(Icons.list)),
                  ButtonSegment(value: SplitMethod.percentage, label: Text('method_percentage'.tr), icon: const Icon(Icons.percent)),
                ],
                selected: {vm.bill.value.splitMethod},
                onSelectionChanged: (s) => vm.setMethod(s.first),
              )),
        ],
      ),
      bottomNavigationBar: FlowBottomBar(label: 'next'.tr, onPressed: vm.continueFromParticipants),
    );
  }
}
