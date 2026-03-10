import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../locale_provider.dart';

class LanguagePickerWidget extends StatelessWidget {
  const LanguagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return DropdownButton<Locale>(
      underline: const SizedBox(),
      icon: const Icon(Icons.language),
      value: provider.locale ?? const Locale('en'),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          provider.setLocale(newLocale);
        }
      },
      items: L10n.all.map((locale) {
        final String languageKey;
        switch (locale.languageCode) {
          case 'ar':
            languageKey = "arabic";
            break;
          case 'ru':
            languageKey = "russian";
            break;
          default:
            languageKey = "english";
        }
        return DropdownMenuItem(value: locale, child: Text(languageKey.tr()));
      }).toList(),
    );
  }
}
