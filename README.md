# Basic Two-Tier AWS Architecture

This provides a template for running a simple two-tier architecture on Amazon
Web services. The premise is that you have a VPC, and an app server running behind
an ELB serving traffic.

After you run `terraform apply` on this configuration, it will
automatically output the DNS address of the ELB. After your instance
registers, this should respond with the default nginx web page.

Create an "aws_provider_override.tf" file and enter your real secret key and access key.
Create a terraform.tfvars file and enter the values for the variables aws_region, availability_zone, key_path and key_name.

Run with a command like this:

```
terraform apply -var 'key_name={your_aws_key_name}' \
   -var 'key_path={location_of_your_key_in_your_local_machine}'` 
```

For example:

```
terraform apply -var 'key_name=terraform' -var 'key_path=/Users/jsmith/.ssh/terraform.pem'
```
