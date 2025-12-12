import 'package:flutter_chatter_hub/config/router.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/core/services/snackbar_service.dart';
import 'package:flutter_chatter_hub/core/services/storage_service.dart';
import 'package:get_it/get_it.dart';

///
/// GetIt instance to be used as a service locator
///
final injector = GetIt.I;

///
/// Inject all the dependencies to getIt
///
Future<void> initializeDependencies() async {
  // Whether to allow reassignment of a dependency
  injector.allowReassignment = true;

  /* ----------------------------------- APP ---------------------------------- */
  // Create the shared preferences object
  final sharedPref = SharedPref();
  // initialze the shared preferences
  await sharedPref.init();
  // initialize the deep link service
  injector.registerSingleton<SharedPref>(sharedPref);
  injector.registerSingleton<AppRoutesName>(AppRoutesName());
  injector.registerSingleton<AppRouter>(AppRouter());
  injector.registerSingleton<SnackBarService>(SnackBarService());
  injector.registerSingleton<FirebaseStorageService>(FirebaseStorageService());
  injector.registerSingleton<FirebaseFirestoreService>(FirebaseFirestoreService());
}
