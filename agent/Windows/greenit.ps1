[CmdletBinding()]
Param (
)

#UTF8 Encoding
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

###
# Functions
###
function GenerateXML
{
    param (
        [Parameter(Mandatory=$True)][PSCustomobject]$data
    )

    $counter = 0

    foreach($PROCESS in $data)
    {
        $generateXML += "<GREENIT>`n"
        $generateXML += "<DATETIME>"+ $PROCESS.DateTime + "</DATETIME>`n"
        $generateXML += "<LIBRARY>"+ $PROCESS.Library + "</LIBRARY>`n"
        $generateXML += "<PROCESS>"+ $PROCESS.Process + "</PROCESS>`n"
        $generateXML += "<VALUE>"+ $PROCESS.Value + "</VALUE>`n"
        $generateXML += "</GREENIT>`n"
    }

    return $generateXML
}

###
# Core
###

#Regular expression
$regex = "(?<Date>(?<Date_Day>[0-9]+)\/(?<Date_Month>[0-9]+)\/(?<Date_Year>[0-9]+)) (?<Time>(?<Time_Hour>[0-9]+):(?<Time_Minute>[0-9]+):(?<Time_Second>[0-9]+)): (?<Library>[\s\S]+?): (?<Process>[_\s\S]+?): (?<Value>[0-9.,]+ W)"

#Reset variables
$resultXML = ""
$data = @()
$element = [PSCustomObject]@{}

write-verbose "[INFO] Gathering consumption information"

Try {
    for($i = 0; $i -lt 10; $i++)
    {
        $file = Get-Content "C:\ProgramData\OCS Inventory NG\Agent\GreenIT.log"
        if($file)
        {
            break;
        }
        Start-Sleep(1)
    }
    if($file)
    {
        foreach($line in $file)
        {
            if($line -match $regex)
            {
                $element = [PSCustomobject]@{
                    DateTime = $Matches.Date_Year + "-" + $Matches.Date_Month + "-" + $Matches.Date_Day + " " + $Matches.Time
                    Library = $Matches.Library
                    Process = $Matches.Process
                    Value = $Matches.Value
                }
                $data += $element
            }
        }
        $resultXML = $(GenerateXML $($data))
    }
    else
    {
        write-verbose "[ERROR] Get-Content Timed out"
    }
}
Catch {
    write-verbose $Error[0]
}

write-verbose "[INFO] Sending report..."

if($resultXML)
{
    echo $resultXML
    write-verbose "[INFO] Done sending report"
}
else
{
    write-verbose "[ERROR] Something went wrong with the report sending. Exiting"
}

write-verbose "[INFO] Exiting"