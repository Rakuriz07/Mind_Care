import 'package:flutter_test/flutter_test.dart';
import 'package:mindcare/database/app_database.dart';
import 'package:mindcare/services/app_state_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Registration Data Persistence Tests', () {
    test('Registering a new patient persists user data in AppDatabase', () async {
      await AppDatabase.instance.init();

      final testEmail = 'test_user_${DateTime.now().millisecondsSinceEpoch}@mindcare.id';
      final testName = 'Budi Santoso';
      final testPassword = 'password123';

      final res = await AppStateService.instance.registerPatient(
        name: testName,
        email: testEmail,
        password: testPassword,
        phone: '+62 812 9999 8888',
      );

      expect(res['success'], isTrue);
      expect(AppStateService.instance.userProfile.email, equals(testEmail));
      expect(AppStateService.instance.userProfile.name, equals(testName));
      expect(AppStateService.instance.isLoggedIn, isTrue);

      // Verify profile loaded from AppDatabase matches registered data
      final profile = AppDatabase.instance.getUserProfile();
      expect(profile.email, equals(testEmail));
      expect(profile.name, equals(testName));
    });

    test('Registered user can successfully log out and log back in', () async {
      await AppDatabase.instance.init();

      final testEmail = 'login_test_${DateTime.now().millisecondsSinceEpoch}@mindcare.id';
      final testName = 'Siti Rahma';
      final testPassword = 'securePass123';

      // 1. Register
      final regRes = await AppStateService.instance.registerPatient(
        name: testName,
        email: testEmail,
        password: testPassword,
      );
      expect(regRes['success'], isTrue);

      // 2. Logout
      await AppStateService.instance.logout();
      expect(AppStateService.instance.isLoggedIn, isFalse);

      // 3. Login
      final loginRes = await AppStateService.instance.loginPatient(
        email: testEmail,
        password: testPassword,
      );
      expect(loginRes['success'], isTrue);
      expect(AppStateService.instance.isLoggedIn, isTrue);
      expect(AppStateService.instance.userProfile.email, equals(testEmail));
    });
  });
}
