#!/bin/bash -x

# shellcheck disable=SC1091
source /root/variables.sh

# Function to run in case of an error
error_handler() {
    echo "An error occurred during provisioning. Shutting down this instance so ASG could start a new one."
    shutdown -h now
}

get_metadata_and_curl() {
  # URL passed as argument
  local url="$1"

  # Determine if we have IMDSv2 enabled (by checking the existence of the token endpoint)
  local token=""
  if curl -s --head --request GET "http://169.254.169.254/latest/api/token" | grep -q "HTTP/1.1 400 Bad Request"; then
    # If the IMDSv2 token endpoint returns 400, it's IMDSv1
    echo "IMDSv1 detected (no token required)" >&2
  else
    # If the IMDSv2 token endpoint exists, IMDSv2 is in use and requires a token
    echo "IMDSv2 detected (token required)" >&2
    # Get the session token for IMDSv2
    token=$(curl -s --request PUT --header "X-aws-ec2-metadata-token-ttl-seconds: 21600" "http://169.254.169.254/latest/api/token")
    if [[ -z "$token" ]]; then
      echo "Failed to retrieve token for IMDSv2"
      return 1
    fi
  fi

  # Now use curl to access the metadata or another URL with the proper token (if IMDSv2)
  if [[ -n "$token" ]]; then
    # Use IMDSv2 token in the header for curl request
    curl -s --header "X-aws-ec2-metadata-token: $token" "$url"
  else
    # No token needed for IMDSv1
    curl -s "$url"
  fi
}

# Set up trap to catch any error and call error_handler
trap 'error_handler' ERR

set -e

# Variables
INSTANCE_ID=$(get_metadata_and_curl http://169.254.169.254/latest/meta-data/instance-id)
DEVICE_NAME="/dev/xvdf"
MOUNT_POINT="/mnt/solr-data"

mkdir -p $MOUNT_POINT

# Retry settings
RETRY_INTERVAL=5  # Retry interval in seconds

yum install -y aws-cli ec2-instance-connect amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

REGION=$(get_metadata_and_curl http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
export AWS_REGION=$REGION
export AWS_DEFAULT_REGION=$REGION # for aws-cli v1 compatibility

attach_volume() {
    echo "Attaching volume $VAR_VOLUME_ID to instance $INSTANCE_ID as $DEVICE_NAME..."

    START_TIME=$SECONDS
    MAX_DURATION=180  # Total retry duration in seconds (3 minutes)
    while [ $((SECONDS - START_TIME)) -lt $MAX_DURATION ] && [ ! -b "$DEVICE_NAME" ]; do
        if aws ec2 attach-volume --volume-id "$VAR_VOLUME_ID" --instance-id "$INSTANCE_ID" --device "$DEVICE_NAME"
        then
            echo "attach-volume call has been successful."
            sleep 5 # it needs some time to attach
            return 0  # Success
        else
            echo "Failed to attach volume $VAR_VOLUME_ID."
            sleep $RETRY_INTERVAL
            ELAPSED=$((SECONDS - START_TIME))
            echo "Retrying... Elapsed time: ${ELAPSED} seconds, remaining $((MAX_DURATION - ELAPSED)) seconds."
        fi
    done
    return 1  # Failure
}

attach_volume

# Double check that device exists
if [ ! -b "$DEVICE_NAME" ]; then
    echo "Error: Device $DEVICE_NAME does not exist."
    error_handler
fi

NVME_DEVICE_NAME=$(lsblk $DEVICE_NAME --output NAME --noheadings --nodeps)

# Check if there are existing partitions on the device
PARTITIONS=$(awk '{print $4}' < /proc/partitions | grep -E "${NVME_DEVICE_NAME}p[0-9]+" || echo "")

PARTITION="/dev/${NVME_DEVICE_NAME}p1"
NEW_PARTITION=false
if [ -z "$PARTITIONS" ]; then
    echo "No partitions found on /dev/${NVME_DEVICE_NAME}. Creating a new partition."

    # Use parted to create a new partition
    yum install -y parted
    parted -s "/dev/${NVME_DEVICE_NAME}" mklabel gpt
    # Create a partition from 1MB to the end of the volume, type xfs
    parted -s "/dev/${NVME_DEVICE_NAME}" mkpart primary xfs  1MB 100%

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
    echo "Partitions already exist on $NVME_DEVICE_NAME."
    echo "Partitions found: $PARTITIONS"
fi

mount "$PARTITION" "$MOUNT_POINT"

if [ $NEW_PARTITION == "true" ]; then
    chown -R 8983 $MOUNT_POINT # 8983 is solr userid inside the container
fi

echo ECS_CLUSTER="$VAR_ECS_CLUSTER" > /etc/ecs/ecs.config
