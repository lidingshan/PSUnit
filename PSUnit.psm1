$script:PSUnit_Root = "";

function PSUnit_SetTestRoot($testRoot) 
{ 
	$script:PSUnit_Root = $testRoot;	
} 

function PSUnit_GetTestRoot()
{
	return $script:PSUnit_Root
}

function PSUnit_GetTestScripts()
{
	$directories = Get-ChildItem $script:PSUnit_Root -Recurse
	
	[array]$scriptFiles = $directories | where {$_.name -like "test*.ps1" -and $_.name -ne "testRunner.ps1"}	
	return $scriptFiles
}

function PSUnit_GetSetupMethod($scriptFullPath)
{
	$setupFunction = Get-Content $scriptFullPath | where {$input -like "function setup*"}
	if ($setupFunction -eq $null)
	{
		return $null
	}
	
	$setupMethod = getMethodName $setupFunction
	
	return $setupMethod
}

function getMethodName($methodDeclaration)
{
	$length = [int]$methodDeclaration.length
	$prefixLength = [int]"function ".length
	$suffixLength = [int]"()".length
	
	$subStringLength = $length - $prefixLength - $suffixLength
	$startPosition = $prefixLength
	
	return $methodDeclaration.SubString($startPosition, $subStringLength)
}

