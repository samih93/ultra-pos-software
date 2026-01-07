class CustomersCountByViewModel {
  String day;
  int count;

  CustomersCountByViewModel(this.day, this.count);

  factory CustomersCountByViewModel.fromJson(Map<String, dynamic> map) {
    return CustomersCountByViewModel(map['day'], map['count']);
  }
}
