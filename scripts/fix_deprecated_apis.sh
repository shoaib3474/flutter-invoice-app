#!/bin/bash

echo "🔧 Fixing deprecated APIs and syntax errors..."

# Fix deprecated APIs in Dart files
find lib -name "*.dart" -type f -exec sed -i.bak \
  -e 's/FlatButton/TextButton/g' \
  -e 's/RaisedButton/ElevatedButton/g' \
  -e 's/OutlineButton/OutlinedButton/g' \
  -e 's/FloatingActionButton.extended/FloatingActionButton.extended/g' \
  -e 's/Scaffold.of(context).showSnackBar/ScaffoldMessenger.of(context).showSnackBar/g' \
  -e 's/Theme.of(context).accentColor/Theme.of(context).colorScheme.secondary/g' \
  -e 's/Theme.of(context).primaryColorDark/Theme.of(context).colorScheme.primary/g' \
  -e 's/Theme.of(context).primaryColorLight/Theme.of(context).colorScheme.primaryContainer/g' \
  -e 's/TextTheme().headline6/TextTheme().titleLarge/g' \
  -e 's/TextTheme().headline5/TextTheme().headlineSmall/g' \
  -e 's/TextTheme().headline4/TextTheme().headlineMedium/g' \
  -e 's/TextTheme().subtitle1/TextTheme().titleMedium/g' \
  -e 's/TextTheme().subtitle2/TextTheme().titleSmall/g' \
  -e 's/TextTheme().bodyText1/TextTheme().bodyLarge/g' \
  -e 's/TextTheme().bodyText2/TextTheme().bodyMedium/g' \
  -e 's/TextTheme().caption/TextTheme().bodySmall/g' \
  -e 's/autovalidate:/autovalidateMode: AutovalidateMode.onUserInteraction,/g' \
  -e 's/resizeToAvoidBottomPadding:/resizeToAvoidBottomInset:/g' \
  {} \;

# Remove backup files
find lib -name "*.dart.bak" -type f -delete

echo "✅ Deprecated APIs fixed!"
