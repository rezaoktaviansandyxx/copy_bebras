import 'package:fluxmobileapp/baselib/command.dart';
import 'package:mobx/mobx.dart';

class GetStartedStore {
  GetStartedStore() {
    pages.addAll([
      OnboardingModel()
        ..title = 'Halo!'
        ..description = 'Selamat datang di aplikasi PANDAI!'
        ..subtitle = 'PANDAI! adalah aplikasi untuk mengasah logika berpikir komputasional.\nYuk cari tahu seberapa tajam logikamu.'
        ..imagePath = 'images/maskot_bebras.svg',
      OnboardingModel()
        ..title = 'Halo!'
        ..description = 'Selamat datang di aplikasi PANDAI!'
        ..subtitle = 'PANDAI! adalah aplikasi untuk mengasah logika berpikir komputasional.\nYuk cari tahu seberapa tajam logikamu.'
        ..imagePath = 'images/maskot_bebras.svg',
      OnboardingModel()
        ..title = 'Halo!'
        ..description = 'Selamat datang di aplikasi PANDAI!'
        ..subtitle = 'PANDAI! adalah aplikasi untuk mengasah logika berpikir komputasional.\nYuk cari tahu seberapa tajam logikamu.'
        ..imagePath = 'images/maskot_bebras.svg',
      // OnboardingModel()
      //   ..title = 'Welcome to Anugra'
      //   ..description = 'The best place to level up your managerial Skill'
      //   ..subtitle = 'sssssssssss'
      //   ..imagePath = 'images/bebras_image.svg',
    ]);

    prev = Command(() async {
      if (currentPageIndex <= 0) {
        return;
      }

      currentPageIndex--;
    });

    next = Command(() async {
      if (currentPageIndex >= pages.length - 1) {
        return;
      }

      currentPageIndex++;
    });

    skip = Command(() async {
      currentPageIndex = pages.length - 1;
    });
  }

  final pages = ObservableList<OnboardingModel>();

  final _currentPageIndex = Observable(0);
  int get currentPageIndex => _currentPageIndex.value;
  set currentPageIndex(int value) {
    _currentPageIndex.value = value;
  }

  bool get isLastPageIndex => currentPageIndex == pages.length - 1;

  OnboardingModel get currentPage => pages[currentPageIndex];

  late Command prev;

  late Command next;

  late Command skip;
}

class OnboardingModel {
  late String title;
  late String description;
  late String subtitle;
  late String imagePath;
}
