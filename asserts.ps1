function assertAreEqual($expected, $actual)
{
	if ($expected -eq $actual)
	{
		return
	}
	else
	{
		$msg = $expected + " are not equal with " + $actual
		throw (New-Object Exception($msg))
	}
}