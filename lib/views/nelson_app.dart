import 'package:flutter/material.dart';
import 'package:nelson_lock_manager/constants.dart';
import 'package:nelson_lock_manager/utilities.dart';
import 'package:nelson_lock_manager/viewmodels/main_view_model.dart';
import 'package:nelson_lock_manager/viewmodels/view_model_factory.dart';
import 'package:nelson_lock_manager/views/locks_view.dart';

class NelsonApp extends StatelessWidget {
  late final MainViewModel viewModel;

  NelsonApp({super.key}) {
    viewModel = ViewModelFactory.mainViewModel;
    viewModel.loading = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nelson',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF285557),
          primary: const Color(0xFF285557),
          primaryContainer: const Color(0xFF285557),
          secondaryContainer: const Color(0xFFf8f7f2),
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Padding(
            padding: EdgeInsets.all(getHorizontalEdgePadding(context)),
            child: Image.asset('assets/nelson-white.png'),
          ),
          centerTitle: false,
          toolbarHeight: _getToolBarHeight(context)),
      body: const SingleChildScrollView(
          scrollDirection: Axis.vertical, child: LocksView()),
    );
  }

  double _getToolBarHeight(BuildContext context) {
    return MediaQuery.of(context).size.width < MediaSizes.mediaSmall
        ? LayoutConstants.toolbarSmallHeight
        : LayoutConstants.toolbarHeight;
  }
}
