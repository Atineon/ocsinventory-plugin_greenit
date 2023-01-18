[CmdletBinding()]
Param (
)

###
# Functions
###
function GenerateXML {
    param (
        [Parameter(Mandatory=$True)][string]$cpu
    )

        $cpu = $($($cpu.subString(0, [System.Math]::Min(255, $cpu.Length))))

        $generateXML += "<GREENIT>`n"
        $generateXML += "<CPU>"+ $cpu +"</CPU>`n"
        $generateXML += "</GREENIT>`n"
        return $generateXML
}

###
# Core
###
Try {
    $resultXML = ''
    write-verbose "[INFO] Gathering consumption information"
    $command = Get-WmiObject -Namespace root\OpenHardwareMonitor -Class Sensor -Filter "Name='CPU Total'"| Select Value
    foreach($setting in $command)
    {
        
        if ($setting.Value) {
            $resultXML = $(GenerateXML $($setting.Value))
        } 
    }
}
Catch {
    write-verbose $Error[0]
}

write-verbose "[INFO] Sending report..."
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::WriteLine($resultXML)
write-verbose "[INFO] Done sending report"
write-verbose "[INFO] Exiting"