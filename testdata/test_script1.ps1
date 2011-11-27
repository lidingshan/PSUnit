function setup()
{
}

function teardown()
{
	$global:teardownIsCalled = $true
}

function test_case1()
{
	$global:testCaseIsCalled = $true
}

function test_case2()
{
	Write-Host "do nothing"
}
