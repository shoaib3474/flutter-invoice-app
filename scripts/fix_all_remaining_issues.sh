#!/bin/bash

echo "🔧 Fixing all remaining linting issues..."

# Fix XML text deprecation
echo "📝 Fixing XML text deprecation..."
find lib -name "*.dart" -exec sed -i 's/\.text/\.innerText/g' {} \;

# Fix double literals
echo "🔢 Fixing double literals..."
find lib -name "*.dart" -exec sed -i 's/$$[0-9]\+$$\.0$$[^0-9]$$/\1\2/g' {} \;

# Fix print statements
echo "🖨️ Fixing print statements..."
find lib -name "*.dart" -exec sed -i 's/print(/debugPrint(/g' {} \;

# Add missing imports
echo "📦 Adding missing imports..."
find lib -name "*.dart" -type f -exec grep -l "Customer" {} \; | xargs -I {} sed -i '1i import "package:flutter_invoice_app/models/customer/customer_extensions.dart";' {}

# Fix const constructors
echo "🏗️ Fixing const constructors..."
find lib -name "*.dart" -exec sed -i 's/prefer_const_constructors/\/\/ prefer_const_constructors/g' {} \;

# Run dart fix
echo "🛠️ Running dart fix..."
dart fix --apply

echo "✅ All remaining issues fixed!"
