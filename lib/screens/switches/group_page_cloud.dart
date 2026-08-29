import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/screens/switches/add_group_page.dart';
import 'package:bbtml_new/screens/switches/group_details_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart' as CustomSnackBar;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupPageCloud extends StatefulWidget {
  const GroupPageCloud({super.key, required this.switchBloc});
  final SwitchBloc switchBloc;
  @override
  State<GroupPageCloud> createState() => _GroupPageCloudState();
}

class _GroupPageCloudState extends State<GroupPageCloud> {
  final SwitchBloc _switchBloc = SwitchBloc();
  final SwitchBloc _deleteGroupBloc = SwitchBloc();

  List<dynamic> _groupList = [];
  @override
  void initState() {
    _switchBloc.add(GetGroupListEvent());
    super.initState();
  }

  @override
  void dispose() {
    _switchBloc.close();
    _deleteGroupBloc.close();
    super.dispose();
  }

  Widget _buildGroupList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(15),
      itemCount: _groupList.length,
      itemBuilder: (context, index) {
        final group = _groupList[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).appColors.background,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsPage(
                    switchBloc: widget.switchBloc,
                    groupDetails: group,
                  ),
                ),
              );
              debugPrint("Group: $group");
            },
            tileColor: Theme.of(context).appColors.background,
            contentPadding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                    color: Theme.of(context).appColors.primary,
                    width: 1,
                    style: BorderStyle.solid)),
            leading: Image.asset(
              "assets/images/group_icon.png",
              color: Theme.of(context).appColors.textPrimary,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      deleteDevice(context, group["uuid"]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).appColors.red,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_outlined),
              ],
            ),
            title: Text(
              group["groupName"] ?? "NA",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SwitchBloc, CommonState>(
      bloc: _deleteGroupBloc,
      listener: (context, state) {
        final apiStatus = state.apiStatus;

        if (apiStatus is ApiResponse) {
          // Delete successful
          _switchBloc.add(GetGroupListEvent());

          CustomSnackBar.commonSnackBar(context, "Group deleted successfully");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Cloud Groups"),
        ),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // roundness
          ),
          child: Icon(
            color: Theme.of(context).appColors.background,
            Icons.add,
          ),
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddGroupCloudPage(
                switchBloc: widget.switchBloc,
              ),
            ));
            _switchBloc.add(GetGroupListEvent());
          },
        ),
        body: BlocBuilder<SwitchBloc, CommonState>(
          bloc: _switchBloc,
          builder: (context, state) {
            final apiStatus = state.apiStatus;
            if (apiStatus is ApiResponse) {
              final apiResponse = apiStatus.response;
              _groupList = apiResponse?['data'] ?? [];
              debugPrint("Api Response: $apiResponse");
              if (_groupList.isEmpty) {
                return CommonServices.noDataWidget();
              } else {
                return _buildGroupList();
              }
            } else if (apiStatus is ApiInitialState ||
                apiStatus is ApiLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return CommonServices.failureWidget(() {
                _switchBloc.add(GetGroupListEvent());
              });
            }
          },
        ),
      ),
    );
  }

  void deleteDevice(BuildContext context, String groupUuid) {
    debugPrint("Group UUID: $groupUuid");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).appColors.redButton,
            ),
            const SizedBox(width: 10),
            Text(
              "Delete Group",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).appColors.textSecondary,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this group?\nThis action cannot be undone.",
          style: TextStyle(
            color: Theme.of(context).appColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).appColors.textSecondary,
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).appColors.redButton,
              foregroundColor: Theme.of(context).appColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteGroupBloc.add(DeleteGroupEvent(groupUuid: groupUuid));
            },
          ),
        ],
      ),
    );
  }
}
