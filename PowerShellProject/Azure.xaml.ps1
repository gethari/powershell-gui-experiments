Add-Type -AssemblyName PresentationFramework
function Add-ControlVariables {
	
New-Variable -Name 'Login' -Value $window.FindName('Login') -Scope 1 -Force	
New-Variable -Name 'AvailableSubscriptions' -Value $window.FindName('AvailableSubscriptions') -Scope 1 -Force	
New-Variable -Name 'AvailableResourceGroups' -Value $window.FindName('AvailableResourceGroups') -Scope 1 -Force	
New-Variable -Name 'AvailableLogicApps' -Value $window.FindName('AvailableLogicApps') -Scope 1 -Force	
New-Variable -Name 'xml' -Value $window.FindName('xml') -Scope 1 -Force	
New-Variable -Name 'json' -Value $window.FindName('json') -Scope 1 -Force	
New-Variable -Name 'MessageBody' -Value $window.FindName('MessageBody') -Scope 1 -Force	
New-Variable -Name 'Trigger' -Value $window.FindName('Trigger') -Scope 1 -Force	
New-Variable -Name 'Request' -Value $window.FindName('Request') -Scope 1 -Force	
New-Variable -Name 'Manual' -Value $window.FindName('Manual') -Scope 1 -Force
New-Variable -Name 'FileName' -Value $window.FindName('FileName') -Scope 1 -Force
New-Variable -Name 'Result' -Value $window.FindName('Result') -Scope 1 -Force
}

function Load-Xaml {
	[xml]$xaml = Get-Content -Path $PSScriptRoot\Azure.xaml
	$manager = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xaml.NameTable
	$manager.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
	$xaml.SelectNodes("//*[@x:Name='Login']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='AvailableSubscriptions']", $manager)[0].RemoveAttribute('SelectionChanged')
	$xaml.SelectNodes("//*[@x:Name='AvailableResourceGroups']", $manager)[0].RemoveAttribute('SelectionChanged')
	$xaml.SelectNodes("//*[@x:Name='AvailableLogicApps']", $manager)[0].RemoveAttribute('SelectionChanged')
	$xaml.SelectNodes("//*[@x:Name='xml']", $manager)[0].RemoveAttribute('Checked')
	$xaml.SelectNodes("//*[@x:Name='json']", $manager)[0].RemoveAttribute('Checked')
	$xaml.SelectNodes("//*[@x:Name='MessageBody']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='Trigger']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='Request']", $manager)[0].RemoveAttribute('Checked')
	$xaml.SelectNodes("//*[@x:Name='Manual']", $manager)[0].RemoveAttribute('Checked')
	$xaml.SelectNodes("//*[@x:Name='FileName']", $manager)[0].RemoveAttribute('Checked')
	$xaml.SelectNodes("//*[@x:Name='Result']", $manager)[0].RemoveAttribute('Checked')
	$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
	[Windows.Markup.XamlReader]::Load($xamlReader)
}

function Set-EventHandlers {

	$Login.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		Connect-AzureRmAccount
		$AvailableSubscriptions.ItemsSource = Get-AzureRmSubscription | Select-Object -ExpandProperty Name
	})
	$AvailableSubscriptions.add_SelectionChanged({
		param([System.Object]$sender,[System.Windows.Controls.SelectionChangedEventArgs]$e)
		$subscription = $sender.SelectedItem
		Select-AzureRmSubscription -SubscriptionName $subscription
		$AvailableResourceGroups.ItemsSource = [Collections.Generic.List[String]](Get-AzureRmResourceGroup | Select-Object -ExpandProperty ResourceGroupName)
	})
	$AvailableResourceGroups.add_SelectionChanged({
		param([System.Object]$sender,[System.Windows.Controls.SelectionChangedEventArgs]$e)
		$Global:resourceGroupName = $sender.SelectedItem
		$AvailableLogicApps.ItemsSource = Get-AzureRmResource -ResourceType "Microsoft.Logic/workflows" -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty Name
	})
	$AvailableLogicApps.add_SelectionChanged({
		param([System.Object]$sender,[System.Windows.Controls.SelectionChangedEventArgs]$e)
		$Global:logicAppName = $sender.SelectedItem
		$Global:url = Get-AzureRmLogicAppTriggerCallbackUrl -ResourceGroupName $resourceGroupName -Name $logicAppName -TriggerName $requestType | Select-Object -ExpandProperty Value
	})
	$xml.add_Checked({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		$Global:contentType = $xml.Content
	})
	$json.add_Checked({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		$Global:contentType = $json.Content
	})
	$MessageBody.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		Get-FileName
		$FileName.Content = [io.path]::GetFileNameWithoutExtension($SelectedFile)
	})
	$Trigger.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		Write-Host "---------Triggering---------"
		$message = Get-Content -Path $SelectedFile -Raw -ErrorAction SilentlyContinue
		$statusCode = Invoke-WebRequest -Uri $url -Method Post -Body $message -ContentType $contentType | Select-Object -ExpandProperty StatusCode
		if($statusCode -eq 202)
		{
			$Result.Content = "Accepted"
			$Result.Foreground ="#f44156"
		}
		else
		{
			$Result.Content = "Failed"
			$Result.Foreground ="#3e6307"
		}
		Write-Host "-------Triggered Successfully--------"
	})
	$Request.add_Checked({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		$Global:requestType = $Request.Content
	})
	$Manual.add_Checked({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		$Global:requestType = $Manual.Content
	})
}
Function Get-FileName()
{
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Please Select File"
    $OpenFileDialog.filter = "XML (*.xml)|*.xml|JSON (*.json)|*.json"
    # Out-Null supresses the "OK" after selecting the file.
	$OpenFileDialog.ShowDialog() | Out-Null
    $Global:SelectedFile = $OpenFileDialog.FileName
}
$window = Load-Xaml
Add-ControlVariables
Set-EventHandlers
$window.ShowDialog()