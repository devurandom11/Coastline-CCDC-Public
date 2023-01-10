# AWS VM Import

## __Configure AWS CLI__

Windows Install:

```
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

Linux Install:

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Confirm Version

```
aws --version
```

Configure

```
aws configure
<Access Key ID>
<Secret Access Key>
<Default Region Name>
```


## __Create Required Service Role__

Create a file named `trust-policy.json` containing the following policy:

```
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
```

Use the create-role command to create a role named vmimport and grant VM Import/Export access to it.

```
aws iam create-role --role-name vmimport --assume-role-policy-document "file://C:\import\trust-policy.json"
```

Create a file named `role-policy.json` with the following policy:

```
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket" 
         ],
         "Resource": [
            "arn:aws:s3:::disk-image-file-bucket",
            "arn:aws:s3:::disk-image-file-bucket/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetBucketAcl"
         ],
         "Resource": [
            "arn:aws:s3:::export-bucket",
            "arn:aws:s3:::export-bucket/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }
   ]
}
```

Use the following `put-role-policy` command to attach the policy to the role created above.

```
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://C:\import\role-policy.json"
```

## __Import VM as Image__

Use `import-image` to import an image with a single disk:

```
aws ec2 import-image --description "My server VM" --disk-containers "file://C:\import\containers.json"
```

Create a `containers.json` file that specifies the image using an S3 bucket:

```
[
  {
    "Description": "My Server OVA",
    "Format": "ova",
    "UserBucket": {
        "S3Bucket": "<bucket>",
        "S3Key": "<vm.ova>"
    }
  }
]
```

Monitor Import Progress:

```
aws ec2 describe-import-image-tasks --import-task-ids <import-id>
```

Once finished, import your image as an EC2 instance custom AMI.