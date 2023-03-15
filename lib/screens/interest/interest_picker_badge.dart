import 'package:flutter/material.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InterestPickerBadge extends StatelessWidget {
  final TopicItem item;
  final Function(TopicItem)? onChangedItem;
  final bool includeText;
  const InterestPickerBadge({
    Key? key,
    required this.item,
    this.onChangedItem,
    this.includeText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return InkWell(
      onTap: onChangedItem != null
          ? () {
              final newValue = TopicItem.fromJson(item.toJson());
              if (newValue.isSelected == null) {
                newValue.isSelected = false;
              }
              newValue.isSelected = !newValue.isSelected!;
              onChangedItem!(newValue);
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.of(context).canvasColorLevel3,
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: FractionallySizedBox(
                      heightFactor: 0.75,
                      widthFactor: 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (() {
                            try {
                              return item.color != null
                                  ? hexToColor(
                                      item.color!,
                                    )
                                  : Theme.of(context).accentColor;
                            } catch (error) {
                              return Theme.of(context).accentColor;
                            }
                          })(),
                        ),
                        child: Image.asset(
                          item.iconUrl ?? '',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: item.isSelected == true ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff5AD57F),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (includeText == true) const SizedBox(height: 5),
          if (includeText == true)
            SizedBox(
              height: 34 * mediaQuery.textScaleFactor,
              child: Text(
                item.name ?? '',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0XFF00ADEE),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
