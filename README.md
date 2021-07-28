# AWSSPARKWINEAPP

AWSSPARKWINEAPP is an pyspark project. Purpose of this project is to provide python code which can train ML model in parallel on ec2 instances.
This also use  Docker to createa container for ML model simplify deployment.
 
 This project contains 2 main python source files:
 
`wine_prediction.py` read training dataset from S3 and train model in parallel on EMR spark cluster.Once model trained this generate
prediction on given test data provided via S3.This stores trained model in S3 bucket(Public URL for bucket - S3://wine-data-12)

`wine_test_data_prediction.py` loads trained model and execute that model on given testdata file, This 
will print F1 score as metrics for accuracy.

Dockerfile: Dockerfile to create docker image and run container for simplified deployment.

##  Instruction to use:
### 1. How to create Spark cluster in AWS 
User can create spark cluster using EMR console provided by AWS. Please follow steps to create one with 4 ec2 instances.
1. Create Key-Pair for EMR cluster using navigation ```EC2-> Network & Security -> Key-pairs```.
   Use .pem as format. This will download {name of key pair}>.pem file. Keep it safe you will need that 
   to do SSH to EC2 instances.
2. Navigate to Amazon EMR console using link  https://console.aws.amazon.com/elasticmapreduce/home?region=us-east-1. Then, navigate
   to clusters-> create cluster.
3. Now fill respective sections:
   General Configuratin -> Cluster Name 
   Software Configuration-> EMR 5.33 , do select 'Spark: Spark 2.4.7 on Hadoop 2.10.1 YARN and Zeppelin 0.9.0' option menu.
   Harware Configuration -> Make instance count as 4
   Security Access -> Provide .pem key created in above step.
   Rest of parameters can be left default.
   
  User can also create spark cluster using below aws cli command:
  ```
  aws emr create-cluster --applications Name=Spark Name=Zeppelin --ebs-root-volume-size 10 --ec2-attributes '{"KeyName":"ec2-spark","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-42c0ca0f","EmrManagedSlaveSecurityGroup":"sg-0d7ed2552ba71f5af","EmrManagedMasterSecurityGroup":"sg-0e853f0a4bdc5f799"}' --service-role EMR_DefaultRole --enable-debugging --release-label emr-5.33.0 --log-uri 's3n://aws-logs-367626191020-us-east-1/elasticmapreduce/' --name 'My cluster' --instance-groups '[{"InstanceCount":3,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"CORE","InstanceType":"m5.xlarge","Name":"Core Instance Group"},{"InstanceCount":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"MASTER","InstanceType":"m5.xlarge","Name":"Master Instance Group"}]' --scale-down-behavior TERMINATE_AT_TASK_COMPLETION --region us-east-1
  ```
  
4. Cluster status should be 'Waiting'.

### 2. How to train ML model in Spark cluster with 4 ec2 instances in parallel
1. Cluster is ready to accept jobs, To submit one you can either use step button to add steps or submit manually.
   To submit manually, Perform SSH to Master of cluster using below command:
```
        ssh -i "ec2key.pem" <<User>>@<<Public IPv4 DNS>>
        
```
2. On successful login to master , change to root user by running command:
  ```
  sudo su
  ```
3. Submit job using following command:
 ```
   spark-submit s3://wine-data-12/wine_prediction.py
 ```
4. You can trace status of this job in EMR UI application logs. Once status is succeded a test.model will be created in s3 bucket-s3://wine-data-12.


### 3. How to run trained ML model locally without docker.
1. Clone this repository.
2. Make sure you have spark environment setup locally for running this. To setup one follow link https://spark.apache.org/docs/latest
3. Install pyspark, you can use pip -m install pyspark. Or use `` conda``
4. Once setup is ready execute below command:
   place the testdata file in current directory and execute following command
 ``` 
 cd awssparkwineapp
 spark-sumit wine_test_data_prediction.py ./<filename>
 ```
 
### 4. Run ML model using Docker
1. Install docker where you want to run this container
2. Docker pull dfordeepika/awssparkwineapp
3. Place your testdata file in a folder (let call it directory dirA) , which you will mount with docker container.
4. docker run -v {directory path for data dirA}:/code/data/csv dfordeepika/awssparkwineapp {testdata file name}
 Sample command
```
docker run -v /Users/deepika/workspace/deepika-cs-643/awssparkwineapp/data/csv:/code/data/csv dfordeepika/awssparkwineapp testdata.csv

```

