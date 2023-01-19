[CmdletBinding()]
Param (
)

#UTF8 Encoding
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'


#kWh cost
$kWhPrice = 0.1752

#List of get commands
$cpu = Get-WmiObject -Namespace root\OpenHardwareMonitor -Class Sensor -Filter "Name='CPU Package' and SensorType='Power'"| Select Value


###
# Functions
###
function GenerateXML {
    param (
        [Parameter(Mandatory=$True)][string]$cpu,
        [Parameter(Mandatory=$True)][string]$cost
    )

    $cpu = $($($cpu.subString(0, [System.Math]::Min(255, $cpu.Length))))
    $cost = $($($cost.subString(0, [System.Math]::Min(255, $cost.Length))))

    $generateXML += "<GREENIT>`n"
    $generateXML += "<CPU>"+ $cpu +" W</CPU>`n"
    $generateXML += "<COST>"+ $cost +" €</COST>`n"
    $generateXML += "</GREENIT>`n"
    return $generateXML
}

###
# Core
###
Try {
    $resultXML = ''

    write-verbose "[INFO] Gathering consumption information"
    
    #Consumption Calcul
    $cpu = ($cpu*60)/1000
    $cost = $cpu*$kWhPrice

    $resultXML = $(GenerateXML $($cpu) $($cost))
}
Catch {
    write-verbose $Error[0]
}

write-verbose "[INFO] Sending report..."
if($resultXML)
{
    [Console]::WriteLine($resultXML)
    write-verbose "[INFO] Done sending report"
    write-verbose "[INFO] Exiting"
}
else
{
    write-verbose "[ERROR] Something went wrong with the report sending. Exiting"
}