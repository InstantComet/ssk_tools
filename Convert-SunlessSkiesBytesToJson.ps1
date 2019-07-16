#$PSVersionTable.PSVersion
#tested on PowerShell 6.2.1
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$WarningPreference = [System.Management.Automation.ActionPreference]::Inquire

# Location of Game Folders
$BASE_GAME_FOLDER = "C:\GOG Games\Sunless Skies"
$MANAGED_FOLDER = "{0}\Sunless Skies_Data\Managed" -f $BASE_GAME_FOLDER
$GAME_DATA = "{0}\..\LocalLow\Failbetter Games\Sunless Skies\storage\data" -f $env:APPDATA
$GAME_DATA_BACKUPS = "{0}\..\LocalLow\Failbetter Games\Sunless Skies\storage\data_backups" -f $env:APPDATA

# import  
Add-Type -Path ("{0}\Assembly-CSharp.dll" -f $MANAGED_FOLDER)

CD $GAME_DATA

$JsonSerializerSettings = [Newtonsoft.Json.JsonSerializerSettings]::new() 
$JsonSerializerSettings.ReferenceLoopHandling = [Newtonsoft.Json.ReferenceLoopHandling]::Serialize
$JsonSerializerSettings.PreserveReferencesHandling = [Newtonsoft.Json.PreserveReferencesHandling]::Objects
$JsonSerializerSettings.Formatting = [Newtonsoft.Json.Formatting]::Indented

$dataTypes = "areas", "bargains", "domiciles", "events", "exchanges", "personas", "prospects", "qualities", "settings"
foreach ($type in $dataTypes) {
    $br = [System.IO.BinaryReader]::new([System.IO.File]::Open(("{0}\{1}.bytes" -f $GAME_DATA, $type), [System.IO.FileMode]::Open))
    switch ($type) {
        "areas"     { $data = [BinarySerializer.BinarySerializer_Area]::DeserializeCollection($br) }
        "bargains"  { $data = [BinarySerializer.BinarySerializer_Bargain]::DeserializeCollection($br) }
        "domiciles" { $data = [BinarySerializer.BinarySerializer_Domicile]::DeserializeCollection($br) }
        "events"    { $data = [BinarySerializer.BinarySerializer_Event]::DeserializeCollection($br) }
        "exchanges" { $data = [BinarySerializer.BinarySerializer_Exchange]::DeserializeCollection($br) }
        "personas"  { $data = [BinarySerializer.BinarySerializer_Persona]::DeserializeCollection($br) }
        "prospects" { $data = [BinarySerializer.BinarySerializer_Prospect]::DeserializeCollection($br) }
        "qualities" { $data = [BinarySerializer.BinarySerializer_Quality]::DeserializeCollection($br) }
        "settings"  { $data = [BinarySerializer.BinarySerializer_Setting]::DeserializeCollection($br) }
    }
    $data | ConvertTo-Json | Out-File ("{0}.json" -f $type)
    [Newtonsoft.Json.JsonConvert]::SerializeObject($data,$JsonSerializerSettings) | Out-File -FilePath ("{0}/{1}.json" -f $GAME_DATA, $type)
    $br.Close()
}