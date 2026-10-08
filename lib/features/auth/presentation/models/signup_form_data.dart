import '../../../../core/legal/legal_links.dart';
import '../../../../core/extensions/extensions.dart';

class SignUpFormData {
  // Step 1: Personal Info
  String fullName = '';
  String email = '';
  String phone = '';
  String password = '';
  String identificationNumber = '';
  String identificationType = 'cedula'; // cedula, pasaporte, licencia

  // Step 2: Vehicle Info
  String vehicleType = 'moto'; // moto, bicicleta, auto
  String licensePlate = '';
  String licenseNumber = '';

  // Step 3: Banking & Address
  String address = '';
  String bankAccount = '';

  // Step 4: Permissions & Terms
  bool locationEnabled = false;
  bool notificationsEnabled = false;
  bool acceptedTerms = false;

  // Validation methods
  bool isStep1Valid() {
    if (fullName.isEmpty) return false;
    if (!email.isValidEmail) return false;
    if (!phone.isValidPhone) return false;
    if (identificationNumber.isEmpty) return false;
    if (!identificationNumber.isValidIdentificationNumber) return false;
    if (!password.isStrongPassword) return false;
    return true;
  }

  bool isStep2Valid() {
    if (vehicleType != 'bicicleta' && licensePlate.isEmpty) return false;
    if (vehicleType != 'bicicleta' && !licensePlate.isValidLicensePlate) return false;
    if (licenseNumber.isEmpty) return false;
    if (!licenseNumber.isValidLicenseNumber) return false;
    return true;
  }

  bool isStep3Valid() {
    if (!address.isValidAddress) return false;
    if (bankAccount.isEmpty) return false;
    if (!bankAccount.isValidIban) return false;
    return true;
  }

  bool isStep4Valid() {
    if (!acceptedTerms) return false;
    if (!locationEnabled && !notificationsEnabled) return false;
    return true;
  }

  Map<String, dynamic> toMetadata() {
    return {
      'fullName': fullName,
      'phone': phone,
      'identificationNumber': identificationNumber,
      'identificationType': identificationType,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
      'licenseNumber': licenseNumber,
      'address': address,
      'bankAccount': bankAccount,
      'locationEnabled': locationEnabled,
      'notificationsEnabled': notificationsEnabled,
      // Evidencia del consentimiento (Ley 29733): qué aceptó, cuándo y qué versión.
      'terms_accepted_at': DateTime.now().toUtc().toIso8601String(),
      'legal_texts_version': LegalLinks.textsVersion,
    };
  }

  Map<String, dynamic> toProfileData(String userId) {
    return {
      'id': userId,
      'full_name': fullName,
      'role': 'driver',
      'phone': phone,
      'address': address,
      'identification_number': identificationNumber,
      'identification_type': identificationType,
      'notifications_enabled': notificationsEnabled,
      'location_enabled': locationEnabled,
    };
  }

  Map<String, dynamic> toDriverData(String userId) {
    return {
      'user_id': userId,
      'vehicle_type': vehicleType,
      'license_plate': licensePlate,
      'license_number': licenseNumber,
      'bank_account': bankAccount,
      'status': 'offline',
      'is_active': true,
      'is_verified': false,
    };
  }
}
