import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button_new.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class OverViewDashboard extends ConsumerWidget {
//   const OverViewDashboard({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     var controller = ref.watch(dashboardControllerProvider);

//     return Row(
//       children: [
//         Text(
//           S.of(context).dashboardOverview,
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: context.primaryColor,
//               fontSize: 20),
//         ),
//         const SizedBox(
//           width: 100,
//         ),
//         Expanded(
//             child: ScrollConfiguration(
//           behavior: ScrollConfiguration.of(context).copyWith(
//             dragDevices: {
//               PointerDeviceKind.mouse,
//               PointerDeviceKind.touch,
//             },
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ...controller.buttons.map((e) => DefaultOutlineButton(
//                     onpress: () async {
//                       controller.onchangeView(e.dashboardFilterEnum);
//                     },
//                     name: e.dashboardFilterEnum.localizedName(context),
//                     textcolor:
//                         e.isselected ? Colors.white : context.primaryColor,
//                     backgroundColor:
//                         e.isselected ? context.primaryColor : Colors.white)),
//               ],
//             ),
//           ),
//         ))
//       ],
//     );
//   }
// }

final selectedDashboardViewProvider = StateProvider<DashboardFilterEnum>((ref) {
  return DashboardFilterEnum.today;
});

class OverViewDashboard extends ConsumerWidget {
  OverViewDashboard({super.key});
  final List<DashboardFilterEnum> views = [
    DashboardFilterEnum.lastYear,
    DashboardFilterEnum.lastMonth,
    DashboardFilterEnum.yesterday,
    DashboardFilterEnum.today,
    DashboardFilterEnum.thisWeek,
    DashboardFilterEnum.thisMonth,
    DashboardFilterEnum.thisYear,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(dashboardControllerProvider);
    var selectedView = ref.watch(selectedDashboardViewProvider);
    final isMobile = context.isMobile;

    // Mobile: Horizontal scrollable toggle buttons
    if (isMobile) {
      return SizedBox(
        height: 50.h,
        child: ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemCount: views.length,
            itemBuilder: (context, index) {
              final view = views[index];
              final isSelected = view == selectedView;

              return GestureDetector(
                onTap: () {
                  controller.onchangeView(view);
                  ref.read(selectedDashboardViewProvider.notifier).state = view;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? context.primaryColor : null,
                    border: Border.all(color: Pallete.greyColor, width: 1),
                  ),
                  child: Center(
                    child: DefaultTextView(
                      text: view.localizedName(context),

                      color: isSelected ? Pallete.whiteColor : null,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // Desktop/Tablet: Centered toggle button
    return Center(
      child: CustomToggleButtonNew(
        height: 40,
        labels: views.map((view) => view.localizedName(context)).toList(),
        selectedIndex: views.indexOf(selectedView),
        onPressed: (index) {
          final view = views[index];
          controller.onchangeView(view);
          ref.read(selectedDashboardViewProvider.notifier).state = view;
        },
      ),
    );
  }
}
