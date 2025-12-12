import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/config/router.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/features/home/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class ChatterHub extends StatelessWidget {
  const ChatterHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: injector<AppRouter>().routerConfig,
        debugShowCheckedModeBanner: false,
        title: 'Chatter Hub',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
      ),
    );
  }
}
