variable "region" {
        default = "us-east-1"
}

variable "instance_name" {
        description = "Name of the instance to be created"
        default = "learn-rust"
}

variable "instance_type" {
        default = "t2.micro"
}

variable "subnet_id" {
        description = "The VPC subnet the instance(s) will be created in"
        default = "subnet-98e06ac7"
}

variable "iam_instance_profile" {
        description = "IAM role for the EC2 instance to access KMS"
        default = "EC2toKMS"
}

variable "vpc_security_group_ids" {
        description = "The VPC Security Group IDs to attach to this instance"
        default = [
            "sg-0070df6d46b3322a2"
        ]
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0fc5d935ebf8bc3bc"
}

variable "number_of_instances" {
        description = "number of instances to be created"
        default = 1
}


variable "instance_key" {
        default = "treebux-ec2-a"
}

variable "user_data" {
    type = string
    default = <<-EOF
    #!/usr/bin/bash
    sudo apt-get update

    # Install aws cli
    echo "*** Installing AWS CLI"
    ## Automatically restart services if prompted
    sudo NEEDRESTART_MODE=a apt-get dist-upgrade --yes
    ## Dependencies
    sudo apt-get install -y unzip libc6 groff less

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    echo "*** Completed Installing AWS CLI"

    # Update apt-get
    echo "*** Updating apt-get"
    sudo apt-get update
    sudo apt-get upgrade
    sudo NEEDRESTART_MODE=a apt-get dist-upgrade --yes # Avoids manual input to prompt for restarting services
    echo "*** Completed Updating apt-get"

    # Install apache2
    echo "*** Installing apache2"
    sudo apt install apache2 -y
    echo "*** Completed Installing apache2"

    # Install Rust and dependencies
    echo "*** Installing Rust and dependencies"
    sudo -i -u ubuntu bash << 'RUST_EOF'
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source $HOME/.cargo/env
      sudo apt update
      sudo apt upgrade
      sudo DEBIAN_FRONTEND=noninteractive apt install build-essential -y
      echo "*** Completed Installing Rust and dependencies"

      # Test Rust
      echo "*** Testing Rust"
      mkdir $HOME/projects
      mkdir $HOME/projects/hello_world
      cd $HOME/projects/hello_world
      touch hello_world.rs
      echo "fn main() {" >> hello_world.rs
      echo "  println!(\"Congratulations! Your Rust program works.\");" >> hello_world.rs
      echo "}" >> hello_world.rs
      rustc hello_world.rs
      ./hello_world
    RUST_EOF
    echo "*** Completed Testing Rust"
  EOF
}

variable "creds" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
