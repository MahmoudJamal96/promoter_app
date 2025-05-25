@echo off
echo Running currency conversion script...

powershell -Command "(Get-Content -Path 'lib\features\menu\delivery\delivery_screen.dart' -Raw) -replace ' ريال', ' ${Strings.CURRENCY}' | Set-Content -Path 'lib\features\menu\delivery\delivery_screen.dart'"
powershell -Command "(Get-Content -Path 'lib\features\returns\screens\return_transaction_screen.dart' -Raw) -replace ' ر.س', ' ${Strings.CURRENCY}' | Set-Content -Path 'lib\features\returns\screens\return_transaction_screen.dart'"
powershell -Command "(Get-Content -Path 'lib\features\inventory\screens\sales_report_screen.dart' -Raw) -replace ' ر.س', ' ${Strings.CURRENCY}' | Set-Content -Path 'lib\features\inventory\screens\sales_report_screen.dart'"

echo Currency conversion completed!
