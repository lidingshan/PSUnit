Import-Module c:\workspace\PSUnit\asserts.psm1

function setup()
{
}

function test_case1()
{
	$expected = 3
	$actual = 1 + 2
	
	$result = $expected -eq $actual
}
