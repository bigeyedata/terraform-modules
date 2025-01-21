#!/bin/bash -x

source /root/variables.sh

# Function to run in case of an error
error_handler() {
    echo "An error occurred during provisioning. Shutting down this instance so ASG could start a new one."
    shutdown -h now
}

# Set up trap to catch any error and call error_handler
trap 'error_handler' ERR

set -e

# Variables
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
DEVICE_NAME="/dev/xvdf"
MOUNT_POINT="/mnt/solr-data"

mkdir -p $MOUNT_POINT

# Retry settings
RETRY_INTERVAL=5  # Retry interval in seconds

yum install -y aws-cli

REGION=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
export AWS_REGION=$REGION
export AWS_DEFAULT_REGION=$REGION # for aws-cli v1 compatibility

attach_volume() {
    echo "Attaching volume $VAR_VOLUME_ID to instance $INSTANCE_ID as $DEVICE_NAME..."

    aws ec2 attach-volume --volume-id "$VAR_VOLUME_ID" --instance-id "$INSTANCE_ID" --device "$DEVICE_NAME"

    if [ $? -eq 0 ]; then
        echo "attach-volume call has been successful."
        sleep 5 # it needs some time to attach
        return 0  # Success
    else
        echo "Failed to attach volume $VAR_VOLUME_ID."
        return 1  # Failure
    fi
}

START_TIME=$SECONDS
MAX_DURATION=180  # Total retry duration in seconds (3 minutes)
while [ $((SECONDS - START_TIME)) -lt $MAX_DURATION ] && [ ! -b "$DEVICE_NAME" ]; do
    attach_volume && break
    echo "Retrying... (elapsed time: $((SECONDS - START_TIME)) seconds)"
    sleep $RETRY_INTERVAL
done

# Double check that device exists
if [ ! -b "$DEVICE_NAME" ]; then
    echo "Error: Device $DEVICE_NAME does not exist."
    error_handler
fi

# Check if there are existing partitions on the device
PARTITIONS=$(cat /proc/partitions | awk '{print $4}' | grep -E "${DEVICE_NAME##*/}[0-9]+" || echo "")

PARTITION="${DEVICE_NAME}1"
NEW_PARTITION=false
if [ -z "$PARTITIONS" ]; then
    echo "No partitions found on $DEVICE_NAME. Creating a new partition."

    # Use parted to create a new partition
    yum install -y parted
    parted -s $DEVICE_NAME mklabel gpt
    # Create a partition from 1MB to the end of the volume, type xfs
    parted -s $DEVICE_NAME mkpart primary xfs  1MB 100%

    # Check if the partition was created successfully
    if [ ! -b "$PARTITION" ]; then
        echo "Error: Failed to create partition $PARTITION."
        error_handler
    fi

    echo "Partition created: $PARTITION"

    mkfs.xfs "$PARTITION"
    echo "Partition $PARTITION formatted with xfs."
    NEW_PARTITION=true
else
    echo "Partitions already exist on $DEVICE_NAME."
    echo "Partitions found: $PARTITIONS"
fi

mount "$PARTITION" "$MOUNT_POINT"

if [ $NEW_PARTITION == "true" ]; then
    chown -R 8983 $MOUNT_POINT # 8983 is solr userid inside the container
fi

echo ECS_CLUSTER=$VAR_ECS_CLUSTER > /etc/ecs/ecs.config
