// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:haus_app/core/network/network_info.dart' as _i1062;
import 'package:haus_app/core/services/avatar_service.dart' as _i601;
import 'package:haus_app/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i1054;
import 'package:haus_app/features/auth/data/repositories/auth_repository_impl.dart'
    as _i834;
import 'package:haus_app/features/auth/domain/repositories/auth_repository.dart'
    as _i1039;
import 'package:haus_app/features/auth/domain/usecases/get_current_user.dart'
    as _i118;
import 'package:haus_app/features/auth/domain/usecases/reset_password.dart'
    as _i873;
import 'package:haus_app/features/auth/domain/usecases/sign_in.dart' as _i1023;
import 'package:haus_app/features/auth/domain/usecases/sign_out.dart' as _i964;
import 'package:haus_app/features/auth/domain/usecases/sign_up.dart' as _i602;
import 'package:haus_app/features/auth/presentation/bloc/auth_bloc.dart'
    as _i596;
import 'package:haus_app/features/listings/data/datasources/listing_remote_data_source.dart'
    as _i946;
import 'package:haus_app/features/listings/data/repositories/listing_repository_impl.dart'
    as _i521;
import 'package:haus_app/features/listings/domain/repositories/listing_repository.dart'
    as _i851;
import 'package:haus_app/features/listings/domain/usecases/create_listing.dart'
    as _i1018;
import 'package:haus_app/features/listings/domain/usecases/delete_listing.dart'
    as _i662;
import 'package:haus_app/features/listings/domain/usecases/get_listings.dart'
    as _i868;
import 'package:haus_app/features/listings/presentation/bloc/listing_bloc.dart'
    as _i487;
import 'package:haus_app/features/locations/data/datasources/location_remote_data_source.dart'
    as _i408;
import 'package:haus_app/features/locations/data/repositories/location_repository_impl.dart'
    as _i456;
import 'package:haus_app/features/locations/domain/repositories/location_repository.dart'
    as _i792;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i1062.NetworkInfo>(
        () => _i1062.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i1054.AuthRemoteDataSource>(
        () => _i1054.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i946.ListingRemoteDataSource>(
        () => _i946.ListingRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i601.AvatarService>(
        () => _i601.AvatarServiceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i851.ListingRepository>(
        () => _i521.ListingRepositoryImpl(gh<_i946.ListingRemoteDataSource>()));
    gh.lazySingleton<_i408.LocationRemoteDataSource>(
        () => _i408.LocationRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i1018.CreateListing>(
        () => _i1018.CreateListing(gh<_i851.ListingRepository>()));
    gh.lazySingleton<_i662.DeleteListing>(
        () => _i662.DeleteListing(gh<_i851.ListingRepository>()));
    gh.lazySingleton<_i868.GetListings>(
        () => _i868.GetListings(gh<_i851.ListingRepository>()));
    gh.lazySingleton<_i792.LocationRepository>(
        () => _i456.LocationRepositoryImpl(
              remoteDataSource: gh<_i408.LocationRemoteDataSource>(),
              networkInfo: gh<_i1062.NetworkInfo>(),
            ));
    gh.lazySingleton<_i1039.AuthRepository>(() => _i834.AuthRepositoryImpl(
          remoteDataSource: gh<_i1054.AuthRemoteDataSource>(),
          networkInfo: gh<_i1062.NetworkInfo>(),
        ));
    gh.factory<_i487.ListingBloc>(() => _i487.ListingBloc(
          createListing: gh<_i1018.CreateListing>(),
          getListings: gh<_i868.GetListings>(),
          deleteListing: gh<_i662.DeleteListing>(),
        ));
    gh.factory<_i118.GetCurrentUser>(
        () => _i118.GetCurrentUser(gh<_i1039.AuthRepository>()));
    gh.factory<_i873.ResetPassword>(
        () => _i873.ResetPassword(gh<_i1039.AuthRepository>()));
    gh.factory<_i1023.SignIn>(() => _i1023.SignIn(gh<_i1039.AuthRepository>()));
    gh.factory<_i964.SignOut>(() => _i964.SignOut(gh<_i1039.AuthRepository>()));
    gh.factory<_i602.SignUp>(() => _i602.SignUp(gh<_i1039.AuthRepository>()));
    gh.factory<_i596.AuthBloc>(() => _i596.AuthBloc(
          signIn: gh<_i1023.SignIn>(),
          signUp: gh<_i602.SignUp>(),
          resetPassword: gh<_i873.ResetPassword>(),
          signOut: gh<_i964.SignOut>(),
          getCurrentUser: gh<_i118.GetCurrentUser>(),
          authRepository: gh<_i1039.AuthRepository>(),
        ));
    return this;
  }
}
