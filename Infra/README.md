## Testing
terraform plan -var-file=secrets.tfvars

## Production
terraform plan -state=terraform-prod.tfstate -var-file=secrets-prod.tfvars

## Renew SSL Certificates

```bash

# Get to the correct directory
cd /mnt/c/Temp/certbot

# Run the certbot container in Docker
docker run -it --rm --name certbot \
  -v $PWD/volumes/letsencrypt:/etc/letsencrypt \
  -v $PWD/volumes/lib:/var/lib/letsencrypt \
  certbot/certbot certonly --manual \
  -d terrademo.com -d www.terrademo.com \
  -m chwieder@microsoft.com \
  --no-eff-email \
  --agree-tos \
  --manual-public-ip-logging-ok

# Create an authentication file per the instructions
touch XXX

# Copy the key into the new file
echo ZZZ > XXX

# Upload the new file to Azure Blob Storage

# REPEAT AS NEEDED

# Once the Certbot approval is complete
cd letsencrypt/archive/terrademo.com

# Convert the file to a PFX file (Password is empty)
openssl pkcs12 -export -out certificate.pfx -inkey privkeyN.pem -in certN.pem -certfile chainN.pem

# Upload this file to the Azure Key Vault

# Rerun the Terraform Infra pipeline
https://dev.azure.com/ateamsw/Terrademo/_release?_a=releases&view=mine&definitionId=3

```
