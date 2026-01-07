import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/cupertino.dart';

class CustomerTableHeader extends StatelessWidget {
  const CustomerTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).name.capitalizeFirstLetter(),
          ),
        ),
        Expanded(
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).phone.capitalizeFirstLetter(),
          ),
        ),
        Expanded(
          flex: 2,
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).address.capitalizeFirstLetter(),
          ),
        ),
        Expanded(
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).discount.capitalizeFirstLetter(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: DefaultTextView(
              fontWeight: FontWeight.bold,
              text: '${S.of(context).manage.capitalizeFirstLetter()}',
            ),
          ),
        ),
      ],
    );
  }
}
