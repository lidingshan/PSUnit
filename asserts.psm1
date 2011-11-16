function assertAreEqual($expected, $actual)
{
	if ($expected -eq $actual)
	{
		return
	}
	else
	{
		$msg = $expected.ToString() + " are not equal with " + $actual.ToString()
		throw (New-Object Exception($msg))
	}
}

function assertIsTrue($result)
{
	if ($result -eq $false)
	{
		$msg = "Expected TRUE but actually FAILED"
		throw (New-Object Exception($msg))
	}
}

function assertIsNone($result)
{
	if ($result -ne $null)
	{
		$msg = "Expected None but actually not"
		throw (New-Object Exception($msg))
	}
}

function assertFail()
{
	$msg = "The test is set as failed"
	throw (New-Object Exception($msg))
}