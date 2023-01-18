<#
.Synopsis
This script gathers uefi settings and there values from Windows Management Instrumentation (WMI).

.Description
This script gathers uefi settings and there values from Windows Management Instrumentation (WMI).
Based on manufacturer the correct query will be run. Output of the query wil be formatted to an xml output.

#>

[CmdletBinding()]
Param (
)

###
# Functions
###
function GenerateXML {
    param (
        [Parameter(Mandatory=$True)][string]$cpu,
        [Parameter(Mandatory=$True)][string]$memory,
        [Parameter(Mandatory=$True)][string]$state
    )

        $cpu = $($($cpu.subString(0, [System.Math]::Min(255, $cpu.Length))))
        $memory = $($($memory.subString(0, [System.Math]::Min(255, $memory.Length))))
        $state = $($($state.subString(0, [System.Math]::Min(255, $state.Length))))

        $generateXML += "<GREENIT>`n"
        $generateXML += "<CPU_USAGE>"+ $cpu +"</CPU_USAGE>`n"
        $generateXML += "<MEMORY_USAGE>"+ $memory +"</MEMORY_USAGE>`n"
        $generateXML += "<STATE>"+ $state +"</STATE>`n"
        $generateXML += "</GREENIT>`n"
        return $generateXML
}

###
# Core
###
Try {
    $resultXML = ''
    $state = ''
    write-verbose "[INFO] Gathering consumption information"
    $cpu = Get-WmiObject Win32_Processor | Select LoadPercentage
    $memory = Get-WmiObject -Class win32_operatingsystem | Select FreePhysicalMemory, TotalVisibleMemorySize
    $command = New-Object PSObject -Property:@{CPU=$cpu;MEMORY=$memory}
    foreach($setting in $command)
    {

        if ($setting.CPU.LoadPercentage -and $setting.MEMORY.FreePhysicalMemory -and $setting.MEMORY.TotalVisibleMemorySize) {
            $memory = (($setting.MEMORY.TotalVisibleMemorySize - $setting.MEMORY.FreePhysicalMemory)*100)/$setting.MEMORY.TotalVisibleMemorySize
            $roundMemory = [math]::Round($memory)

            if($setting.CPU.LoadPercentage -lt 10 -or $roundMemory -lt 25)
            {
               $state = 'LOW'
            }
            if($setting.CPU.LoadPercentage -gt 10 -or $setting.CPU.LoadPercentage -lt 15 -or $roundMemory -gt 25 -or $roundMemory -lt 50)
            {
                $state = 'MEDIUM'
            }
            if($setting.CPU.LoadPercentage -gt 15 -or $roundMemory -gt 50)
            {
                $state = 'HIGH'
            }

            $resultXML = $(GenerateXML $($setting.CPU.LoadPercentage) $roundMemory $state)
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