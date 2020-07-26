# terraform-task2

# Problem Statement

## Have to create/launch Application using Terraform

Perform the task-1 using EFS instead of EBS service on the AWS

1. Create Security group which allow the port 80.

2. Launch EC2 instance.

3. In this Ec2 instance use the existing key or provided key and security group which we have created in step 1.

4. Launch one Volume using the EFS service and attach it in your vpc, then mount that volume into /var/www/html

5. Developer have uploded the code into github repo also the repo has some images.

6. Copy the github repo code into /var/www/html

7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.

8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to  update in code in /var/www/html

## Solution for this problem is:
 

### Initial steps:

* Create the repository from where developer will push the code.

* Configure the hooks so that whenever the developer commit the code it will automaically puch the code to github.

## So, this task is same as the task 1 only change is that we have to use the EFS instead of EBS for storage.

## [TASK 1](https://github.com/sara16play/task1terraform.git)

* Changes will apply and we have to use the VPC and subnet for the EFS so we have to first create the VPC and subnets and also security group which has EFS port number allowed.

* And also launch our instance in the same VPC and subnet.

* Find the change code in this link itself and for task 1 go to the link provided below and above.

## [TASK 1](https://github.com/sara16play/task1terraform.git)

## Author

[SAURAV PATEL](https://www.linkedin.com/in/saurav-patel-148539151/)
