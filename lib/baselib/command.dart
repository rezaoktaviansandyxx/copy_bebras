import 'dart:async';

import 'package:rxdart/rxdart.dart';

class Command<TParameter> {
  late Future Function(TParameter? parameter) _execute;

  Command._(
    Future Function(TParameter? parameter) execute, [
    Future<bool> Function(TParameter? parameter)? canExecute,
  ]) {
    _execute = execute;
    this.canExecute =
        canExecute ?? ((TParameter? parameter) => Future.value(!isExecuting));
  }

  factory Command.sync(
    Function execute, [
    bool Function()? canExecute,
  ]) {
    return Command._(
      (_) {
        execute();
        return Future.value(null);
      },
      (_) => canExecute != null ? canExecute() as Future<bool> : Future.value(true),
    );
  }

  factory Command.syncParameter(
    void Function(TParameter? parameter) execute, [
    bool Function()? canExecute,
  ]) {
    return Command._(
      (_) {
        execute(_);
        return Future.value(_);
      },
      (_) => canExecute != null ? canExecute() as Future<bool> : Future.value(true),
    );
  }

  factory Command(
    Future Function() execute, [
    Future<bool> Function()? canExecute,
  ]) {
    return Command._(
      (_) => execute(),
      (_) => canExecute != null ? canExecute() : Future.value(true),
    );
  }

  factory Command.parameter(
    Future Function(TParameter? parameter) execute, [
    Future<bool> Function(TParameter? parameter)? canExecute,
  ]) {
    return Command._(execute, canExecute);
  }

  late Future<bool> Function(TParameter? parameter) canExecute;

  var isExecuting = false;

  Future execute([TParameter? parameter]) async {
    try {
      isExecuting = true;

      return await _execute(parameter).whenComplete(() {
        _subject.add(null);
      });
    } finally {
      isExecuting = false;
    }
  }

  Future executeIf([TParameter? parameter]) async {
    var canExecute = await this.canExecute(parameter);
    if (!canExecute || isExecuting) {
      print('Command can execute $canExecute');
      print('Command is executing $isExecuting');
      return null;
    }

    return await execute(parameter).whenComplete(() {
      _subject.add(null);
    });
  }

  var _subject = BehaviorSubject(
    sync: true,
  );
  Future get next => _subject.take(1).last;

  BehaviorSubject get execute$ => _subject;

  void dispose() {
    _subject.close();
  }
}
