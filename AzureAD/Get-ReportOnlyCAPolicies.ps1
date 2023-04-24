Import-Module Microsoft.Graph.Reports
Connect-MGGraph -Scope AuditLog.Read.All
$SignIns = Get-MGAuditLogSignIn
    ForEach ($SignIn in $SignIns){
        $Policies = $SignIn.AppliedConditionalAccessPolicies
            ForEach ($Policy in $Policies)
                {
                    
                    If (($Policy.Result -like "reportOnly*") -ine ($Policy.Result -eq "reportOnlyNotApplied")){
                    $Report = [ordered]@{'Login Time'=$SignIn.CreatedDateTime;'Policy Name'=$Policy.DisplayName;'Username'=$SignIn.UserDisplayName;'Result'=$Policy.Result;'Device Name'=$signin.DeviceDetail.DisplayName;'OS Version'=$signin.DeviceDetail.OperatingSystem;'Browser'=$signin.DeviceDetail.Browser;'IP Address'=$SignIn.IPAddress}
                    $Reports += @(New-Object -TypeName psObject -Property $Report)
                    }
                    Else{}

                }        
    }

$Reports | FT

<# Extra bits
$Reports = $NULL
$Reports | Where-Object {($_.Result -eq "ReportOnlyFailure") -and ($_.'Login Time' -gt ((Get-Date).AddDays(-7)))} | FT
$Reports | Where-Object {} | FT
$Reports | Where-Object {$_.Result -eq "ReportOnlyFailure"} | Export-CSV C:\Temp\ConditionalAccess_$(Get-Date -Format yyyyMMddhhmmss).csv -NoTypeInformation -NoClobber -Force 
#>
