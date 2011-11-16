$global:PSUnit_Home = Get-Location

Import-Module $global:PSUnit_Home"\PSUnit.psm1"

function Run($path)
{
	PSUnit_SetTestRoot $path
	$scriptFiles = PSUnit_GetTestScripts
	
	if (!$scriptFiles)
	{
		Write-Host "No tests executed"
		return
	}

	foreach($script in $scriptFiles)
	{
		PSUnit_ExcecuteOneScriptFile $script
	}
}

Run $args[0]

