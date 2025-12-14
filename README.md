# Uptime Monitor (serverless)


Serverless uptime monitoring project using AWS Lambda, DynamoDB, EventBridge, and CloudWatch.


# Requirements

- AWS CLI
- Terraform
- Python + Pip


## What it does
- Periodically (default: every 5 minutes) checks configured URLs
- Stores results in DynamoDB with timestamped entries
- Publishes custom CloudWatch metrics (availability, latency)


## Quickstart (manual)
1. Build the lambda artifact:


```powershell
.\lambda\package_and_deploy.ps1
```


2. Initialize terraform


```powershell
cd terraform
terraform init
```


3. (Optional) Review terraform operations


```powershell
terraform plan
```


4. Deploy


```powershell
terraform apply
```


## Verify

```powershell
aws lambda invoke `
  --function-name uptime-monitor `
  output.json
```


## Teardown


1. (Optional) Review plan


```powershell
cd terraform
terraform plan -destroy
```


2. Destroy


```powershell
terraform destroy
```