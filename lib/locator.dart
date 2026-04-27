import 'package:family_tracker/data/repositories/auth_repository_impl.dart';
import 'package:family_tracker/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  /// external services
  locator.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  locator.registerLazySingleton<ImagePicker>(() => ImagePicker());

  // data sources

  ///repositories  
   locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<SupabaseClient>())
  );
}