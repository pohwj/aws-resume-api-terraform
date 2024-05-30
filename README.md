# **Resume API on AWS Lambda**

Create an API with AWS Lambda that displays resume in json format. The resume is stored in S3.

# **Architecture Diagram**
![serverless-diagram](https://github.com/pohwj/aws-resume-api-terraform/assets/118417467/fa8285d3-ff18-42c2-87ae-8dc347c462db)

Services used:
1) S3 Bucket: Stores the resume in json format. The content in this resume was taken from https://jsonresume.org/schema/
2) API Gateway + Lambda: Fetches and displays the resume from S3 when deployed
3) Terraform: Provision S3 bucket, API Gateway and Lambda
4) Github Actions: Workflow to run Terraform when triggered

API URL: https://s2gxped427.execute-api.ap-southeast-1.amazonaws.com/dev/serverless-api-gw

Blog post: https://pohwj.hashnode.dev/create-api-with-aws-lambda

References:

https://jsonresume.org/schema/

https://www.youtube.com/watch?v=UllPQzVXYtU

https://www.youtube.com/watch?v=-pKrT7Ix3G0
