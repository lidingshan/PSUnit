Import-Module c:\workspace\PSUnit\asserts.psm1
Import-Module c:\workspace\PSUnit\PSUnit.psm1

$global:setupIsCalled = $false

function setup()
{
	PSUnit_SetTestRoot ".\testdata\"
	$global:setupIsCalled = $true
}

function test_get_testing_path()
{
	$expected = ".\testdata\"
	$actual = PSUnit_GetTestRoot
	
	assertAreEqual $expected $actual
}

function test_get_all_testscript_file()
{
	[int]$expected = 2
	
	[array]$scriptFiles = PSUnit_GetTestScripts	
	[int]$actual = $scriptFiles.length
	
	assertAreEqual $expected $actual
}

function test_setup_called()
{
	assertIsTrue $script:setupIsCalled
}

function test_get_setup_method()
{
	$expected = "setup"
	$scriptFullPath = ".\testdata\test_script1.ps1"
	
	$actual = PSUnit_GetSetupMethod($scriptFullPath)
	
	assertAreEqual $expected $actual
}

function test_no_setup()
{
	$scriptFullPath = ".\testdata\test_script2.ps1"
	$actual = PSUnit_GetSetupMethod($scriptFullPath)
	
	assertIsNone $actual
}