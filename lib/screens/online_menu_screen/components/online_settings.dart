import 'dart:typed_data';

import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/opening_hours_model.dart';
import 'package:desktoppossystem/models/setting_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class OnlineSettings extends ConsumerStatefulWidget {
  const OnlineSettings({super.key});

  @override
  ConsumerState<OnlineSettings> createState() => _OnlineSettingsState();
}

class _OnlineSettingsState extends ConsumerState<OnlineSettings> {
  late TextEditingController _storeNameController;
  late TextEditingController _storeLocationController;
  late TextEditingController _storePhoneController;
  late TextEditingController _noteController;
  late TextEditingController _dolarRateController;

  bool _isInitialized = false;
  bool isLoadingUpdate = false;
  Uint8List? _logoBytes;
  List<OpeningHoursModel> _openingHours = OpeningHoursModel.getDefaultHours();

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _storeLocationController = TextEditingController();
    _storePhoneController = TextEditingController();
    _noteController = TextEditingController();
    _dolarRateController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final menuState = ref.read(menuControllerProvider);
      if (menuState.getSettingsState == RequestState.success &&
          menuState.settingModel != null) {
        _loadSettingsData(menuState.settingModel!);
        _isInitialized = true;
      }
    }
  }

  void _loadSettingsData(SettingModel setting) {
    _storeNameController.text = setting.storeName ?? '';
    _storeLocationController.text = setting.storeLocation ?? '';
    _storePhoneController.text = setting.storePhone ?? '';
    _noteController.text = setting.note ?? '';
    _dolarRateController.text = setting.dolarRate?.toString() ?? '';
    _logoBytes = setting.logo;
    _openingHours = setting.openingHours ?? OpeningHoursModel.getDefaultHours();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeLocationController.dispose();
    _storePhoneController.dispose();
    _noteController.dispose();
    _dolarRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuControllerProvider);

    // Load settings data when they become available
    if (!_isInitialized &&
        menuState.getSettingsState == RequestState.success &&
        menuState.settingModel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isInitialized) {
          _loadSettingsData(menuState.settingModel!);
          setState(() {
            _isInitialized = true;
          });
        }
      });
    }

    if (menuState.getSettingsState == RequestState.loading) {
      return Container(
        padding: kPadd10,
        decoration: BoxDecoration(
          borderRadius: defaultRadius,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: const Center(child: CoreCircularIndicator()),
      );
    }

    return Container(
      padding: kPadd10,
      decoration: BoxDecoration(
        borderRadius: defaultRadius,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DefaultTextView(
                        text: S.of(context).settingScreen,
                        color: context.primaryColor,
                        fontSize: 20,
                      ),
                      ElevatedButtonWidget(
                        states: [
                          isLoadingUpdate
                              ? RequestState.loading
                              : RequestState.success,
                        ],
                        isDisabled: isLoadingUpdate,
                        icon: Icons.save,
                        text: S.of(context).save,
                        onPressed: () {
                          saveOnlineSettings();
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  AppTextFormField(
                    showText: true,
                    controller: _storeNameController,
                    inputtype: TextInputType.name,
                    hinttext: "${S.of(context).name.capitalizeFirstLetter()}",
                  ),
                  AppTextFormField(
                    showText: true,
                    controller: _storeLocationController,
                    inputtype: TextInputType.name,
                    hinttext: S.of(context).address.capitalizeFirstLetter(),
                  ),
                  AppTextFormField(
                    showText: true,
                    controller: _storePhoneController,
                    inputtype: TextInputType.phone,
                    hinttext: S.of(context).phone.capitalizeFirstLetter(),
                  ),
                  AppTextFormField(
                    showText: true,
                    format: numberTextFormatter,
                    controller: _dolarRateController,
                    inputtype: TextInputType.number,
                    hinttext: S.of(context).dollarRate,
                  ),
                  AppTextFormField(
                    height: 200,
                    showText: true,
                    controller: _noteController,
                    inputtype: TextInputType.multiline,
                    maxligne: 10,
                    minline: 5,
                    hinttext: S.of(context).note.capitalizeFirstLetter(),
                  ),
                  kGap20,

                  // Opening Hours Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextView(
                        text: 'Opening Hours',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                      kGap10,
                      const Divider(),
                      kGap10,
                      ..._openingHours.asMap().entries.map((entry) {
                        final index = entry.key;
                        final hours = entry.value;
                        return _buildOpeningHourRow(index, hours);
                      }).toList(),
                    ],
                  ),
                  kGap20,

                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: maxWidth,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: _logoBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                _logoBytes!,
                                width: 250,
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                kGap10,
                                DefaultTextView(
                                  text: S.of(context).pickLogo,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _logoBytes = bytes;
      });
    }
  }

  Widget _buildOpeningHourRow(int index, OpeningHoursModel hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 80,
            child: DefaultTextView(
              text: hours.day.capitalizeFirstLetter(),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          kGap5,

          // Open time
          Expanded(
            child: InkWell(
              onTap: hours.isClosed ? null : () => _selectTime(index, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hours.isClosed
                        ? Colors.grey.shade300
                        : Pallete.blueColor,
                  ),
                  borderRadius: defaultRadius,
                  color: hours.isClosed ? Colors.grey.shade100 : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextView(
                      text: hours.openAt,
                      fontSize: 12,
                      color: hours.isClosed ? Colors.grey : Colors.black,
                    ),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: hours.isClosed ? Colors.grey : Pallete.blueColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          kGap5,

          // Close time
          Expanded(
            child: InkWell(
              onTap: hours.isClosed ? null : () => _selectTime(index, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hours.isClosed
                        ? Colors.grey.shade300
                        : Pallete.blueColor,
                  ),
                  borderRadius: defaultRadius,
                  color: hours.isClosed ? Colors.grey.shade100 : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextView(
                      text: hours.closeAt,
                      fontSize: 12,
                      color: hours.isClosed ? Colors.grey : Colors.black,
                    ),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: hours.isClosed ? Colors.grey : Pallete.blueColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          kGap5,

          // Closed checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: hours.isClosed,
                  onChanged: (value) {
                    setState(() {
                      _openingHours[index] = hours.copyWith(
                        isClosed: value ?? false,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 4),
              const DefaultTextView(text: 'Off', fontSize: 11),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(int index, bool isOpenTime) async {
    final currentHours = _openingHours[index];
    final currentTime = isOpenTime ? currentHours.openAt : currentHours.closeAt;
    final timeParts = currentTime.split(':');

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 10,
        minute: int.tryParse(timeParts[1]) ?? 0,
      ),
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        if (index == 0) {
          // First day - apply to all days
          _openingHours = _openingHours.map((h) {
            return h.copyWith(
              openAt: isOpenTime ? timeString : h.openAt,
              closeAt: isOpenTime ? h.closeAt : timeString,
            );
          }).toList();
        } else {
          // Other days - update only the selected day
          _openingHours[index] = currentHours.copyWith(
            openAt: isOpenTime ? timeString : currentHours.openAt,
            closeAt: isOpenTime ? currentHours.closeAt : timeString,
          );
        }
      });
    }
  }

  Future<void> saveOnlineSettings() async {
    if (isLoadingUpdate) return;
    setState(() {
      isLoadingUpdate = true;
    });

    final currentSetting = ref.read(menuControllerProvider).settingModel;
    if (currentSetting == null) {
      setState(() {
        isLoadingUpdate = false;
      });
      return;
    }

    final updatedSetting = currentSetting.copyWith(
      storeName: _storeNameController.text.trim(),
      storeLocation: _storeLocationController.text.trim(),
      storePhone: _storePhoneController.text.trim(),
      note: _noteController.text.trim(),
      dolarRate: double.tryParse(_dolarRateController.text.trim()),
      logo: _logoBytes,
      openingHours: _openingHours,
    );

    await ref
        .read(menuControllerProvider.notifier)
        .updateMenuSettings(updatedSetting);
    setState(() {
      isLoadingUpdate = false;
    });
  }
}
