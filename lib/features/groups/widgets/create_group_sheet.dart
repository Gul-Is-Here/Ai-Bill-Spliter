import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/currency_picker.dart';
import '../models/group.dart';
import '../viewmodels/groups_viewmodel.dart';

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  static Future<Group?> show() => Get.bottomSheet<Group>(
        const CreateGroupSheet(),
        isScrollControlled: true,
        backgroundColor: Get.theme.colorScheme.surface,
      );

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _member = TextEditingController();
  final _members = <String>[];
  var _type = GroupType.trip;
  late var _currency = Get.find<LocalCacheService>().defaultCurrency;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _member.dispose();
    super.dispose();
  }

  void _addMember() {
    final n = _member.text.trim();
    if (n.isEmpty) return;
    setState(() {
      _members.add(n);
      _member.clear();
    });
  }

  Future<void> _submit() async {
    _addMember();
    if (!_formKey.currentState!.validate()) return;
    if (_members.length < 2) {
      setState(() => _error = 'error_min_participants'.tr);
      return;
    }
    final group = await Get.find<GroupsViewModel>()
        .create(name: _name.text, type: _type, currency: _currency, memberNames: _members);
    Get.back(result: group);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('new_group'.tr, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: 'group_name'.tr),
                  validator: Validators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(spacing: AppSpacing.sm, children: [
                  for (final t in GroupType.values)
                    ChoiceChip(
                      label: Text('group_type_${t.name}'.tr),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ]),
                const SizedBox(height: AppSpacing.md),
                CurrencyPicker(value: _currency, onChanged: (c) => setState(() => _currency = c)),
                const SizedBox(height: AppSpacing.md),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _member,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: 'add_person'.tr),
                      onSubmitted: (_) => _addMember(),
                    ),
                  ),
                  IconButton(onPressed: _addMember, icon: const Icon(Icons.person_add_alt_1), tooltip: 'add_person'.tr),
                ]),
                Wrap(spacing: AppSpacing.sm, children: [
                  for (var i = 0; i < _members.length; i++)
                    InputChip(label: Text(_members[i]), onDeleted: () => setState(() => _members.removeAt(i))),
                ]),
                if (_error != null)
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(onPressed: _submit, child: Text('create_group'.tr)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
