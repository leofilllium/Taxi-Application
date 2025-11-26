// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Safar One';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get letsGetYouStarted => 'Let\'s get you started';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get iAmA => 'I am a...';

  @override
  String get userTypeClient => 'Client';

  @override
  String get userTypeDriver => 'Driver';

  @override
  String get vehicleDetailsTitle => 'Vehicle Details';

  @override
  String get vehicleModelLabel => 'Vehicle Model';

  @override
  String get licensePlateLabel => 'License Plate';

  @override
  String get colorLabel => 'Color';

  @override
  String get yearLabel => 'Year';

  @override
  String get vehicleTypeLabel => 'Vehicle Type';

  @override
  String get vehicleTypeSedan => 'Sedan';

  @override
  String get vehicleTypeSuv => 'SUV';

  @override
  String get vehicleTypeHatchback => 'Hatchback';

  @override
  String get vehicleTypeMinivan => 'Minivan';

  @override
  String get vehicleTypeTukTuk => 'Tuk-tuk';

  @override
  String get vehicleTypeMotorbike => 'Motorbike';

  @override
  String get signInButton => 'Sign In';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get dontHaveAccount => 'Create an account';

  @override
  String get emailValidationError => 'Enter email';

  @override
  String get passwordValidationError =>
      'Password must be at least 6 characters';

  @override
  String get nameValidationError => 'Enter name';

  @override
  String get phoneValidationError => 'Enter phone';

  @override
  String get whereTo => 'Where to?';

  @override
  String get ride => 'Ride';

  @override
  String get delivery => 'Delivery';

  @override
  String get cancel => 'Cancel';

  @override
  String get driverResponding => 'Driver responding...';

  @override
  String get searchingWaitMessage => 'This usually takes a few seconds';

  @override
  String arrivingIn(int minutes) {
    return 'Arriving in ~$minutes min';
  }

  @override
  String freeWaitTime(String time) {
    return 'Free wait time: $time';
  }

  @override
  String get meetDriverAtPickup => 'Meet driver at the pickup point';

  @override
  String minutesLeft(int minutes) {
    return '$minutes min left';
  }

  @override
  String get onTheWayToDestination => 'On the way to destination';

  @override
  String get onMyWay => 'On my way';

  @override
  String get safety => 'Safety';

  @override
  String get contact => 'Contact';

  @override
  String get locationAccessRequired => 'Location Access Required';

  @override
  String get locationAccessMessage =>
      'We need access to your location to find rides and show your position on the map.';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String requestRide(String rideName) {
    return 'Request $rideName';
  }

  @override
  String requestDelivery(String price) {
    return 'Request Delivery ($price)';
  }

  @override
  String get chooseDestination => 'Choose destination';

  @override
  String get search => 'Search';

  @override
  String get selectOnMap => 'Select on Map';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get confirmDestination => 'Confirm Destination';

  @override
  String routeInfo(String distance, int duration) {
    return '$distance km · $duration min';
  }

  @override
  String get deliveryDetails => 'Delivery Details';

  @override
  String get recipientName => 'Recipient\'s Name';

  @override
  String get recipientPhone => 'Recipient\'s Phone';

  @override
  String get packageDetails => 'Package details (e.g., documents)';

  @override
  String get fragilePackage => 'Fragile Package?';

  @override
  String get youAreOnline => 'You\'re online';

  @override
  String get youAreOffline => 'You\'re offline';

  @override
  String get headingToPickup => 'Heading to pickup';

  @override
  String get headingToPickupPackage => 'Heading to pickup package';

  @override
  String get arrivedAtPickup => 'Arrived at pickup';

  @override
  String get arrivedForPackagePickup => 'Arrived for package pickup';

  @override
  String get onTrip => 'On trip';

  @override
  String get deliveringPackage => 'Delivering package';

  @override
  String get onARide => 'On a ride';

  @override
  String get tripRequest => 'Trip Request';

  @override
  String get deliveryRequest => 'Delivery Request';

  @override
  String get pickup => 'PICKUP';

  @override
  String get dropoff => 'DROPOFF';

  @override
  String get package => 'PACKAGE';

  @override
  String get recipient => 'RECIPIENT';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get goOnline => 'Go Online';

  @override
  String get goOffline => 'Go Offline';

  @override
  String get confirmPackagePickup => 'Confirm Package Pickup';

  @override
  String get arrivedForPickup => 'Arrived for Pickup';

  @override
  String get startDelivery => 'Start Delivery';

  @override
  String get startRide => 'Start Ride';

  @override
  String get confirmDropOff => 'Confirm Drop-off';

  @override
  String get completeRide => 'Complete Ride';

  @override
  String get cancelRide => 'Cancel Ride';

  @override
  String get passengerInfo => 'Passenger Info';

  @override
  String get recipientInfo => 'Recipient Info';

  @override
  String get senderInfo => 'Sender Info';

  @override
  String get rideHistory => 'Ride History';

  @override
  String get noPastRides => 'No Past Rides';

  @override
  String get pastRidesMessage => 'Your completed rides will appear here.';

  @override
  String from(String address) {
    return 'From: $address';
  }

  @override
  String get statusSearching => 'Searching for driver';

  @override
  String get statusDriverOnWay => 'Driver on the way';

  @override
  String get statusDriverArrived => 'Driver has arrived';

  @override
  String get statusInProgress => 'On the way to destination';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDari => 'دری';

  @override
  String get continueButton => 'Continue';

  @override
  String get rateYourRide => 'Rate your ride';

  @override
  String howWasYourTripWith(String driverName) {
    return 'How was your trip with $driverName?';
  }

  @override
  String get addAComment => 'Add a comment...';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get skip => 'Skip';

  @override
  String get profilePicture => 'Profile Picture';

  @override
  String get chooseYourRide => 'Choose your ride';

  @override
  String get availableNearby => 'Available nearby';

  @override
  String get deliveryService => 'Delivery Service';

  @override
  String get motorbikeDelivery => 'Motorbike delivery';

  @override
  String get deliveryDetailsTitle => 'Delivery Details';

  @override
  String get recipientNameLabel => 'Recipient Name';

  @override
  String get recipientNamePlaceholder => 'Enter recipient\'s full name';

  @override
  String get recipientNameError => 'Name is required';

  @override
  String get recipientPhoneLabel => 'Phone Number';

  @override
  String get recipientPhonePlaceholder => 'Enter recipient\'s phone number';

  @override
  String get recipientPhoneError => 'Phone number is required';

  @override
  String get packageDescriptionLabel => 'Package Description';

  @override
  String get packageDescriptionPlaceholder => 'Describe what you\'re sending';

  @override
  String get packageDescriptionError => 'Package description is required';

  @override
  String get fragilePackageLabel => 'Fragile Package';

  @override
  String get handleWithCare => 'Handle with extra care';

  @override
  String requestDeliveryButton(String price) {
    return 'Request Delivery • $price';
  }

  @override
  String get settingUpDriver => 'Setting up your driver profile...';

  @override
  String get weNeedLocationMatch =>
      'We need your location to match you with riders.';

  @override
  String get locationDetails => 'Getting location details...';

  @override
  String get tripCompleted => 'Trip Completed!';

  @override
  String get finalPrice => 'Final Price';

  @override
  String get close => 'Close';

  @override
  String navigateTo(String targetName) {
    return 'Navigate to $targetName';
  }

  @override
  String get chooseNavigationApp => 'Choose your navigation app';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get yandexMaps => 'Yandex Maps';

  @override
  String errorOpeningNavigation(String error) {
    return 'Error opening navigation: $error';
  }

  @override
  String couldNotOpenGoogleMaps(String error) {
    return 'Could not open Google Maps: $error';
  }

  @override
  String get appleMapsNotAvailable => 'Apple Maps not available';

  @override
  String couldNotOpenAppleMaps(String error) {
    return 'Could not open Apple Maps: $error';
  }

  @override
  String get searchingLocations => 'Searching locations...';

  @override
  String get moveMapToSelectLocation => 'Move the map to select a location';

  @override
  String get destination => 'Destination';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmationTitle => 'Delete Account?';

  @override
  String get deleteAccountConfirmationMessage =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get actionDelete => 'Delete';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get accountDeletionSuccess => 'Account deleted successfully.';

  @override
  String get accountDeletionFailed => 'Failed to delete account.';

  @override
  String get whereWouldYouLikeToGo => 'Where would you like to go?';

  @override
  String get searchForDestination => 'Search for a destination';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get locationServicesDisabled => 'Location Services Disabled';

  @override
  String get pleaseEnableLocation =>
      'Please enable location services to receive ride requests.';

  @override
  String get settings => 'Settings';

  @override
  String get locationPermission => 'Location Permission';

  @override
  String get thisAppNeedsLocation =>
      'This app needs location permission to function. Please grant permission in settings.';

  @override
  String get byCreatingAccountYouAgree =>
      'By creating an account, you agree to our ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get legal => 'Legal information';

  @override
  String get privacyPolicyDescription => 'Review the terms of data processing';

  @override
  String get locationAccessTitle => 'Location Access';

  @override
  String get locationAccessMessageClient =>
      'Safar One collects location data to find nearby drivers for you, set routes, and track your trip. This is necessary for the service to work.';

  @override
  String get locationAccessMessageDriver =>
      'Safar One collects location data to offer you orders nearby, set routes, and show your location to the customer. It is necessary for work.';

  @override
  String get locationDataUsage => 'How we use your location:';

  @override
  String get locationUsageMatching => 'Match you with nearby drivers';

  @override
  String get locationUsageTracking => 'Track your ride in real-time';

  @override
  String get locationUsageSharing => 'Share your location with your driver';

  @override
  String get locationUsageRouting => 'Calculate optimal routes';

  @override
  String get privacyPolicyPrefix => 'Read our ';

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
