function Test1 {
    param($iterationCount = 10)
    
    $ms = (Measure-Command {
        for ($i = 0; $i -lt $iterationCount; $i++) {
            Invoke-WebRequest -Uri "https://s3.amazonaws.com/assets-cp/assets/Agent_Uninstaller.zip" -OutFile "$env:TEMP"
        }
    }).TotalMilliseconds
    
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    return $ms
}

function Test2 {
    param($iterationCount = 10)
    
    $ms = (Measure-Command {
        for ($i = 0; $i -lt $iterationCount; $i++) {
            $url = "https://s3.amazonaws.com/assets-cp/assets/Agent_Uninstaller.zip"
            $outPath = Join-Path $PWD.Path "Agent_Uninstaller.zip"

            $CHUNK_SIZE = 1MB
            $request = [System.Net.HttpWebRequest]::Create($url)
            $request.Method = "GET"
            $response = $request.GetResponse()
            $responseStream = $response.GetResponseStream()
            $fs = [System.IO.File]::OpenWrite($outPath)
            $buffer = New-Object byte[] $CHUNK_SIZE
            while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $fs.Write($buffer, 0, $read)
            }
            $fs.Close()
            $responseStream.Close()
            $response.Close()
        }
    }).TotalMilliseconds
    
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    return $ms
}
