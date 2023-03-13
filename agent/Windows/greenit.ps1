$data = $null

if(Test-Path 'C:\ProgramData\OCS Inventory NG\Agent\GreenIT\data.json') {
    $dataContent = Get-Content -Path 'C:\ProgramData\OCS Inventory NG\Agent\GreenIT\data.json'
}
if($null -eq $dataContent) {
    $xml = "<GREENIT/>"
} else {
    $xml = ""

    $regex =  "`"(?<DATE>[0-9]+-[0-9]+-[0-9]+)`": {`"CONSUMPTION`":`"(?<CONSUMPTION>[\s\S]+?)`",`"UPTIME`":`"(?<UPTIME>[0-9]+)`"},"
    foreach($data in $dataContent)
    {
        if($data -match $regex)
        {
            $xml += "<GREENIT>`n"
            $xml += "<DATE>" + $Matches.DATE + "</DATE>`n"
            if($Matches.CONSUMPTION -eq "VM detected")
            {
                $xml += "<CONSUMPTION>" + $Matches.CONSUMPTION + "</CONSUMPTION>`n"
            }
            else
            {
                $xml += "<CONSUMPTION>" + $Matches.CONSUMPTION + " W/h</CONSUMPTION>`n"
            }
            $xml += "<UPTIME>" + $Matches.UPTIME + " s</UPTIME>`n"
            $xml += "</GREENIT>`n"
        }
    }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::WriteLine($xml)