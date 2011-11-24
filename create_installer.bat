devenv Installer\Installer.sln /Build

net use Z: "\\shasrvbsd02\Dataxfer\Mike Li\PSUnit"
cp Installer\Installer\Bin\PSUnitInstaller.msi Z:
echo Y | net use Z: /delete