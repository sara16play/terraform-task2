//aws login

provider "aws" {
  region = "ap-south-1"
}

//key-pair

resource "tls_private_key" "taskkey" {
 algorithm = "RSA"
 rsa_bits = 4096
}

resource "aws_key_pair" "key" {
 key_name = "task2key"
 public_key = "${tls_private_key.taskkey.public_key_openssh}"
 depends_on = [
    tls_private_key.taskkey
    ]
}

resource "local_file" "key1" {
 content = "${tls_private_key.taskkey.private_key_pem}"
 filename = "task2key.pem"
  depends_on = [
    aws_key_pair.key
   ]
}


//network.tf
resource "aws_vpc" "test-env" {
   cidr_block = "192.168.0.0/16"
   enable_dns_hostnames = true
   enable_dns_support = true
   tags ={
     Name = "test-env"
   }
 }

 
resource "aws_subnet" "subnet-efs" {
   vpc_id = "${aws_vpc.test-env.id}"
   map_public_ip_on_launch = "true"
   cidr_block = "192.168.0.0/24"
   availability_zone = "ap-south-1a"
 }
resource "null_resource" "nulllocal1"  {

depends_on = [
    aws_vpc.test-env,
  ]
 }
 

//security-group

resource "aws_security_group" "new" {
  vpc_id = "${aws_vpc.test-env.id}"
  name        = "task2sg"
  
  ingress {
    description = "TCP"
    from_port   = 80	
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
     //security_groups = ["${aws_security_group.ingress-efs-test.id}"]
     description = "EFS"
     from_port = 2049
     to_port = 2049
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

  ingress {
     description = "SSH"
     from_port   = 22	
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]

}
  egress {
     from_port   = 0	
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]

}  
  tags = {
    Name = "task2sg"
  }
}

resource "null_resource" "nulllocal2"  {


depends_on = [
    aws_vpc.test-env,
    aws_subnet.subnet-efs
  ]
}

 // efs.tf
resource "aws_efs_file_system" "efs-example" {
   creation_token = "efs-example"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EfsExample"
   }
 }

resource "null_resource" "nulllocal13"  {


depends_on = [
    aws_vpc.test-env,
	aws_subnet.subnet-efs,
	aws_security_group.new
  ]
}

resource "aws_efs_mount_target" "efs-mt-example" {
   file_system_id  = "${aws_efs_file_system.efs-example.id}"
   subnet_id = "${aws_subnet.subnet-efs.id}"
   //vpc_id = "${aws_vpc.test-env.id}"
   security_groups = ["${aws_security_group.new.id}"]
 }
 
 
resource "null_resource" "nulllocal4"  {


depends_on = [
    aws_vpc.test-env,
	aws_subnet.subnet-efs,
	aws_security_group.new,
	aws_efs_file_system.efs-example
  ]
}

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.test-env.id}"
tags ={
    Name = "test-env-gw"
  }
}
resource "null_resource" "nulllocal1301"  {


depends_on = [
    aws_vpc.test-env,
	aws_subnet.subnet-efs,
	aws_security_group.new
  ]
}

resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.test-env.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }
tags ={
    Name = "test-env-route-table"
  }
}

 resource "null_resource" "nulllocal1302"  {


depends_on = [
    aws_internet_gateway.test-env-gw,
	aws_vpc.test-env,
	aws_subnet.subnet-efs,
	aws_security_group.new
  ]
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-efs.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}

resource "null_resource" "nulllocal13011"  {


depends_on = [
    aws_route_table.route-table-test-env,
    aws_internet_gateway.test-env-gw,
	aws_vpc.test-env,
	aws_subnet.subnet-efs,
	aws_security_group.new
  ]
}

//s3-bucket


resource "null_resource" "null2"  {
 provisioner "local-exec" {
   command = "git clone https://github.com/sara16play/task1cloud.git F:/hybrid/tasks/task2/code"
}
}

resource "aws_s3_bucket" "new" {
  bucket = "saratask1play"
  acl    = "public-read"
  force_destroy = "true"
}

resource "aws_s3_bucket_object" "image" {
  bucket = "${aws_s3_bucket.new.id}"
  key    = "sara.png"
  source = "F:/hybrid/tasks/task2/code/sara.png"
  acl = "public-read"
  depends_on = [
    aws_s3_bucket.new
]
}

//cloudfront

resource "aws_cloudfront_distribution" "s3" {
depends_on = [ aws_s3_bucket_object.image]  
origin {
    domain_name = "${aws_s3_bucket.new.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.new.id}"
    
    
}

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "hello"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.new.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "IN"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "null_resource" "nullRemote40" {
   depends_on = [aws_cloudfront_distribution.s3,
                 aws_instance.web,
                 null_resource.nullremote3]
	connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${tls_private_key.taskkey.private_key_pem}"
    host     = aws_instance.web.public_ip
    	}


	provisioner "remote-exec" {
		inline = [
			"sudo sed -i 's@path@https://${aws_cloudfront_distribution.s3.domain_name}/${aws_s3_bucket_object.image.key}@g' /var/www/html/index.html"
		]
	}
}

//aws-ec2-launch

resource "aws_instance" "web" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet-efs.id}"
  vpc_security_group_ids = ["${aws_security_group.new.id}"]
  //security_groups = [ "task2sg" ]
  key_name = "task2key"

  
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${tls_private_key.taskkey.private_key_pem}"
    host     = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git nfs-common -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "sara16paly"
  }
  depends_on = [
    local_file.key1,
    aws_s3_bucket_object.image,
    aws_security_group.new,
    aws_cloudfront_distribution.s3,
    aws_vpc.test-env,
	aws_subnet.subnet-efs,
	aws_security_group.new,
	aws_efs_file_system.efs-example
]
    
}

resource "null_resource" "nullremote3"  {

depends_on = [
    local_file.key1,
    aws_s3_bucket_object.image,
    aws_security_group.new,
    aws_cloudfront_distribution.s3,
    aws_vpc.test-env,
	aws_subnet.subnet-efs,
	aws_security_group.new,
	aws_efs_file_system.efs-example,
        aws_instance.web,
  ]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${tls_private_key.taskkey.private_key_pem}"
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_mount_target.efs-mt-example.mount_target_dns_name}:/ /var/www/html/",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/sara16play/task1cloud.git /var/www/html/",
      "sudo su -c \"echo '${aws_efs_mount_target.efs-mt-example.mount_target_dns_name}:/ /var/www/html/ nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab\""
]
  }
}



resource "null_resource" "nulllocal100"  {


depends_on = [
    null_resource.nullremote3,
     aws_instance.web
  ]

	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.web.public_ip}"
  	}

}



resource "null_resource" "nulllocal10"  {


depends_on = [
    null_resource.nullremote3,
     aws_instance.web
  ]

provisioner "local-exec"{
 command  =   "rd /s /q F:/hybrid/tasks/task2/code"
}

}