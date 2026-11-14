$apk = Join-Path $PSScriptRoot 'downloads\grant-compass.apk'
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 8080)
$listener.Start()
try {
  while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
      $client.ReceiveTimeout = 15000
      $client.SendTimeout = 120000
      $stream = $client.GetStream()
      $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $request = $reader.ReadLine()
      while (($line = $reader.ReadLine()) -and $line.Length -gt 0) {}
      if ($request -match '^GET /grant-compass\.apk(?:\s|\?)' -and (Test-Path -LiteralPath $apk)) {
        $body = $null
        $length = (Get-Item -LiteralPath $apk).Length
        $type = 'application/vnd.android.package-archive'
      } else {
        $body = [System.Text.Encoding]::UTF8.GetBytes('<!doctype html><meta name="viewport" content="width=device-width"><title>Grant Compass</title><h1>Grant Compass</h1><p><a href="/grant-compass.apk">Download Android APK</a></p>')
        $length = $body.Length
        $type = 'text/html; charset=utf-8'
      }
      $header = [System.Text.Encoding]::ASCII.GetBytes("HTTP/1.1 200 OK`r`nContent-Type: $type`r`nContent-Length: $length`r`nConnection: close`r`n`r`n")
      $stream.Write($header, 0, $header.Length)
      if ($null -eq $body) {
        $file = [System.IO.File]::OpenRead($apk)
        try { $file.CopyTo($stream) } finally { $file.Dispose() }
      } else { $stream.Write($body, 0, $body.Length) }
    } catch { Write-Warning "Request failed: $($_.Exception.Message)" } finally { $client.Close() }
  }
} finally { $listener.Stop() }
