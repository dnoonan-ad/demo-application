READ-ME

The first step for the deployment is to build the images in the DB and rates folder using docker build . -t <containername>
push them to a container registry of your choice

Once this has been finished you will need the following:
- The address of the two above containers
- AWS Access Keys with the permissions to run terraform code and build infrastructure in an AWS account 

The AWS Access keys should be entered in the provider file replacing
<AWS_ACCESS_KEY> and <AWS_SECRET_ACCESS_KEY>

The two container addesses will go in the vars.tf file 
- The rates container should go in the api_image var in the place of the default 
- The DB container should go in the db_image var

Once this has been done run terraform init and terraform plan and if there are no errors run terraform apply and the infrastructure will be build

the terraform code will output a DNS address that will allow you to access the container
For testing purposes i used the following:
curl "http://<terraform_output>/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"
(it will take about two mins after you recieve the link for the containers to start)