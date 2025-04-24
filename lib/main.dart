import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/service/bloc/location_bloc/location_bloc.dart';
import 'package:weather_app/service/bloc/search_bloc/search_bloc.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_bloc.dart';
import 'package:weather_app/view/home_screen.dart';

void main() async {
  // Load the .env file
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => WeatherBloc()),
        BlocProvider(create: (context) => LocationBloc()),
        BlocProvider(create: (context) => SearchBloc()),
      ],
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
