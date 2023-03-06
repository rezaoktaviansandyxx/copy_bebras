import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

class AppHtml extends StatelessWidget {
  final String html;
  final TextAlign textAlign;
  final Color? color;
  AppHtml(
    this.html, {
    this.textAlign = TextAlign.start,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, Style> style = {
      'html, body': Style(
        margin: Margins.zero,
        padding: EdgeInsets.zero,
        fontSize: FontSize(16),
        textAlign: textAlign,
        color: color,
      ),
      // '.hljs-comment': Style(
      //   fontSize: FontSize(100)
      // ),
    };
    return Html(
      data: html,
      style: style,
    );
  }
}
