# Self-Managed ECR Installation

This example is intended to illustrate caching the Bigeye ECR images
in your own AWS account vs running ECS tasks directly from images stored 
in Bigeye's ECR.

This is a recommended paradigm for enterprise customers, to cache docker images locally.
Some benefits:
- This allows you to run your own in-house docker vulnerability scanners
- Reduce the cost of pulling docker images over public net on every container start
- Avoids reliance on external infrastructure operate to run the Bigeye service.

See the "Standard" example for more details on general Bigeye stack configuration

## Prerequisites

Contact Bigeye support with your AWS account ID for access to Bigeye docker images.

## Steps

1. Use the Terraform example example in this repo to create local ECR repos in your AWS account.
    NOTE: The ECS services will not start properly until steps 2 & 3 are completed.
2. Run list_bigeye_images.sh to get a list of images available.  Use the last one in the list.  It's the latest and always recommended
3. Run get_bigeye_images.sh to cache all images required in your local ECR

## Configuration

In main.tf there is an example of 
- creating all ECR repos necessary
- Use the image_registry variable to set the ECR path to your local registry

## Scripts
Also included are some helper scripts.  These can be run with -h for more detail.
- list_bigeye_images.sh - lists the image versions available for download
- get_bigeye_images.sh - pulls images from Bigeye's ECR and caches them into your own ECR