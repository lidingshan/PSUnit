$global:PSUnit_Home = $env:PSUNIT_HOME

Import-Module $global:PSUnit_Home"\PSUnit.psm1"

function Run($path)
{
	PSUnit_SetTestRoot $path
	$scriptFiles = PSUnit_GetTestScripts
	PSUnit_Run
}

Run $args[0]

