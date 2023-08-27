# **Resume API on AWS**

Create API with AWS Lambda that displays resume in json format. The resume is stored in S3.

# **Architecture Diagram**
![image](https://github.com/pohwj/aws-resume-api-terraform/assets/118417467/0810d87b-a712-4866-ba10-857ca75cc405)



Services used:
1) S3 Bucket: Stores the resume which is in json format
2) API Gateway + Lambda: Fetches the resume from S3 bucket when triggered
3) Terraform: Provision API Gateway, AWS Lambda and S3
4) Github Action: Workflow to run Terraform when triggered
