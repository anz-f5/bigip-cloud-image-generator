# How to use the BIG-IP image generator tool to prep images for AWS and Azure

## Overview

You can use the F5 image generator <https://clouddocs.f5.com/cloud/public/v1/ve-image-gen_index.html> to create BIG-IP images for use in public Clouds. This method creates a private machine image and is therefore not limited to the official BIG-IP versions released via the marketplace.

The F5 image generator comes as a multi-component install, or as a docker container.

This document shows the steps required to generate a functional private image with the docker method within both AWS and Azure.

## Common Prerequisite

- Open Virtualization Format Tool (ovftool) – Download from VMware
- Working docker environment
- BIG-IP ISO (with optional EHF ISO)
- Optional hardware virtualization support <https://github.com/f5devcentral/f5-bigip-image-generator/#virtualization-requirements>

## AWS

You can provision a Ubuntu (all major Linux distros should work with the container method) host using i3.metal instance type – this instance type is the cheapest with hardware virtualisation support. The presence of hardware virtualisation speeds up the image creation process, but it is not essential.

Ensure the **root device (/)** has over 100GB of disk space – this is needed to hold all files the image creation process requires

You can also use an existing host, provided it has docker installed and has enough disk space.

Once the host is ready, go through the following steps as a reference.

```bash
cd /home/ubuntu
```

Get ovftool onto the host (need to download from VMware first). Below is an example of getting it via curl.

```bash
curl -OJ https://cz-abgmbh.s3.amazonaws.com/VMware-ovftool-4.4.3-18663434-lin.x86_64.bundle
```

Install ovftool and copy extracted files to local directory.

```bash
chmod +x VMware-ovftool-4.4.3-18663434-lin.x86_64.bundle
sudo ./VMware-ovftool-4.4.3-18663434-lin.x86_64.bundle --eulas-agreed
sudo cp -r /usr/lib/vmware-ovftool /home/ubuntu/vmware-ovftool
```

Get BIG-IP ISO and optional EHF ISO

```bash
curl -OJ https://cz-abgmbh.s3.amazonaws.com/BIGIP-15.1.5-0.0.10.iso
```

Run below to obtain/run the container, enable **hardware virtualisation support** and mount local directory into the container

```bash
sudo docker run -it --device="/dev/kvm" -v "/home/ubuntu:/mnt" f5devcentral/f5-bigip-image-generator:latest
```

Inside the container, run the following

```bash
cp -r /mnt/vmware-ovftool /usr/lib/vmware-ovftool/; sudo chmod +x /usr/lib/vmware-ovftool/ovftool /usr/lib/vmware-ovftool/ovftool.bin;
PATH=$PATH:/usr/lib/vmware-ovftool/:/f5
which ovftool
```

Create config.yml file for the image generator. Check <https://github.com/f5devcentral/f5-bigip-image-generator/#create-config-file> for all options

```yaml
cat << EOF > config.yaml
AWS_ACCESS_KEY_ID: "xxx"
AWS_SECRET_ACCESS_KEY: "xxx"
AWS_BUCKET: "cz-abgmbh" 
AWS_REGION: "us-east-1"
BOOT_LOCATIONS: "1" 
MODULES: "all" 
PLATFORM: "aws"
REUSE: "Yes"
ISO: "/mnt/BIGIP-15.1.4.1-0.0.15.iso"
EOF
```

The image generator creates the image from the ISO and then uploads it to an existing s3 bucket, after which the image is converted into a snapshot, which is eventually registered as an AMI.

The AWS key must carry the appropriate permissions. See this <https://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html#iam-permissions-image> for detail.

As well as a service role named ‘vmimport’ be created. See this <https://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html#vmimport-role> for detail.

Once all the permissions and the role are ready, run the build process as below.

```bash
build-image -c config.yaml
```

The process will generate the image, upload it to the s3 bucket, import it as a snapshot, convert the snapshot as an AMI and finally print out an AWS AMI ID.

## Azure

To generate the image for Azure, the process is that the image generator creates the image, uploads it to an existing storage container, it will then convert that image to an Azure image and place it within the same Azure resource group where the existing storage container is.

A service principal is required with ‘Contributor’ role assignment.

Refer to this <https://github.com/f5devcentral/f5-bigip-image-generator/tree/master/docs/providers/azure> for detail.

Below is a sample config.yaml file.

```yaml
AZURE_APPLICATION_ID: ""
AZURE_APPLICATION_SECRET: ""
AZURE_REGION: ""
AZURE_RESOURCE_GROUP: ""
AZURE_STORAGE_CONNECTION_STRING: "DefaultEndpointsProtocol=https;AccountName=w3pmz53aigsylzhr;AccountKey=uAmlpWVb8Nf1K5UFpXxvK9nU2GJJkyQnwnmhkja4mwuEFeFapzg+gZ7XoiwlQNoj2iAWla2RiffJ+AStnBW4zw==;EndpointSuffix=core.windows.net"
AZURE_STORAGE_CONTAINER_NAME: ""
AZURE_SUBSCRIPTION_ID: ""
AZURE_TENANT_ID: ""
BOOT_LOCATIONS: "1" 
MODULES: "all" 
PLATFORM: "azure"
REUSE: "Yes"
ISO: "/mnt/BIGIP-15.1.4.1-0.0.15.iso"
```

## Terraform

The Terraform code in `ubuntu.tf` in Azure and AWS folders creates a Ubuntu VM in the corresponding Cloud environment for the container to run. The VM is provisioned with an instance type that has hardware virtualisation support built-in as this speeds up the image creation process.

Once the image creation process is completed, `ltm.tf`  references the  created image and provisions a ltm VM with it. When you create the Ubuntu VM, simply move `ltm.tf` to the `temp` folder first prior to running `terraform apply`. Once the image is ready and referenced in `ltm.tf`, move `ltm.tf` back to the Terraform working directory and run `terraform apply` again to create the ltm VM.
