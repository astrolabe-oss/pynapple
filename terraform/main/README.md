### Local Setup

#### Prereqs cli programs:
* kubectl
* aws 
* OpenTofu >= 1.9 (becuae we are using it's `for_each` for `provider` functionality)

## How to deploy it
1. Create SSH key pair in AWS
   1. Download/save the private and public key
   2. Either name it `pynapple_key_pair` or pass the name into terraform as `var=key_pair_name`
1. Fill out the backend block
1. Deploy
   ```bash
   tofu apply var="key_pair_name=my_key_pair" var="aws_account_id=my_aws_account_id"
```