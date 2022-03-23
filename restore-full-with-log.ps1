function sync-db-files {
     c:
     cd \
     cd 'Logs'

    # Remove All Old backup Files
    Get-ChildItem "C:\Logs\*.*" -Recurse -File | Remove-Item -Force -Verbose -ErrorAction SilentlyContinue
    
    # Get last 1 BAK
    Get-ChildItem "C:\Backups\*.bak" -Recurse -File | select -last 1 | copy-item -Destination "C:\Logs" -Force -Verbose -ErrorAction SilentlyContinue
    
    # Get last n TRN
    Get-ChildItem "C:\Backups\TRN\*.trn" -Recurse -File | select -last 14 | copy-item -Destination "C:\Logs" -Force -Verbose -ErrorAction SilentlyContinue

}

function restore-full-with-log-database {

    c:
    cd \
    cd 'Logs'

    $qry = "USE master `nALTER DATABASE [Your_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE " 

    # 1. Restore one BAK file
    $list = get-childitem -Path C:\Logs -Filter Your_DB*.BAK | Sort-Object -Property name | select -last 1
    $qry = $qry + ( $list | ForEach-Object {"`n`nRESTORE DATABASE [Your_DB] FROM DISK = '$($_.FullName)' WITH  FILE = 1,  MOVE N'Your_DB.mdf' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Your_DB.mdf',  MOVE N'Log.ldf' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Your_DB_log.ldf',  STANDBY = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\ROLLBACK_UNDO_Your_DB.BAK', REPLACE,NOUNLOAD,STATS = 20"}) 
    
    # 2. Restore many Logs
    $list = get-childitem -Path C:\Logs -Filter Your_DB*.trn
    $qry = $qry + ($list | ForEach-Object {"`nRESTORE LOG [Your_DB] FROM DISK = '$($_.FullName)' WITH  FILE = 1,  STANDBY = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\ROLLBACK_UNDO_Your_DB.BAK',  NOUNLOAD,  STATS = 25; "})

    $qry = $qry + "`nALTER DATABASE [Your_DB] SET MULTI_USER " 

    write-host $qry 
    
    Invoke-Sqlcmd -Verbose -Querytimeout 0 -Query $qry -Database 'Your_DB' -ErrorAction SilentlyContinue 

}

# Execute it

# sync-db-files
# restore-full-with-log-database

