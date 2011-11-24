devenv Installer\Installer.sln /Build

net use Z: "\\shasrvbsd02\Dataxfer\Mike Li\PSUnit"

set SetupAppName=PSUnitInstaller-build%SOURCE_BUILD_NUMBER%.msi
cp Installer\Installer\Bin\PSUnitInstaller.msi Z:\%SetupAppName%
echo Y|net use Z: /delete