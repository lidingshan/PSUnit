Import-Module $global:PSUnit_Home"\PSUnit.psm1"
Import-Module $global:PSUnit_Home"\asserts.psm1"

$global:setupIsCalled = $false
$global:testCaseIsCalled = $false

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
	$testPath = PSUnit_GetTestRoot
	$files = dir $testPath
	[int]$expected = $files.length
	
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

function test_get_testcases()
{
	[int]$expected = 2
	
	$scriptFullPath = ".\testdata\test_script1.ps1"
	[array]$testCases = PSUnit_GetTestCases($scriptFullPath)
	$actual = $testCases.length
	
	assertAreEqual $expected $actual
	assertAreEqual "test_case1" $testCases[0]
}

function test_no_testcase()
{
	$scriptFullPath = ".\testdata\test_script3.ps1"
	[array]$testCases = PSUnit_GetTestCases($scriptFullPath)
	
	assertIsNone $testCases
}

function test_get_one_testcase()
{
	$expected = ".\testdata\test_script1.ps1;test_case1"
	$scriptPath = ".\testdata\test_script1.ps1"
	$testCase = "test_case1"
	$actual = PSUnit_GetOneTestCase($scriptPath, $testCase)
	
	assertAreEqual $expected $actual
}

function test_run_one_testcase()
{
	$scriptFullPath = ".\testdata\test_script1.ps1"
	$testCase = "test_case1"
	
	PSUnit_RunOneCase $scriptFullPath $testCase
	
	assertIsTrue $global:testCaseIsCalled
}

function test_WriteFail()
{
	assertFail
}