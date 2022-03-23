function restore-full-database {

	# Goto Backup Folder
	c:
	cd \
	cd 'C:\Backups'

	# Change your databbase name
	# Create a restore script C:\restore_full_database.sql (Optional)

		$qry = "USE master `nALTER DATABASE [Your_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE `n" #| Out-File -FilePath  C:\restore_full_database.sql

	#
	# Change your databbase logical name and Location
	#

	# Get the last full database backup
		$list = get-childitem -Path 'C:\Backups' -Filter *.BAK | Sort-Object -Property name | select -last 1

		$qry = $qry + ($list | ForEach-Object {"`nRESTORE DATABASE [Your_DB] FROM DISK = `n'$($_.FullName)' `nWITH  FILE = 1, `nMOVE N'File_DB' `nTO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\file_db.mdf', `nMOVE N'File_log' `nTO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\file_log.ldf', `nNOUNLOAD,  REPLACE,  STATS = 25"}) # | Out-File -FilePath  C:\restore_full_database.sql -Append)

		$qry = $qry + " `n `nALTER DATABASE [Your_DB] SET MULTI_USER `n " #| Out-File -FilePath  C:\restore_full_database.sql -Append

		cls
		Write-host $qry

		Invoke-Sqlcmd -Verbose -Querytimeout 0 -Query $qry -Database 'Your_DB' -ErrorAction SilentlyContinue 
}

# Execute it
# restore-full-database-database
