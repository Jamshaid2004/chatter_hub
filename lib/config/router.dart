import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/global/navigator_key.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/features/add_user/view/add_user_screen.dart';
import 'package:flutter_chatter_hub/features/agree_and_continue/agree_continue_view.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view/chat_detail_screen.dart';
import 'package:flutter_chatter_hub/features/home/view/home_screen.dart';
import 'package:flutter_chatter_hub/features/number_input/number_input_screen_view.dart';
import 'package:flutter_chatter_hub/features/profile_info/view/profile_info_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  late final GoRouter routerConfig;

  AppRouter() {
    routerConfig = GoRouter(
      navigatorKey: navigatorKey,

      // Set initial location to '/' which will redirect properly
      initialLocation: '/',

      redirect: (context, state) {
        final isAuthDone = injector<SharedPref>().getValue('isAuthCompleted') as bool? ?? false;
        final locationName = state.name;

        if (!isAuthDone && locationName != 'agree_and_continue') {
          debugPrint('Redirecting to agree_and_continue');
          return injector<AppRoutesName>().agreeAndCountinue;
        } // redirect unauthenticated
        if (isAuthDone && locationName == 'agree_and_continue') return injector<AppRoutesName>().homeScreen; // redirect authenticated
        return null;
      },

      // All app routes
      routes: [
        // Redirect root to proper screen
        GoRoute(
          path: '/',
          redirect: (context, state) {
            final isAuthDone = injector<SharedPref>().getValue('isAuthCompleted') as bool? ?? false;
            debugPrint('Redirecting to agree_and_continue');
            return isAuthDone ? injector<AppRoutesName>().homeScreen : injector<AppRoutesName>().agreeAndCountinue;
          },
        ),

        GoRoute(
          path: injector<AppRoutesName>().agreeAndCountinue,
          builder: (context, state) => const AgreeContinueView(),
        ),
        GoRoute(
          path: injector<AppRoutesName>().numberInputScreen,
          builder: (context, state) => const NumberInputScreenView(),
        ),
        GoRoute(
          path: injector<AppRoutesName>().profileScreen,
          builder: (context, state) => const ProfileInfoScreen(),
        ),
        GoRoute(
          path: injector<AppRoutesName>().homeScreen,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: injector<AppRoutesName>().chatDetailScreen,
          builder: (context, state) {
            final params = state.extra as ChatDetailScreenInputParams;
            return ChatDetailScreen(
              username: params.name,
              pfp: params.pfp,
              uid: params.userId,
            );
          },
        ),
        GoRoute(
          path: injector<AppRoutesName>().addUserScreen,
          builder: (context, state) => const AddUserScreen(),
        ),
      ],
    );
  }
}

class ChatDetailScreenInputParams {
  final String? pfp;
  final String name;
  final String userId;

  ChatDetailScreenInputParams({required this.pfp, required this.name, required this.userId});
}
