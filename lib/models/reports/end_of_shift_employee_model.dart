class EndOfShiftEmployeeModel {
  int shiftId;
  String employeeName;
  String startShiftDate;
  String? endShiftDate;

  EndOfShiftEmployeeModel(
      {required this.shiftId,
      required this.employeeName,
      required this.startShiftDate,
      this.endShiftDate});
}
