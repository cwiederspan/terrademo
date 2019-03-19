## Testing
terraform plan -var-file=secrets.tfvars

## Production
terraform plan -state=terraform-prod.tfstate -var-file=secrets-prod.tfvars