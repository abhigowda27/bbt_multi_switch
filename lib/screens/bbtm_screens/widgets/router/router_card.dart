import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/constants.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/connect_to_router.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/router_on_off.dart';
import 'package:bbtml_new/screens/switches/switch_page_cloud.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/api_status.dart';
import '../../../../widgets/common_snackbar.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../view/schedule_on_off_page.dart';
import '../custom/toast.dart';

class RouterCard extends StatefulWidget {
  final RouterDetails routerDetails;
  final bool showOptions;

  const RouterCard({
    this.showOptions = true,
    required this.routerDetails,
    super.key,
  });

  @override
  State<RouterCard> createState() => _RouterCardState();
}

class _RouterCardState extends State<RouterCard> {
  bool hide = true;
  bool isExpanded = false;
  final StorageController _storageController = StorageController();
  final SwitchBloc _addToCloudBloc = SwitchBloc();
  final NetworkService _networkService = NetworkService();
  String _wifiName = "";
  late VoidCallback _wifiListener;

  @override
  void dispose() {
    _networkService.wifiNameNotifier.removeListener(_wifiListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    isExpanded = !widget.showOptions;

    _wifiName = _networkService.wifiName;

    _wifiListener = () {
      if (!mounted) return;
      setState(() {
        _wifiName = _networkService.wifiName;
      });
    };

    _networkService.wifiNameNotifier.addListener(_wifiListener);
  }

  // ✅ Helper method (clean + reusable)
  bool _isConnectedToRouter() {
    return _wifiName
            .toLowerCase()
            .contains(widget.routerDetails.routerName.toLowerCase()) ||
        widget.routerDetails.routerName
            .toLowerCase()
            .contains(_wifiName.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return InkWell(
      onTap: widget.showOptions
          ? () {
              !_isConnectedToRouter()
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConnectToRouterPage(
                          routerDetails: widget.routerDetails,
                        ),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouterOnOff(
                          routerDetails: widget.routerDetails,
                        ),
                      ),
                    );
            }
          : null,
      child: Container(
        padding: EdgeInsets.all(width * 0.03),
        decoration: widget.showOptions
            ? BoxDecoration(
                boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .appColors
                          .textSecondary
                          .withValues(alpha: 0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(2, 2),
                    ),
                  ],
                color:
                    Theme.of(context).appColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12))
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .appColors
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .appColors
                              .textSecondary
                              .withValues(alpha: 0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                        Constants().applianceIconAsset(
                            widget.routerDetails.switchType ?? ""),
                        width: width * 0.2,
                        height: width * 0.2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(widget.routerDetails.routerName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontSize: 18)),
                          ),
                          IconButton(
                              tooltip: "more info",
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.info_outline,
                                color: Theme.of(context).appColors.primary,
                              ),
                              onPressed: () => showInfo()),
                        ],
                      ),
                      Text(
                        widget.routerDetails.switchName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.routerDetails.switchTypes.isNotEmpty) ...[
                            Expanded(
                              child: Text(
                                "(${widget.routerDetails.switchTypes.length}) Devices",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                          if (widget.routerDetails.selectedFan!.isNotEmpty) ...[
                            Expanded(
                              child: Text(
                                widget.routerDetails.selectedFan!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.routerDetails.wattage != 0) ...[
                        Text(CommonServices()
                            .formatWatt(widget.routerDetails.wattage ?? 0))
                      ]
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.showOptions) ...[
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).appColors.primary,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        tooltip: "Delete Router",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (cont) {
                              return AlertDialog(
                                title: Text(
                                  'Delete Router',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .appColors
                                              .redButton),
                                ),
                                content: Text(
                                  'This will delete the Router',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                actions: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'CANCEL',
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      _storageController.deleteOneRouter(
                                          widget.routerDetails.switchID);
                                      Navigator.pushAndRemoveUntil<dynamic>(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) =>
                                              const TabsPage(),
                                        ),
                                        (route) =>
                                            false, //if you want to disable back feature set to false
                                      );
                                    },
                                    child: const Text(
                                      'OK',
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).appColors.textPrimary)),
                    IconButton(
                        tooltip: "timer",
                        onPressed: () {
                          if (!_isConnectedToRouter()) {
                            showFlutterToast(
                                "You should be connected to ${widget.routerDetails.routerName} to proceed");
                            AppSettings.openAppSettings(
                                type: AppSettingsType.wifi);
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleOnOffPage(
                                switchName: widget.routerDetails.switchName,
                                ipAddress: widget.routerDetails.iPAddress!,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.access_alarms_sharp,
                            color: Theme.of(context).appColors.textPrimary)),
                    BlocListener<SwitchBloc, CommonState>(
                      bloc: _addToCloudBloc,
                      listener: (context, state) {
                        ApiStatus apiResponse = state.apiStatus;
                        if (apiResponse is ApiResponse) {
                          final responseData = apiResponse.response;
                          CommonServices.hideLoadingDialog(context);
                          debugPrint("Response data====>$responseData");
                          if (responseData != null &&
                              responseData["status"] == "success") {
                            navigateToHome();
                          }
                        } else if (apiResponse is ApiLoadingState ||
                            apiResponse is ApiInitialState) {
                          CommonServices.showLoadingDialog(context);
                        } else if (apiResponse is ApiFailureState) {
                          CommonServices.hideLoadingDialog(context);
                          final exception = apiResponse.exception.toString();
                          debugPrint(exception);
                          String errorMessage =
                              'Something went wrong! Please try again';
                          final messageMatch = RegExp(r'message:\s*([^}]+)')
                              .firstMatch(exception);
                          if (messageMatch != null) {
                            errorMessage =
                                messageMatch.group(1)?.trim() ?? errorMessage;
                          }
                          showSnackBar(context, errorMessage);
                        }
                      },
                      child: IconButton(
                          tooltip: "add to cloud",
                          onPressed: widget.routerDetails.deviceMacId != null
                              ? () {
                                  try {
                                    // Build the switches list
                                    List<Map<String, dynamic>> switchesPayload =
                                        [];

                                    // Add selected switches
                                    for (var i = 0;
                                        i <
                                            widget.routerDetails.switchTypes
                                                .length;
                                        i++) {
                                      switchesPayload.add({
                                        "type": 1,
                                        "name": widget.routerDetails
                                            .switchTypes[i]["name"],
                                      });
                                    }

                                    // Add fan if selected
                                    if (widget.routerDetails.selectedFan!
                                        .isNotEmpty) {
                                      switchesPayload.add({
                                        "type": 2, // 2 = fan
                                        "name":
                                            widget.routerDetails.selectedFan,
                                      });
                                    }
                                    // Final payload
                                    final payload = {
                                      "deviceName":
                                          widget.routerDetails.switchName,
                                      "deviceType": 3,
                                      "deviceId":
                                          widget.routerDetails.deviceMacId,
                                      "switches": switchesPayload
                                    };

                                    _addToCloudBloc
                                        .add(AddSwitchEvent(payload: payload));
                                  } catch (e) {
                                    debugPrint("Error ${e.toString()}");
                                  }
                                }
                              : () {
                                  showSnackBar(context,
                                      "Mac Id does not exit, Please check");
                                },
                          icon: Icon(Icons.cloud_upload_sharp,
                              color: widget.routerDetails.deviceMacId != null
                                  ? Theme.of(context).appColors.textPrimary
                                  : Theme.of(context).appColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).appColors.background.withValues(alpha: 0.75),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ---------- HEADER ----------
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .appColors
                                  .primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              Constants().applianceIconAsset(
                                widget.routerDetails.switchType ?? "",
                              ),
                              width: 45,
                              height: 45,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.routerDetails.routerName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// ---------- CONTENT ----------
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonWidgets().infoRow(
                                context,
                                label: "Switch ID",
                                value: widget.routerDetails.switchID,
                              ),
                              CommonWidgets().infoRow(
                                context,
                                label: "Switch Name",
                                value: widget.routerDetails.switchName,
                              ),
                              Divider(
                                  color: Theme.of(context)
                                      .appColors
                                      .textSecondary),
                              if (widget
                                  .routerDetails.switchTypes.isNotEmpty) ...[
                                Text(
                                  "Selected Switches (${widget.routerDetails.switchTypes.length})",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                ...widget.routerDetails.switchTypes
                                    .map((entry) {
                                  final index = entry["order"];
                                  final switchType = entry["name"];

                                  return Card(
                                    color: Theme.of(context)
                                        .appColors
                                        .primary
                                        .withValues(alpha: 0.5),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .appColors
                                            .primary
                                            .withValues(alpha: 0.5),
                                        child: Text("$index"),
                                      ),
                                      titleTextStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      title: Text(switchType),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title:
                                                  const Text("Delete Switch"),
                                              content: Text(
                                                  'Are you sure you want to delete "$switchType"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .appColors
                                                          .redButton,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            _storageController
                                                .deleteOneSwitchTypeFromRouter(
                                              switchId:
                                                  widget.routerDetails.switchID,
                                              switchTypeToRemove: switchType,
                                            );
                                            setState(() {
                                              widget.routerDetails.switchTypes
                                                  .remove(switchType);
                                            });
                                            setDialogState(() {});
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }),
                                Divider(
                                    color: Theme.of(context)
                                        .appColors
                                        .textSecondary),
                              ],
                              if (widget
                                      .routerDetails.selectedFan?.isNotEmpty ==
                                  true)
                                CommonWidgets().infoRow(
                                  context,
                                  label: "Selected Fan",
                                  value: widget.routerDetails.selectedFan!,
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SwitchCloudPage()),
      );
    }
  }
}
