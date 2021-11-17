#Multi-Cloud IaC Deployment automation for Azure & AWS using customized image with pre-installed softwares ( Jenkins, Docker, Helm etc). 

### Prerequisite: Linux ubuntu, git
1. Clone the github repo in your ubuntu machine:
   ```
   $ git clone https://github.com/satender346/IaC-packer-terraform-multi-cloud.git
   ```
2. Change directory to 'IaC-packer-terraform-multi-cloud' and Install packer, terraform, aws-cli and azure-cli by running the shell script
    ``` 
      $ cd IaC-packer-terraform-multi-cloud
      $ steps_to_install_packer_terraform_awsCli_azureCli.sh
   ```
3. export aws secrets on the terminal.(find aws secrets on the aws account ui) Run below export commands:
   ```
   $ cd packer_ami_with_jenkins
   $ export AWS_ACCESS_KEY_ID=
   $ export AWS_SECRET_ACCESS_KEY=
   $ export AWS_DEFAULT_REGION=us-west-1
   ```
4. Add azure secrets in the 'variables.pkr.hcl' file and 'variables.tf' file. Run below commands to run the packer script.
   ```
   $ packer init .
   $ packer build .
   $ cd ..
   ```
5. Run below commands to setup aws-instance and azure instance for the eks and aks deployments:
   ```
   $ terraform init
   $ terraform plan --auto-approve
   $ terraform apply --auto-approve
   ```
7. Once instance finish it will give public ip for both the clouds(azure and aws). Copy those ip's, because instance and jenkins will be running on that ip. \
   a. open jenkins in browser using instance-ip:8080 \
   b. Login to instance using ssh devops@instance-public-ip and provide password 'devops' \
   c. To login to jenkins, username will be 'admin' and get initial password by running the below command into the instance terminal:
     ```
     $ sudo cat /var/jenkins_home/secrets/initialAdminPassword
     ```
   d. from jenkins ui click build button for all below jobs in the same order one by one.
       IaC-eks-aks-cluster-pipeline : Job will create EKS cluster in AWS and AKS cluster in Azure
      ```
      1 IaC-eks-aks-cluster-pipeline

   e. Iac-eks-aks-cluster pipeline outputs the kubernetes config, copy and save that config on the instance machine and you can access the kubernetes cluster.
