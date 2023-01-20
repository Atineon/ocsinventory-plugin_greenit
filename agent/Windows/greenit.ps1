[CmdletBinding()]
Param (
)

#UTF8 Encoding
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8mb4'


#kWh costPerDay
$kWhPrice = 0.1752

#List of get commands
$cpu = Get-WmiObject -Namespace root\OpenHardwareMonitor -Class Sensor -Filter "Name='CPU Package' and SensorType='Power'"| Select Value


###
# Functions
###
function GenerateXML {
    param (
        [Parameter(Mandatory=$True)][string]$cpuConsumption,
        [Parameter(Mandatory=$True)][string]$costPerDay,
        [Parameter(Mandatory=$True)][string]$costPerMonth,
        [Parameter(Mandatory=$True)][string]$costPerYear
    )

    $cpuConsumption = $($($cpuConsumption.subString(0, [System.Math]::Min(255, $cpuConsumption.Length))))
    $costPerDay = $($($costPerDay.subString(0, [System.Math]::Min(255, $costPerDay.Length))))
    $costPerMonth = $($($costPerMonth.subString(0, [System.Math]::Min(255, $costPerMonth.Length))))
    $costPerYear = $($($costPerYear.subString(0, [System.Math]::Min(255, $costPerYear.Length))))

    $generateXML += "<GREENIT>`n"
    $generateXML += "<CPU_CONSUMPTION>"+ $cpuConsumption +" kW/h</CPU_CONSUMPTION>`n"
    $generateXML += "<COST_PER_DAY>"+ $costPerDay +" €/day</COST_PER_DAY>`n"
    $generateXML += "<COST_PER_MONTH>"+ $costPerMonth +" €/month</COST_PER_MONTH>`n"
    $generateXML += "<COST_PER_YEAR>"+ $costPerYear +" €/year</COST_PER_YEAR>`n"
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
    $cpuConsumption = ($cpu.Value*60)/1000
    $costPerDay = $cpuConsumption*24*$kWhPrice
    $costPerMonth = $cpuConsumption*730*$kWhPrice
    $costPerYear = $cpuConsumption*8760*$kWhPrice

    $resultXML = $(GenerateXML $($cpuConsumption) $($costPerDay) $($costPerMonth) $($costPerYear))
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