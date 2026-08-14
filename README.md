# Secure and Automated Network/Health Alerting architecture on AWS

This project stands for a secure, scalable, and fully automated AWS cloud infrastructure provisioned using Infrastructure as Code (IaC) with Terraform. It deploys a multi-subnet VPC, compute instance, remote state management, and automated health alerting.

---

## 📐 Architecture Overview

[AWS Architecture Diagram] -> assets/architecture-diagram.jpeg

### Key Components:
* **Networking:** Virtual Private Cloud (VPC) spanning public and private subnets across an Availability Zone.
* **Compute:** EC2 instance hosted securely inside the private subnet.
* **Security:** Strict inbound/outbound traffic filtering via Security Groups.
* **State Management:** Remote S3 backend for Terraform state file ensuring state locking.
* **Monitoring & Alerting:** CloudWatch CPU utilization alarm triggering real-time Amazon SNS notifications.

---

## 🎯 Business Problem & Architectural Objectives

### 1. Business Problem
Deploying applications directly into public networks or using default AWS configurations introduces significant security risks, operational overhead, and potential downtime. Organizations need a foundational network architecture that:
* **Protects Sensitive Workloads:** Prevents direct, unauthenticated internet exposure of application servers and data stores.
* **Ensures High Availability & Observability:** Automatically detects resource strain (In this case, high CPU usage) and alerts engineering teams before service degradation impacts end users.
* **Guarantees Infrastructure Consistency:** Prevents "configuration drift" and human error caused by manual deployments in the AWS Management Console.

### 2. How This Architecture Solves It
This project implements AWS Networking and Security best practices by isolating resources, automating infrastructure provisioning via Terraform, and adding an automated observability layer on top.

---

## 💡 Architectural Decision-making

### Why a VPC with Both Public and Private Subnets?
* **Single Subnet Architecture Risk:** Placing servers in a single public subnet exposes them to direct public internet traffic, increasing the attack surface. To prevent this, an additional subnet is deployed to place critical resources that must remain private.
* **Two-Subnet Decision:**
  * **Public Subnet:** Reserved for edge routing components (like NAT Gateways) that require direct connectivity to the internet.
  * **Private Subnet:** Reserved for application workloads (EC2 instance). Instances here do not have public IP addresses and are protected from direct external access while retaining outbound access via the NAT Gateway for updates and patches.

### Why Security Groups over Default Settings?
* **Principle of Least Privilege and Security Group implementation:** Default security groups often allow permissive traffic which happens to be insecure for every critical resource. To avoid this, Security best practices are applied using the principle of Least Privilege by adding a custom Security Group that acts as a stateful firewall deployed directly at the instance level. 

Inbound traffic is explicitly limited to required protocols/ports (SSH management from a designated IP and HTTPS traffic from the public subnet), while all unnecessary inbound ports remain blocked.

### Why store Terraform State File remotely with S3?
* **Local State Limitations and S3 implementation:** Storing `terraform.tfstate` locally prevents team collaboration, runs the risk of accidental deletion, and risks committing sensitive state data to public source control. Since this architecture aims to follow best practices, one S3 bucket is used as a centralized, durable remote store for state files with versioning enabled for rollback capabilities, also providing state locking to prevent concurrent execution conflicts that could corrupt the infrastructure state.

### Why CloudWatch Alarm + SNS Alerting?
* **Operations Delays:** Waiting for users to report performance loss leads to strict SLA breaches, therefore, any system needs an automated monitoring and alerting method that is able to track metrics, monitor critical resources and notify users before they notice a failure. To comply with these statements, CloudWatch and SNS services were used as the following:

* **CloudWatch Metric:** Used to track EC2 Instance CPU utilization in real time.
 * **Threshold Alarm (>80%):** Fires an alert as soon as system workload crosses critical performance threshold set in 80%.
* **SNS Topic:** Instantly pushes notifications via Email to operational team as soon as the Threshold Alarm is triggered for rapid incident response.

---

## 🚀 Deployment Advices

1. Ensure there's an IAM user with sufficient permissions to manage VPC, EC2, S3 and SNS Services.
2. The S3 bucket that stores the state file must be deployed before anything else to avoid sudden errors. Run terraform apply command under the file -> s3_backend_main.tf.
3. Update personal IP and sns endpoint email under the variables.tf file. Refer to the variables "sg_ip" and "sns_endpoint".

## 🛠️ Tech Stack & Tools

* **Cloud Provider:** Amazon Web Services (AWS)
* **Infrastructure as Code:** Terraform (= v1.12.2)
* **Compute:** AWS EC2
* **Networking:** AWS VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway, EC2 Instance Connect Endpoint
* **Monitoring:** AWS CloudWatch, AWS SNS
* **State Backend:** AWS S3



