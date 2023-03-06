import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TextFieldControllerWrapper extends HookWidget {
  final TextEditingController Function()? textEditingControllerBuilder;
  final Widget Function(
    BuildContext context,
    TextEditingController textEditingController,
  ) onControllerCreated;

  const TextFieldControllerWrapper({
    Key? key,
    this.textEditingControllerBuilder,
    required this.onControllerCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textEditingController = useMemoized(
      () => textEditingControllerBuilder != null
          ? textEditingControllerBuilder!()
          : TextEditingController(),
    );
    useEffect(() {
      return () {
        textEditingController.dispose();
      };
    }, const []);

    return onControllerCreated(context, textEditingController);
  }
}
