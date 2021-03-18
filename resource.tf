resource "aws_key_pair" "kops" {
  key_name   = var.cluster_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuRwWMKfaEPrB+YIdernYlA6UY1t6Gmu/FZef3A4R6qQ5XIhs7xegQ/QvlUeRAb0AVal1xUyornLlxCOlQ0fVPP5VmwHPZrQYqcpbbyGz8g2po8wAXGuGgfhOxoslMGxHcD06Bu9V2ydaN/szpjf2j7dLUK4LX/g45kkAThO86/qKWwnmnFAOM1kdgXFQ4LPdXp7O0N7ptsIVwbdiyNPPnq/DykRbDkziynpSeIvy/sRjhlGJ3u3uaLNlAjJfgKq5SSQDKpxKFztlX0RhEQF5TPTJFzflR1UH9gTuLGIskAUdmQnO5W4L1fM4ALceXOiZPhC4ckGe5FQgUGootNXkwQ== ubuntu"
}

resource "aws_instance" "kops" {
  ami           = "ami-0b44050b2d893d5f7" # change latest or anyother AMI Id here
  instance_type = "t3.nano" # Should be changed as you want
  key_name = aws_key_pair.kops.key_name
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.kops.id]
  iam_instance_profile = aws_iam_instance_profile.kops-profile.name


  provisioner "file" {
    source      = "./scripts/startup.sh"
    destination = "/home/ubuntu/startup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/startup.sh",
      # sudo sh /home/ubuntu/startup.sh ZONES_NAME TOPOLOGY MASTER_SIZE MASTER_NODES WORKERS_SIZE WORKERS_NODES WORKERS_VOLUME_SIZE CLUSTER_NAME NETWORKING S3_BUCKET REGION
      "sudo sh /home/ubuntu/startup.sh 'ap-south-1a' 'public' 't2.small' 1 't2.large' 1 50 '${aws_instance.kops.tags["Name"]}' 'calcio' ${aws_s3_bucket.kops_bucket.tags["Name"]} ap-south-1"
    ]
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = ""
    host     = aws_instance.kops.public_ip
    private_key = file("./kops.pem")
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_eip" "kops" {
  instance = aws_instance.kops.id
  vpc      = true
}

resource "aws_s3_bucket" "kops_bucket" {
  bucket = var.s3_name
  acl    = "private"

  region = "us-east-1"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = {
    Name = var.s3_name
  }
}