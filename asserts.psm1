
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

function assertAreGreater($first, $second)
{
    if ($first -gt $second)
    {
        return
    }
    else
    {
        $msg = "$first is not greater than $second"
        throw (New-Object Exception($msg))
    }
}

function assertAreLess($first, $second)
{
    if ($first -le $second)
    {
        return
    }
    else
    {
        $msg = "$first is not less than $second"
        throw (New-Object Exception($msg))
    }
}