import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Safar One'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @letsGetYouStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get letsGetYouStarted;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @iAmA.
  ///
  /// In en, this message translates to:
  /// **'I am a...'**
  String get iAmA;

  /// No description provided for @userTypeClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get userTypeClient;

  /// No description provided for @userTypeDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get userTypeDriver;

  /// No description provided for @vehicleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetailsTitle;

  /// No description provided for @vehicleModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModelLabel;

  /// No description provided for @licensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlateLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleTypeLabel;

  /// No description provided for @vehicleTypeSedan.
  ///
  /// In en, this message translates to:
  /// **'Sedan'**
  String get vehicleTypeSedan;

  /// No description provided for @vehicleTypeSuv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get vehicleTypeSuv;

  /// No description provided for @vehicleTypeHatchback.
  ///
  /// In en, this message translates to:
  /// **'Hatchback'**
  String get vehicleTypeHatchback;

  /// No description provided for @vehicleTypeMinivan.
  ///
  /// In en, this message translates to:
  /// **'Minivan'**
  String get vehicleTypeMinivan;

  /// No description provided for @vehicleTypeTukTuk.
  ///
  /// In en, this message translates to:
  /// **'Tuk-tuk'**
  String get vehicleTypeTukTuk;

  /// No description provided for @vehicleTypeMotorbike.
  ///
  /// In en, this message translates to:
  /// **'Motorbike'**
  String get vehicleTypeMotorbike;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get dontHaveAccount;

  /// No description provided for @emailValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get emailValidationError;

  /// No description provided for @passwordValidationError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordValidationError;

  /// No description provided for @nameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get nameValidationError;

  /// No description provided for @phoneValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter phone'**
  String get phoneValidationError;

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// No description provided for @ride.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get ride;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @driverResponding.
  ///
  /// In en, this message translates to:
  /// **'Driver responding...'**
  String get driverResponding;

  /// No description provided for @searchingWaitMessage.
  ///
  /// In en, this message translates to:
  /// **'This usually takes a few seconds'**
  String get searchingWaitMessage;

  /// No description provided for @arrivingIn.
  ///
  /// In en, this message translates to:
  /// **'Arriving in ~{minutes} min'**
  String arrivingIn(int minutes);

  /// No description provided for @freeWaitTime.
  ///
  /// In en, this message translates to:
  /// **'Free wait time: {time}'**
  String freeWaitTime(String time);

  /// No description provided for @meetDriverAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Meet driver at the pickup point'**
  String get meetDriverAtPickup;

  /// No description provided for @minutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String minutesLeft(int minutes);

  /// No description provided for @onTheWayToDestination.
  ///
  /// In en, this message translates to:
  /// **'On the way to destination'**
  String get onTheWayToDestination;

  /// No description provided for @onMyWay.
  ///
  /// In en, this message translates to:
  /// **'On my way'**
  String get onMyWay;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @locationAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Access Required'**
  String get locationAccessRequired;

  /// No description provided for @locationAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'We need access to your location to find rides and show your position on the map.'**
  String get locationAccessMessage;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @requestRide.
  ///
  /// In en, this message translates to:
  /// **'Request {rideName}'**
  String requestRide(String rideName);

  /// No description provided for @requestDelivery.
  ///
  /// In en, this message translates to:
  /// **'Request Delivery ({price})'**
  String requestDelivery(String price);

  /// No description provided for @chooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get chooseDestination;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @selectOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select on Map'**
  String get selectOnMap;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @confirmDestination.
  ///
  /// In en, this message translates to:
  /// **'Confirm Destination'**
  String get confirmDestination;

  /// No description provided for @routeInfo.
  ///
  /// In en, this message translates to:
  /// **'{distance} km · {duration} min'**
  String routeInfo(String distance, int duration);

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @recipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient\'s Name'**
  String get recipientName;

  /// No description provided for @recipientPhone.
  ///
  /// In en, this message translates to:
  /// **'Recipient\'s Phone'**
  String get recipientPhone;

  /// No description provided for @packageDetails.
  ///
  /// In en, this message translates to:
  /// **'Package details (e.g., documents)'**
  String get packageDetails;

  /// No description provided for @fragilePackage.
  ///
  /// In en, this message translates to:
  /// **'Fragile Package?'**
  String get fragilePackage;

  /// No description provided for @youAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re online'**
  String get youAreOnline;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get youAreOffline;

  /// No description provided for @headingToPickup.
  ///
  /// In en, this message translates to:
  /// **'Heading to pickup'**
  String get headingToPickup;

  /// No description provided for @headingToPickupPackage.
  ///
  /// In en, this message translates to:
  /// **'Heading to pickup package'**
  String get headingToPickupPackage;

  /// No description provided for @arrivedAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Arrived at pickup'**
  String get arrivedAtPickup;

  /// No description provided for @arrivedForPackagePickup.
  ///
  /// In en, this message translates to:
  /// **'Arrived for package pickup'**
  String get arrivedForPackagePickup;

  /// No description provided for @onTrip.
  ///
  /// In en, this message translates to:
  /// **'On trip'**
  String get onTrip;

  /// No description provided for @deliveringPackage.
  ///
  /// In en, this message translates to:
  /// **'Delivering package'**
  String get deliveringPackage;

  /// No description provided for @onARide.
  ///
  /// In en, this message translates to:
  /// **'On a ride'**
  String get onARide;

  /// No description provided for @tripRequest.
  ///
  /// In en, this message translates to:
  /// **'Trip Request'**
  String get tripRequest;

  /// No description provided for @deliveryRequest.
  ///
  /// In en, this message translates to:
  /// **'Delivery Request'**
  String get deliveryRequest;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'PICKUP'**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In en, this message translates to:
  /// **'DROPOFF'**
  String get dropoff;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'PACKAGE'**
  String get package;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'RECIPIENT'**
  String get recipient;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @goOnline.
  ///
  /// In en, this message translates to:
  /// **'Go Online'**
  String get goOnline;

  /// No description provided for @goOffline.
  ///
  /// In en, this message translates to:
  /// **'Go Offline'**
  String get goOffline;

  /// No description provided for @confirmPackagePickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Package Pickup'**
  String get confirmPackagePickup;

  /// No description provided for @arrivedForPickup.
  ///
  /// In en, this message translates to:
  /// **'Arrived for Pickup'**
  String get arrivedForPickup;

  /// No description provided for @startDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start Delivery'**
  String get startDelivery;

  /// No description provided for @startRide.
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get startRide;

  /// No description provided for @confirmDropOff.
  ///
  /// In en, this message translates to:
  /// **'Confirm Drop-off'**
  String get confirmDropOff;

  /// No description provided for @completeRide.
  ///
  /// In en, this message translates to:
  /// **'Complete Ride'**
  String get completeRide;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRide;

  /// No description provided for @passengerInfo.
  ///
  /// In en, this message translates to:
  /// **'Passenger Info'**
  String get passengerInfo;

  /// No description provided for @recipientInfo.
  ///
  /// In en, this message translates to:
  /// **'Recipient Info'**
  String get recipientInfo;

  /// No description provided for @senderInfo.
  ///
  /// In en, this message translates to:
  /// **'Sender Info'**
  String get senderInfo;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// No description provided for @noPastRides.
  ///
  /// In en, this message translates to:
  /// **'No Past Rides'**
  String get noPastRides;

  /// No description provided for @pastRidesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your completed rides will appear here.'**
  String get pastRidesMessage;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From: {address}'**
  String from(String address);

  /// No description provided for @statusSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for driver'**
  String get statusSearching;

  /// No description provided for @statusDriverOnWay.
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get statusDriverOnWay;

  /// No description provided for @statusDriverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get statusDriverArrived;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'On the way to destination'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageDari.
  ///
  /// In en, this message translates to:
  /// **'دری'**
  String get languageDari;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @rateYourRide.
  ///
  /// In en, this message translates to:
  /// **'Rate your ride'**
  String get rateYourRide;

  /// No description provided for @howWasYourTripWith.
  ///
  /// In en, this message translates to:
  /// **'How was your trip with {driverName}?'**
  String howWasYourTripWith(String driverName);

  /// No description provided for @addAComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addAComment;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @chooseYourRide.
  ///
  /// In en, this message translates to:
  /// **'Choose your ride'**
  String get chooseYourRide;

  /// No description provided for @availableNearby.
  ///
  /// In en, this message translates to:
  /// **'Available nearby'**
  String get availableNearby;

  /// No description provided for @deliveryService.
  ///
  /// In en, this message translates to:
  /// **'Delivery Service'**
  String get deliveryService;

  /// No description provided for @motorbikeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Motorbike delivery'**
  String get motorbikeDelivery;

  /// No description provided for @deliveryDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetailsTitle;

  /// No description provided for @recipientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get recipientNameLabel;

  /// No description provided for @recipientNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter recipient\'s full name'**
  String get recipientNamePlaceholder;

  /// No description provided for @recipientNameError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get recipientNameError;

  /// No description provided for @recipientPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get recipientPhoneLabel;

  /// No description provided for @recipientPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter recipient\'s phone number'**
  String get recipientPhonePlaceholder;

  /// No description provided for @recipientPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get recipientPhoneError;

  /// No description provided for @packageDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Package Description'**
  String get packageDescriptionLabel;

  /// No description provided for @packageDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe what you\'re sending'**
  String get packageDescriptionPlaceholder;

  /// No description provided for @packageDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Package description is required'**
  String get packageDescriptionError;

  /// No description provided for @fragilePackageLabel.
  ///
  /// In en, this message translates to:
  /// **'Fragile Package'**
  String get fragilePackageLabel;

  /// No description provided for @handleWithCare.
  ///
  /// In en, this message translates to:
  /// **'Handle with extra care'**
  String get handleWithCare;

  /// No description provided for @requestDeliveryButton.
  ///
  /// In en, this message translates to:
  /// **'Request Delivery • {price}'**
  String requestDeliveryButton(String price);

  /// No description provided for @settingUpDriver.
  ///
  /// In en, this message translates to:
  /// **'Setting up your driver profile...'**
  String get settingUpDriver;

  /// No description provided for @weNeedLocationMatch.
  ///
  /// In en, this message translates to:
  /// **'We need your location to match you with riders.'**
  String get weNeedLocationMatch;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Getting location details...'**
  String get locationDetails;

  /// No description provided for @tripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get tripCompleted;

  /// No description provided for @finalPrice.
  ///
  /// In en, this message translates to:
  /// **'Final Price'**
  String get finalPrice;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button text to navigate to a given location
  ///
  /// In en, this message translates to:
  /// **'Navigate to {targetName}'**
  String navigateTo(String targetName);

  /// No description provided for @chooseNavigationApp.
  ///
  /// In en, this message translates to:
  /// **'Choose your navigation app'**
  String get chooseNavigationApp;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @appleMaps.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get appleMaps;

  /// No description provided for @yandexMaps.
  ///
  /// In en, this message translates to:
  /// **'Yandex Maps'**
  String get yandexMaps;

  /// No description provided for @errorOpeningNavigation.
  ///
  /// In en, this message translates to:
  /// **'Error opening navigation: {error}'**
  String errorOpeningNavigation(String error);

  /// No description provided for @couldNotOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps: {error}'**
  String couldNotOpenGoogleMaps(String error);

  /// No description provided for @appleMapsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps not available'**
  String get appleMapsNotAvailable;

  /// No description provided for @couldNotOpenAppleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Apple Maps: {error}'**
  String couldNotOpenAppleMaps(String error);

  /// No description provided for @searchingLocations.
  ///
  /// In en, this message translates to:
  /// **'Searching locations...'**
  String get searchingLocations;

  /// Hint shown when user should move the map to pick a location
  ///
  /// In en, this message translates to:
  /// **'Move the map to select a location'**
  String get moveMapToSelectLocation;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirmationTitle;

  /// No description provided for @deleteAccountConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmationMessage;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @accountDeletionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletionSuccess;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account.'**
  String get accountDeletionFailed;

  /// No description provided for @whereWouldYouLikeToGo.
  ///
  /// In en, this message translates to:
  /// **'Where would you like to go?'**
  String get whereWouldYouLikeToGo;

  /// No description provided for @searchForDestination.
  ///
  /// In en, this message translates to:
  /// **'Search for a destination'**
  String get searchForDestination;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get locationServicesDisabled;

  /// No description provided for @pleaseEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services to receive ride requests.'**
  String get pleaseEnableLocation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermission;

  /// No description provided for @thisAppNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'This app needs location permission to function. Please grant permission in settings.'**
  String get thisAppNeedsLocation;

  /// No description provided for @byCreatingAccountYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our '**
  String get byCreatingAccountYouAgree;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal information'**
  String get legal;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the terms of data processing'**
  String get privacyPolicyDescription;

  /// No description provided for @locationAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationAccessTitle;

  /// No description provided for @locationAccessMessageClient.
  ///
  /// In en, this message translates to:
  /// **'Safar One collects location data to find nearby drivers for you, set routes, and track your trip. This is necessary for the service to work.'**
  String get locationAccessMessageClient;

  /// No description provided for @locationAccessMessageDriver.
  ///
  /// In en, this message translates to:
  /// **'Safar One collects location data to offer you orders nearby, set routes, and show your location to the customer. It is necessary for work.'**
  String get locationAccessMessageDriver;

  /// No description provided for @locationDataUsage.
  ///
  /// In en, this message translates to:
  /// **'How we use your location:'**
  String get locationDataUsage;

  /// No description provided for @locationUsageMatching.
  ///
  /// In en, this message translates to:
  /// **'Match you with nearby drivers'**
  String get locationUsageMatching;

  /// No description provided for @locationUsageTracking.
  ///
  /// In en, this message translates to:
  /// **'Track your ride in real-time'**
  String get locationUsageTracking;

  /// No description provided for @locationUsageSharing.
  ///
  /// In en, this message translates to:
  /// **'Share your location with your driver'**
  String get locationUsageSharing;

  /// No description provided for @locationUsageRouting.
  ///
  /// In en, this message translates to:
  /// **'Calculate optimal routes'**
  String get locationUsageRouting;

  /// No description provided for @privacyPolicyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Read our '**
  String get privacyPolicyPrefix;

  /// No description provided for @whereToGo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereToGo;

  /// No description provided for @selectRideType.
  ///
  /// In en, this message translates to:
  /// **'Select Ride Type'**
  String get selectRideType;

  /// No description provided for @searchingForDrivers.
  ///
  /// In en, this message translates to:
  /// **'Searching for drivers...'**
  String get searchingForDrivers;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @minAway.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min away'**
  String minAway(int minutes);

  /// No description provided for @driverHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get driverHasArrived;

  /// No description provided for @minRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min remaining'**
  String minRemaining(int minutes);

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @pleaseEnableLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Please enable location access to use this feature.'**
  String get pleaseEnableLocationAccess;

  /// No description provided for @rideAccepted.
  ///
  /// In en, this message translates to:
  /// **'Ride Accepted'**
  String get rideAccepted;

  /// No description provided for @driverIsOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way'**
  String get driverIsOnTheWay;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @areYouSureYouWantToCancelThisRide.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride?'**
  String get areYouSureYouWantToCancelThisRide;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @receivingRideRequests.
  ///
  /// In en, this message translates to:
  /// **'Receiving ride requests'**
  String get receivingRideRequests;

  /// No description provided for @notReceivingRequests.
  ///
  /// In en, this message translates to:
  /// **'Not receiving requests'**
  String get notReceivingRequests;

  /// No description provided for @newRideRequest.
  ///
  /// In en, this message translates to:
  /// **'New Ride Request'**
  String get newRideRequest;

  /// No description provided for @arriveAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Arrive at Pickup'**
  String get arriveAtPickup;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
