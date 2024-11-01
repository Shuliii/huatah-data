#!/bin/bash

# Get today's date
DATE=$(date +"%Y%m%d")

# Rename old backup
if [ -f backup.sql ]; then
  mv backup.sql backup.sql_$DATE || { echo "Renaming failed!"; exit 1; }
else
  echo "No existing backup.sql found, skipping rename."
fi

# Ensure the MySQL pod is accessible
kubectl get pod mysql-0 > /dev/null 2>&1 || { echo "MySQL pod not found!"; exit 1; }

# Create backup in mysql-0 pod
kubectl exec mysql-0 -- mysqldump -u root -ptest123 Huatah > backup.sql || { echo "Backup failed!"; exit 1; }

echo "Backup successful!"