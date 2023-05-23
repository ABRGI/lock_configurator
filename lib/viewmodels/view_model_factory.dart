import 'package:nelson_lock_manager/viewmodels/main_view_model.dart';

class ViewModelFactory {
  static MainViewModel? _mainViewModel;

  static MainViewModel get mainViewModel {
    _mainViewModel ??= MainViewModel();
    return _mainViewModel!;
  }
}
