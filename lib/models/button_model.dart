import 'package:desktoppossystem/shared/utils/enum.dart';

class DashboardButtonModel {
  DashboardFilterEnum dashboardFilterEnum;
  bool isselected = false;

  DashboardButtonModel(this.isselected, {required this.dashboardFilterEnum});
}

class ProfitButtonModel {
  ReportInterval reportInterval;
  bool isselected = false;

  ProfitButtonModel(this.isselected, {required this.reportInterval});
}
