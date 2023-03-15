import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:quiver/strings.dart' as q;

part 'mobx_forms.g.dart';

class ValidatableObject<T> = _ValidatableObject<T> with _$ValidatableObject;

abstract class _ValidatableObject<T> with Store {
  _ValidatableObject() {
    // Just onetime only for initial value
    when(
      (r) {
        return initialValue != null;
      },
      () {
        value = initialValue;
      },
    );
    autorun((c) {
      value = initialValue;
      c.dispose();
    });
  }

  List<IValidator<T>> _validations = [];
  List<IValidator<T?>> get validations => _validations;

  @computed
  String? get error => errors == null || errors!.isEmpty ? null : errors![0];

  @observable
  List<String?>? errors;

  final _value = Observable<T?>(null);
  T? get value => _value.value;
  set value(T? value) => _value.value = value;

  final _initialValue = Observable<T?>(null);
  T? get initialValue => _initialValue.value;
  set initialValue(T? value) => _initialValue.value = value;

  @computed
  bool get isValid => errors != null && errors!.isEmpty;

  bool validate({bool notify = true}) {
    var _errors = validations
        .where((v) => !v.isValid(value))
        .map((t) => t.errorMessage)
        .toList();
    errors = _errors;
    return isValid;
  }
}

abstract class IValidator<T> {
  String? errorMessage;
  bool isValid(T value);
}

class StringNotNullValidator extends IValidator<String> {
  StringNotNullValidator() {
    errorMessage = 'Can\'t be null';
  }

  @override
  bool isValid(String value) {
    return !q.isBlank(value);
  }
}

class EmailValidator extends IValidator<String> {
  @override
  bool isValid(String value) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value ?? '');
  }
}

class InlineValidator<T> extends IValidator<T> {
  final bool Function(T value) validator;

  InlineValidator({
    required this.validator,
  });

  @override
  bool isValid(T value) {
    return validator(value);
  }
}
