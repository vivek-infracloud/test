resource "aws_key_pair" "personal" {
  key_name   = "amazon-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDekhpzJrZjMUD1G7lJQJVI54m6yCu0HcP6FminKPJwX80aKKsjBvTOOBP7NfK3OmitZFD5HyfgHc+uMWdzog30ezim2a6TKiqGCHgvnppXwtdEdJEQwne2dh8eXp6lX1MNg4TQUFqx7YPmwDpmNEtTnb2Et4Zh2R3/xDlEsXtUBvlu3jNKNUqALbchEjdq+G/CciaMYlI3TsA0t0VRp9CcjmBeDSn7RKKCaO9DPWjm0qR/YABU5zYU+9mF32A/QJME4d6WTV1oPNudR1pvFwYpblq7+2UFf2jaEW1CKDXtc1HF7SuFFiWJL08AEt7bnxI+vFWhZ9GulA2/OO6IFAMkFpL1BfAwzPrX01pcQvxA17pQd4lfOGaHozILnnUaL8h9w3zSiKqu72dr2DihHLowff+RyUB8tI0Y8aTVGya4bEOArV+TVSv8A+vem36LKlJh0JWKpaipsFzDGPkF4WkxSWNFwiULDUEIKrRbHZmHEE01TfijM8o4cSwZvEao/8M= infracloud@infracloud-ThinkPad-E14-Gen-2"
}

resource "aws_instance" "ec2-instance" {

  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = "subnet-6127e62d"
  security_groups             = [var.vpc_security_group_id_for_ec2]
  associate_public_ip_address = true
  key_name                    = "amazon-key"
  depends_on                  = [aws_key_pair.personal]
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 320
  }
  tags = {
    Name = "${var.name}"
  }
  user_data = <<-EOF
    #!/bin/bash
    curl https://releases.rancher.com/install-docker/20.10.sh | sh
    sudo chmod 777 /var/run/docker.sock
    docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher:${var.rancher_version}
    docker logs $(docker ps --format '{{.Names}}') 2>&1 | grep "Bootstrap Password" > dockerpassword.txt
    cat dockerpassword.txt | grep -oP '(?<=Bootstrap Password: )[^ ]*' > bootstrappassword
  EOF
}
