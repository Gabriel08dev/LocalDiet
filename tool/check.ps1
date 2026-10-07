# Roda as mesmas verificacoes do CI: formatacao, analise e testes.
$ErrorActionPreference = 'Stop'
dart format --output=none --set-exit-if-changed lib test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter test
exit $LASTEXITCODE
