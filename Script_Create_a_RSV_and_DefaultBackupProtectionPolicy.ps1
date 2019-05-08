##########################################################################################
#
# .Description
#   Script used for deploy a default Recovery Service Vault and create a default policy
#
##########################################################################################
# .Author:  Eduardo Kieling
# .Blog:    https://eduardokieling.com 
# .Version:    1.0
####################################################################

###### User definition #######################################################################################
#
#
$ResourceGroup = "RG-Kieling"      #Create your Resource Group
$Location = "East US 2"     #Set a location
$BackupVault = "RSV-Kieling"        #Set a name for your Resource Backup Vault
$StorageRedundancy = "GeoRedundant"     #Set a storage redundancy LocallyRedundant (LRS) or GeoRedundant (GRS)
$DefaultPlanName = "Plan-BKP-Kieling" #Set a Backup Protection Policy Name
$BackupTime = "11:00 PM"     #Set a backup time  ***It will be converted to UTC time zone in Azure.
$DailyRetention = 14     #Set a daily retention in days
$WeeklyRetention = 4     #Set a weekly retention in weeks
$MonthlyRetention = 12    #Set a monthly retention in months (last day of each month)
#
#
##############################################################################################################

#Resource Group Criation
New-AzResourceGroup -Name $ResourceGroup -Location $Location 

#Recovery Services Vault criation
$RSV =  New-AzRecoveryServicesVault -Name $BackupVault -ResourceGroupName $ResourceGroup -Location $Location
Set-AzRecoveryServicesBackupProperty -Vault $RSV  -BackupStorageRedundancy $StorageRedundancy

#### Setting retentions
$RETENTION 	= Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureVM -BackupManagementType AzureVM
$RETENTION.IsYearlyScheduleEnabled = $false
$RETENTION.DailySchedule.DurationCountInDays = $DailyRetention
$RETENTION.WeeklySchedule.DurationCountInWeeks = $WeeklyRetention
$RETENTION.MonthlySchedule.DurationCountInMonths = $MonthlyRetention
$RETENTION.MonthlySchedule.RetentionScheduleFormatType = 'Daily'
$RETENTION.MonthlySchedule.RetentionScheduleDaily[0].DaysOfTheMonth[0].Date = 0
$RETENTION.MonthlySchedule.RetentionScheduleDaily[0].DaysOfTheMonth[0].isLast = $true

#### Creating a default backup policy
$Sch = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM" 
$Sch.ScheduleRunTimes.Clear()
$Dt = [datetime]$BackupTime 
$Sch.ScheduleRunTimes.Add($Dt.ToUniversalTime())
New-AzRecoveryServicesBackupProtectionPolicy -Name $DefaultPlanName -WorkloadType AzureVM -RetentionPolicy $RETENTION -VaultId $RSV.ID -SchedulePolicy $Sch
