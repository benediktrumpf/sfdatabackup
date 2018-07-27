#!/bin/bash
# backup SF Data
# Written by benedikt.rumpf@caroobi.com

# set variables to be used later
PASSWORD='yourpassword'
NOW=$(date +"%d_%m_%Y")
SCRIPT_PATH='/home/bene/SFBackup/Scripts/sendmail.py'
PYTHON='/usr/bin/python3'

#login to salesforce. Here we use the system user as the PW never changes
/home/bene/bin/force login -i=login.salesforce.com -u=yourusername -p=$PASSWORD

# specify how the fields are retrieved. This function queries all fields from
# the specified object. The object is specified within the query
function getfields()
{
  FIELDS=$($HOME/bin/force field list $1 | sed 's/\:.*/,/' )
  LIST=${FIELDS::-1}
  echo $LIST
}

# create folder with todays date for plain files
mkdir /home/bene/SFBackup/Backup_Folders/$NOW-data

# iterate over all objects in salesforce to get the fields for the query
# Since our attachments are 18GB at this point, they will be excluded from the
# query. Not only to save space but also to save on API calls
array=$(/home/bene/bin/force sobject list)
for i in ${array[@]}; do
    if [[ $i == "Attachment" ]]; then
      :
    elif [[ $i == "ApexClass" ]]; then
      :
    elif [[ $i == "ApexComponent" ]]; then
      :
    elif [[ $i == "ApexPage" ]]; then
      :
    elif [[ $i == "ApexPageInfo" ]]; then
      :
    elif [[ $i == "ApexTestResult" ]]; then
      :
    elif [[ $i == "ApexTestResultLimits" ]]; then
      :
    elif [[ $i == "ApexTestRunResult" ]]; then
      :
    elif [[ $i == "ApexTrigger" ]]; then
      :
    elif [[ $i == "AsyncApexJob" ]]; then
      :
    elif [[ $i == "ConnectedApplication" ]]; then
      :
    elif [[ $i == "CollaborationGroupRecord" ]]; then
      :
    elif [[ $i == "ContentDocumentLink" ]]; then
      :
    elif [[ $i == "ContentFolderItem" ]]; then
      :
    elif [[ $i == "ContentFolderMember" ]]; then
      :
    elif [[ $i == "DatacloudAddress" ]]; then
      :
    elif [[ $i == "DataStatistics" ]]; then
      :
    elif [[ $i == "EntityParticle" ]]; then
      :
    elif [[ $i == "FieldDefinition" ]]; then
      :
    elif [[ $i == "FileSearchActivity" ]]; then
      :
    elif [[ $i == "FlexQueueItem" ]]; then
      :
    elif [[ $i == "IdeaComment" ]]; then
      :
    elif [[ $i == "LeadShare" ]]; then
      :
    elif [[ $i == "ListViewChartInstance" ]]; then
      :
    elif [[ $i == "LoginGeo" ]]; then
      :
    elif [[ $i == "LoginHistory" ]]; then
      :
    elif [[ $i == "LoginIp" ]]; then
      :
    elif [[ $i == "MacroHistory" ]]; then
      :
    elif [[ $i == "MacroShare" ]]; then
      :
    elif [[ $i == "OutgoingEmail" ]]; then
      :
    elif [[ $i == "OwnerChangeOptionInfo" ]]; then
      :
    elif [[ $i == "PicklistValueInfo" ]]; then
      :
    elif [[ $i == "PlatformAction" ]]; then
      :
    elif [[ $i == "ProcessInstance" ]]; then
      :
    elif [[ $i == "ProcessInstanceNode" ]]; then
      :
    elif [[ $i == "RelationshipDomain" ]]; then
      :
    elif [[ $i == "RelationshipInfo" ]]; then
      :
    elif [[ $i == "SearchLayout" ]]; then
      :
    elif [[ $i == "UserEntityAccess" ]]; then
      :
    elif [[ $i == "UserFieldAccess" ]]; then
      :
    elif [[ $i == "VisualforceAccessMetrics" ]]; then
      :
    elif [[ $i == "Vote" ]]; then
      :
    elif [ $(echo $(/home/bene/bin/force describe -t=sobject -n=$i) | jq '.queryable') == false ]; then
      :
    else
      /home/bene/bin/force query "SELECT $(getfields $i) from $i" > $HOME/SFBackup/Backup_Folders/$NOW-data/$i.csv
    fi
done

# cleanup objects that cannot be queried or don't hold data
find /home/bene/SFBackup/Backup_Folders/$NOW-data -size  0 -print0 |xargs -0 rm --

# zip the files and move them to the backup files folders
cd /home/bene/SFBackup/Backup_Folders
zip -r $NOW-data.zip $NOW-data
mv $NOW-data.zip /home/bene/SFBackup/Backup_Files

# send the email to Hendrik, Lisa, Atul and myself. This mail also contains the backup
# of the metadata
#$PYTHON $SCRIPT_PATH
