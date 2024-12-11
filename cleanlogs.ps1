# Comprobar la política de ejecución actual de PowerShell
$ExecutionPolicy = Get-ExecutionPolicy

# Si la política de ejecución no es "RemoteSigned", la establece en "RemoteSigned" de forma forzada.
# La política "RemoteSigned" permite ejecutar scripts sólo si están firmados,
# pero se asume que los scripts locales son de confianza. Esto se hace sin preguntar al usuario.
if ($ExecutionPolicy -ne "RemoteSigned") {
    Set-ExecutionPolicy RemoteSigned -Force
}

# Número de días a conservar los archivos de log antes de borrarlos
$days = 30

# Rutas donde se almacenan los archivos de registro (logs) que se quieren limpiar
$IISLogPath = "C:\inetpub\logs\LogFiles\"
$ExchangeLoggingPath = "C:\Program Files\Microsoft\Exchange Server\V15\Logging\"
$ETLLoggingPath = "C:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\ETLTraces\"
$ETLLoggingPath2 = "C:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\Logs\"

# Definición de la función para limpiar archivos de log
Function CleanLogfiles($TargetFolder) {
    # Muestra información por pantalla (modo debug)
    Write-Host -Debug -ForegroundColor Yellow -BackgroundColor Cyan $TargetFolder

    # Verifica que la carpeta exista
    if (Test-Path $TargetFolder) {
        # Obtiene la fecha actual
        $Now = Get-Date
        # Calcula la fecha límite restando $days a la fecha actual
        $LastWrite = $Now.AddDays(-$days)

        # Obtiene todos los archivos con extensiones .log, .blg o .etl
        # que tengan una fecha de última modificación anterior o igual a $LastWrite
        $Files = Get-ChildItem $TargetFolder -Recurse | 
                 Where-Object { $_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl" } |
                 Where-Object { $_.lastWriteTime -le "$lastwrite" } |
                 Select-Object FullName

        # Elimina cada uno de los archivos seleccionados
        foreach ($File in $Files) {
            $FullFileName = $File.FullName
            Write-Host "Deleting file $FullFileName" -ForegroundColor "yellow"
            Remove-Item $FullFileName -ErrorAction SilentlyContinue | Out-Null
        }
    }
    else {
        # Informa si la carpeta no existe
        Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "red"
    }
}

# Llamadas a la función para limpiar las distintas rutas especificadas
CleanLogfiles($IISLogPath)
CleanLogfiles($ExchangeLoggingPath)
CleanLogfiles($ETLLoggingPath)
CleanLogfiles($ETLLoggingPath2)
