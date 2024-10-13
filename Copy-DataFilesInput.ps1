$inputPath = "c:/input"
$utFile = "./unit_test/tt_timer_set.purely_wrap_timer_set_inp.json"
$csvFile = "./fantasy_premier_league_player_stats.csv"

$IsFolder = $true
if (Test-Path $inputPath) {

    if (Test-Path -PathType Container $inputPath) {
        "The item $inputPath is a folder, copy there..."
    } else {
        "The item $inputPath is a file, aborting..."
        $IsFolder = $false
    }

} else {

    "The item $inputPath does not exist, creating folder..."
    New-Item -ItemType Directory -Force -Path $inputPath

}
if ($IsFolder) {
    Copy-Item $utFile $inputPath
    "Copied $utFile to $inputPath"
    Copy-Item $csvFile $inputPath
    "Copied $csvFile to $inputPath"
}