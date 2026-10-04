import 'package:flutter/widgets.dart';

class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  bool get isArabic => locale.languageCode == 'ar';
  String get appName => 'VIA';
  String get demoMode => isArabic ? 'وضع تجريبي' : 'Demo mode';
  String get bookingId => isArabic ? 'رقم الحجز' : 'Booking';
  String get bookingStatus => isArabic ? 'حالة الحجز' : 'Status';
  String get expired => isArabic ? 'منتهي' : 'Expired';
  String get holdCountdown => isArabic ? 'المتبقي للحجز' : 'Hold remaining';
  String get requestCash => isArabic ? 'طلب تأكيد الدفع النقدي' : 'Request cash confirmation';
  String get awaitingCash => isArabic ? 'بانتظار تأكيد المشغل للدفع النقدي' : 'Awaiting operator cash confirmation';
  String get simulateCashConfirmation => isArabic ? 'محاكاة تأكيد المشغل' : 'Simulate operator confirmation';
  String get ticketIssued => isArabic ? 'تم إصدار التذكرة' : 'Ticket issued';
  String get ticketId => isArabic ? 'رقم التذكرة' : 'Ticket';
  String get commission => isArabic ? 'العمولة' : 'Commission';
  String get demo => isArabic ? 'تجريبي' : 'Demo';
  String get headline => isArabic ? 'سافر ببساطة.' : 'Travel simply.';
  String get route => isArabic ? 'دمشق ← منطقة جامعات درعا' : 'Damascus → Daraa University Area';
  String get from => isArabic ? 'من' : 'From';
  String get to => isArabic ? 'إلى' : 'To';
  String get searchTrips => isArabic ? 'البحث عن الرحلات' : 'Search trips';
  String get availableTrips => isArabic ? 'الرحلات المتاحة' : 'Available trips';
  String get chooseSeats => isArabic ? 'اختر المقاعد' : 'Choose seats';
  String seats(int count) => isArabic ? '$count مقعد' : '$count seat${count == 1 ? '' : 's'}';
  String price(int amount) => isArabic ? '$amount SYP' : '$amount SYP';
  String get holdSeats => isArabic ? 'حجز المقاعد مؤقتاً' : 'Hold seats';
  String get oneWay => isArabic ? 'ذهاب' : 'One way';
  String get roundTrip => isArabic ? 'ذهاب وعودة' : 'Round trip';
  String get language => isArabic ? 'EN' : 'عربي';
  String get trustedBoundaryTitle => isArabic ? 'حد الثقة في الحجز' : 'Trusted booking boundary';
  String get trustedBoundaryText => isArabic
      ? 'تغييرات المقاعد تتم من خلال الخادم الموثوق. هذه النسخة تعرض مسار العميل وتبقي سلطة التعديل خارج التطبيق.'
      : 'Seat mutations stay on the trusted backend. This build presents the passenger journey while mutation authority remains outside the client.';
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);
  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
