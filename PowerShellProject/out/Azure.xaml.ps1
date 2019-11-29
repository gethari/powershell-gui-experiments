function Add-ControlVariables {	
New-Variable -Name 'Login' -Value $window.FindName('Login') -Scope 1 -Force
}

function Load-Xaml {
	[xml]$xaml = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('PFdpbmRvdw0KDQogIHhtbG5zPSJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dpbmZ4LzIwMDYveGFtbC9wcmVzZW50YXRpb24iDQoNCiAgeG1sbnM6eD0iaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93aW5meC8yMDA2L3hhbWwiDQoNCiAgVGl0bGU9Ik1haW5XaW5kb3ciIEhlaWdodD0iMzUwIiBXaWR0aD0iNTI1Ij4NCg0KICAgIDxHcmlkPg0KDQogICAgICAgIDxMYWJlbCBDb250ZW50PSJMYWJlbCIgSG9yaXpvbnRhbEFsaWdubWVudD0iTGVmdCIgTWFyZ2luPSI2OCwzOCwwLDAiIFZlcnRpY2FsQWxpZ25tZW50PSJUb3AiIFdpZHRoPSIxOTciLz4NCg0KICAgICAgICA8QnV0dG9uIHg6TmFtZT0iTG9naW4iIENvbnRlbnQ9IkJ1dHRvbiIgSG9yaXpvbnRhbEFsaWdubWVudD0iTGVmdCIgTWFyZ2luPSIzMDcsNDEsMCwwIiBWZXJ0aWNhbEFsaWdubWVudD0iVG9wIiBXaWR0aD0iNzUiIENsaWNrPSJMb2dpbiIvPg0KDQogICAgPC9HcmlkPg0KDQo8L1dpbmRvdz4='))
[System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework') | Out-Null
	$manager = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xaml.NameTable
	$manager.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
	$xaml.SelectNodes("//*[@x:Name='Login']", $manager)[0].RemoveAttribute('Click')
	$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
	[Windows.Markup.XamlReader]::Load($xamlReader)
}
function Set-EventHandlers {
	$Login.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		Login($sender,$e)
		Connect-AzureRmAccount
	})
}
$window = Load-XamlAdd-ControlVariables
Set-EventHandlers

function Login
{
	param($sender, $e)
}

$window.ShowDialog()