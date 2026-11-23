import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/view_state.dart';
import '../../bill/models/participant.dart';
import '../models/group.dart';
import '../repositories/group_repository.dart';

class GroupsViewModel extends GetxController {
  GroupsViewModel(this._repository);

  final GroupRepository _repository;

  final groups = <Group>[].obs;
  final state = ViewState.loading.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    groups.assignAll(_repository.cachedGroups());
    if (groups.isNotEmpty) state.value = ViewState.success;
    refreshGroups();
  }

  Future<void> refreshGroups() async {
    try {
      groups.assignAll(await _repository.fetchAll());
      state.value = groups.isEmpty ? ViewState.empty : ViewState.success;
    } on AppException catch (e) {
      if (groups.isNotEmpty) return;
      errorMessage.value = e.message;
      state.value = ViewState.empty;
    }
  }

  Future<Group> create({
    required String name,
    required GroupType type,
    required String currency,
    required List<String> memberNames,
  }) async {
    final id = _repository.newId();
    final group = await _repository.save(Group(
      id: id,
      name: name.trim(),
      type: type,
      currency: currency,
      createdAt: DateTime.now(),
      members: [
        for (var i = 0; i < memberNames.length; i++) Participant(id: '${id}_m$i', name: memberNames[i].trim()),
      ],
    ));
    groups.insert(0, group);
    state.value = ViewState.success;
    return group;
  }

  void replace(Group group) {
    final i = groups.indexWhere((g) => g.id == group.id);
    if (i >= 0) groups[i] = group;
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    groups.removeWhere((g) => g.id == id);
    if (groups.isEmpty) state.value = ViewState.empty;
  }
}
