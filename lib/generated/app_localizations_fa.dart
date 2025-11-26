// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'سفر';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get createAccount => 'ایجاد حساب کاربری';

  @override
  String get signInToContinue => 'برای ادامه وارد شوید';

  @override
  String get letsGetYouStarted => 'بیایید شروع کنیم';

  @override
  String get emailLabel => 'ایمیل';

  @override
  String get passwordLabel => 'رمز عبور';

  @override
  String get fullNameLabel => 'نام کامل';

  @override
  String get phoneLabel => 'شماره تلفن';

  @override
  String get iAmA => 'من یک ... هستم';

  @override
  String get userTypeClient => 'مشتری';

  @override
  String get userTypeDriver => 'راننده';

  @override
  String get vehicleDetailsTitle => 'مشخصات وسیله نقلیه';

  @override
  String get vehicleModelLabel => 'مدل وسیله نقلیه';

  @override
  String get licensePlateLabel => 'پلاک';

  @override
  String get colorLabel => 'رنگ';

  @override
  String get yearLabel => 'سال';

  @override
  String get vehicleTypeLabel => 'نوع وسیله نقلیه';

  @override
  String get vehicleTypeSedan => 'سدان';

  @override
  String get vehicleTypeSuv => 'شاسی بلند';

  @override
  String get vehicleTypeHatchback => 'هاچ‌بک';

  @override
  String get vehicleTypeMinivan => 'مینی‌ون';

  @override
  String get vehicleTypeTukTuk => 'توک-توک';

  @override
  String get vehicleTypeMotorbike => 'موتورسیکلت';

  @override
  String get signInButton => 'ورود';

  @override
  String get createAccountButton => 'ایجاد حساب';

  @override
  String get alreadyHaveAccount => 'حساب کاربری دارید؟ وارد شوید';

  @override
  String get dontHaveAccount => 'ایجاد حساب کاربری';

  @override
  String get emailValidationError => 'ایمیل را وارد کنید';

  @override
  String get passwordValidationError => 'رمز عبور باید حداقل ۶ کاراکتر باشد';

  @override
  String get nameValidationError => 'نام را وارد کنید';

  @override
  String get phoneValidationError => 'شماره تلفن را وارد کنید';

  @override
  String get whereTo => 'کجا می‌روید؟';

  @override
  String get ride => 'سفر';

  @override
  String get delivery => 'تحویل';

  @override
  String get cancel => 'لغو';

  @override
  String get driverResponding => 'در حال پاسخگویی راننده...';

  @override
  String get searchingWaitMessage => 'این معمولاً چند ثانیه طول می‌کشد';

  @override
  String arrivingIn(int minutes) {
    return 'رسیدن در حدود $minutes دقیقه';
  }

  @override
  String freeWaitTime(String time) {
    return 'زمان انتظار رایگان: $time';
  }

  @override
  String get meetDriverAtPickup => 'راننده را در محل سوار شدن ملاقات کنید';

  @override
  String minutesLeft(int minutes) {
    return '$minutes دقیقه باقی مانده';
  }

  @override
  String get onTheWayToDestination => 'در راه به مقصد';

  @override
  String get onMyWay => 'در راهم';

  @override
  String get safety => 'ایمنی';

  @override
  String get contact => 'تماس';

  @override
  String get locationAccessRequired => 'دسترسی به موقعیت مکانی لازم است';

  @override
  String get locationAccessMessage =>
      'برای یافتن سفر و نمایش موقعیت شما روی نقشه، به دسترسی به موقعیت مکانی شما نیاز داریم.';

  @override
  String get enableLocation => 'فعال کردن موقعیت مکانی';

  @override
  String requestRide(String rideName) {
    return 'درخواست $rideName';
  }

  @override
  String requestDelivery(String price) {
    return 'درخواست تحویل ($price)';
  }

  @override
  String get chooseDestination => 'انتخاب مقصد';

  @override
  String get search => 'جستجو';

  @override
  String get selectOnMap => 'انتخاب روی نقشه';

  @override
  String get currentLocation => 'موقعیت فعلی';

  @override
  String get pickupLocation => 'محل سوار شدن';

  @override
  String get confirmDestination => 'تایید مقصد';

  @override
  String routeInfo(String distance, int duration) {
    return '$distance کیلومتر · $duration دقیقه';
  }

  @override
  String get deliveryDetails => 'جزئیات تحویل';

  @override
  String get recipientName => 'نام گیرنده';

  @override
  String get recipientPhone => 'تلفن گیرنده';

  @override
  String get packageDetails => 'جزئیات بسته (مثلا اسناد)';

  @override
  String get fragilePackage => 'بسته شکستنی است؟';

  @override
  String get youAreOnline => 'شما آنلاین هستید';

  @override
  String get youAreOffline => 'شما آفلاین هستید';

  @override
  String get headingToPickup => 'در راه به مبدا';

  @override
  String get headingToPickupPackage => 'در راه برای گرفتن بسته';

  @override
  String get arrivedAtPickup => 'به مبدا رسید';

  @override
  String get arrivedForPackagePickup => 'برای گرفتن بسته رسید';

  @override
  String get onTrip => 'در سفر';

  @override
  String get deliveringPackage => 'در حال تحویل بسته';

  @override
  String get onARide => 'در حال سفر';

  @override
  String get tripRequest => 'درخواست سفر';

  @override
  String get deliveryRequest => 'درخواست تحویل';

  @override
  String get pickup => 'مبدا';

  @override
  String get dropoff => 'مقصد';

  @override
  String get package => 'بسته';

  @override
  String get recipient => 'گیرنده';

  @override
  String get decline => 'رد کردن';

  @override
  String get accept => 'پذیرفتن';

  @override
  String get goOnline => 'آنلاین شوید';

  @override
  String get goOffline => 'آفلاین شوید';

  @override
  String get confirmPackagePickup => 'تایید گرفتن بسته';

  @override
  String get arrivedForPickup => 'به مبدا رسیدم';

  @override
  String get startDelivery => 'شروع تحویل';

  @override
  String get startRide => 'شروع سفر';

  @override
  String get confirmDropOff => 'تایید تحویل';

  @override
  String get completeRide => 'پایان سفر';

  @override
  String get cancelRide => 'لغو سفر';

  @override
  String get passengerInfo => 'اطلاعات مسافر';

  @override
  String get recipientInfo => 'اطلاعات گیرنده';

  @override
  String get senderInfo => 'اطلاعات فرستنده';

  @override
  String get rideHistory => 'تاریخچه سفرها';

  @override
  String get noPastRides => 'سفر گذشته‌ای وجود ندارد';

  @override
  String get pastRidesMessage =>
      'سفرهای تکمیل شده شما در اینجا نمایش داده می‌شود.';

  @override
  String from(String address) {
    return 'از: $address';
  }

  @override
  String get statusSearching => 'در جستجوی راننده';

  @override
  String get statusDriverOnWay => 'راننده در راه است';

  @override
  String get statusDriverArrived => 'راننده رسیده است';

  @override
  String get statusInProgress => 'در راه به مقصد';

  @override
  String get statusCompleted => 'تکمیل شده';

  @override
  String get statusCancelled => 'لغو شده';

  @override
  String get selectLanguage => 'زبان را انتخاب کنید';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDari => 'دری';

  @override
  String get continueButton => 'ادامه';

  @override
  String get rateYourRide => 'سفر خود را ارزیابی کنید';

  @override
  String howWasYourTripWith(String driverName) {
    return 'سفر شما با $driverName چگونه بود؟';
  }

  @override
  String get addAComment => 'نظر خود را اضافه کنید...';

  @override
  String get submitRating => 'ثبت ارزیابی';

  @override
  String get skip => 'رد کردن';

  @override
  String get profilePicture => 'تصویر پروفایل';

  @override
  String get chooseYourRide => 'سفر خود را انتخاب کنید';

  @override
  String get availableNearby => 'در این نزدیکی موجود است';

  @override
  String get deliveryService => 'خدمات تحویل';

  @override
  String get motorbikeDelivery => 'تحویل با موتورسیکلت';

  @override
  String get deliveryDetailsTitle => 'جزئیات تحویل';

  @override
  String get recipientNameLabel => 'نام گیرنده';

  @override
  String get recipientNamePlaceholder => 'نام کامل گیرنده را وارد کنید';

  @override
  String get recipientNameError => 'نام الزامی است';

  @override
  String get recipientPhoneLabel => 'شماره تلفن';

  @override
  String get recipientPhonePlaceholder => 'شماره تلفن گیرنده را وارد کنید';

  @override
  String get recipientPhoneError => 'شماره تلفن الزامی است';

  @override
  String get packageDescriptionLabel => 'توضیحات بسته';

  @override
  String get packageDescriptionPlaceholder =>
      'توضیح دهید چه چیزی ارسال می‌کنید';

  @override
  String get packageDescriptionError => 'توضیحات بسته الزامی است';

  @override
  String get fragilePackageLabel => 'بسته شکستنی';

  @override
  String get handleWithCare => 'با احتیاط حمل شود';

  @override
  String requestDeliveryButton(String price) {
    return 'درخواست تحویل • $price';
  }

  @override
  String get settingUpDriver => 'تنظیم پروفایل راننده تان...';

  @override
  String get weNeedLocationMatch =>
      'ما به موقعیت شما نیاز داریم تا شما را با سوارکاران مطابقت دهد.';

  @override
  String get locationDetails => 'دریافت جزئیات موقعیت...';

  @override
  String get tripCompleted => 'سفر تکمیل شد!';

  @override
  String get finalPrice => 'قیمت نهایی';

  @override
  String get close => 'بستن';

  @override
  String navigateTo(String targetName) {
    return 'رفتن به $targetName';
  }

  @override
  String get chooseNavigationApp => 'اپلیکیشن مسیریابی خود را انتخاب کنید';

  @override
  String get googleMaps => 'نقشه گوگل';

  @override
  String get appleMaps => 'نقشه اپل';

  @override
  String get yandexMaps => 'نقشه یاندکس';

  @override
  String errorOpeningNavigation(String error) {
    return 'خطا در باز کردن مسیریاب: $error';
  }

  @override
  String couldNotOpenGoogleMaps(String error) {
    return 'امکان باز کردن نقشه گوگل وجود ندارد: $error';
  }

  @override
  String get appleMapsNotAvailable => 'نقشه اپل در دسترس نیست';

  @override
  String couldNotOpenAppleMaps(String error) {
    return 'امکان باز کردن نقشه اپل وجود ندارد: $error';
  }

  @override
  String get searchingLocations => 'جستجوی مکان ها...';

  @override
  String get moveMapToSelectLocation =>
      'نقشه را حرکت دهید تا مکان را انتخاب کنید';

  @override
  String get destination => 'مقصد';

  @override
  String get profile => 'پروفایل';

  @override
  String get editProfile => 'ویرایش پروفایل';

  @override
  String get saveChanges => 'ذخیره تغییرات';

  @override
  String get logout => 'خروج';

  @override
  String get deleteAccount => 'حذف حساب کاربری';

  @override
  String get deleteAccountConfirmationTitle => 'حذف حساب کاربری؟';

  @override
  String get deleteAccountConfirmationMessage =>
      'آیا مطمئن هستید که می‌خواهید حساب کاربری خود را برای همیشه حذف کنید؟ این عمل قابل بازگشت نیست.';

  @override
  String get actionDelete => 'حذف';

  @override
  String get profileUpdateSuccess => 'پروفایل با موفقیت به‌روزرسانی شد!';

  @override
  String get profileUpdateFailed => 'به‌روزرسانی پروفایل ناموفق بود';

  @override
  String get accountDeletionSuccess => 'حساب کاربری با موفقیت حذف شد.';

  @override
  String get accountDeletionFailed => 'حذف حساب کاربری ناموفق بود.';

  @override
  String get whereWouldYouLikeToGo => 'شما میخواهید کجا بروید؟';

  @override
  String get searchForDestination => 'جستجوی مقصد';

  @override
  String get personalInformation => 'معلومات شخصی';

  @override
  String get tapToChangePhoto => 'برای تغییر عکس ضربه بزنید';

  @override
  String get locationServicesDisabled => 'خدمات موقعیت غیرفعال شده است';

  @override
  String get pleaseEnableLocation =>
      'لطفاً خدمات موقعیت را برای دریافت درخواست های سواری فعال کنید.';

  @override
  String get settings => 'تنظیمات';

  @override
  String get locationPermission => 'اجازه موقعیت';

  @override
  String get thisAppNeedsLocation =>
      'این اپلیکیشن برای فعالیت نیاز به اجازه موقعیت دارد. لطفاً در تنظیمات اجازه بدهید.';

  @override
  String get byCreatingAccountYouAgree =>
      'با ایجاد یک حساب کاربری ، شما با ما موافقت می کنید';

  @override
  String get privacyPolicy => 'سیاست حفظ حریم خصوصی';

  @override
  String get legal => 'اطلاعات حقوقی';

  @override
  String get privacyPolicyDescription => 'بررسی شرایط پردازش داده ها';

  @override
  String get locationAccessTitle => 'دسترسی به مکان';

  @override
  String get locationAccessMessageClient =>
      'Safar One داده های مکان را جمع آوری می کند تا رانندگان نزدیک را برای شما پیدا کند ، مسیرها را تعیین کند و سفر شما را ردیابی کند. این برای کار سرویس ضروری است.';

  @override
  String get locationAccessMessageDriver =>
      'Safar One داده های مکان را جمع آوری می کند تا سفارشات نزدیک را به شما ارائه دهد ، مسیرها را تنظیم کند و مکان خود را به مشتری نشان دهد. برای کار ضروری است.';

  @override
  String get locationDataUsage => 'چگونه از موقعیت مکانی شما استفاده می‌کنیم:';

  @override
  String get locationUsageMatching => 'شما را با رانندگان نزدیک مطابقت دهیم';

  @override
  String get locationUsageTracking => 'سفر شما را به صورت زنده ردیابی کنیم';

  @override
  String get locationUsageSharing =>
      'موقعیت شما را با راننده به اشتراک بگذاریم';

  @override
  String get locationUsageRouting => 'مسیرهای بهینه را محاسبه کنیم';

  @override
  String get privacyPolicyPrefix => 'بخوانید ';

  @override
  String get whereToGo => 'Where to?';

  @override
  String get selectRideType => 'Select Ride Type';

  @override
  String get searchingForDrivers => 'Searching for drivers...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String minAway(int minutes) {
    return '$minutes min away';
  }

  @override
  String get driverHasArrived => 'Driver has arrived';

  @override
  String minRemaining(int minutes) {
    return '$minutes min remaining';
  }

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get pleaseEnableLocationAccess =>
      'Please enable location access to use this feature.';

  @override
  String get rideAccepted => 'Ride Accepted';

  @override
  String get driverIsOnTheWay => 'Driver is on the way';

  @override
  String get okay => 'Okay';

  @override
  String get areYouSureYouWantToCancelThisRide =>
      'Are you sure you want to cancel this ride?';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get receivingRideRequests => 'Receiving ride requests';

  @override
  String get notReceivingRequests => 'Not receiving requests';

  @override
  String get newRideRequest => 'New Ride Request';

  @override
  String get arriveAtPickup => 'Arrive at Pickup';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get save => 'Save';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get retry => 'Retry';
}
