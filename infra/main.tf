resource "aws_lambda_function" "myfunc" {
  filename         = data.archive_file.zip_the_python_code.output_path
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  function_name    = "serverless-lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "serverless-lambda.lambda_handler"
  runtime          = "python3.9"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "iam_policy_for_serverless_lambda" {

  name        = "aws_iam_policy_for_serverless_lambda"
  path        = "/"
  description = "AWS IAM Policy for managing the serverless lambda function"
  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource : "arn:aws:logs:*:*:*",
          Effect : "Allow"
        },
        {
          Effect : "Allow"
          Action : [
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = [
            "arn:aws:s3:::serverless-resume-bucket",
            "arn:aws:s3:::serverless-resume-bucket/*"
          ]
        },
      ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_serverless_lambda.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/serverless-lambda.py"
  output_path = "${path.module}/lambda/serverless-lambda.zip"
}

resource "aws_s3_bucket" "serverless_bucket" {

  bucket = "serverless-resume-bucket"
  tags = {
    Name        = "serverless-resume-bucket"
    Environment = "dev"
  }
}

resource "aws_s3_object" "serverless_bucket_object" {
  bucket = aws_s3_bucket.serverless_bucket.id
  key    = "resume.json"
  source = "${path.module}/resume.json"
}

resource "aws_api_gateway_rest_api" "my-api-gw" {
  name        = "serverless-api-gw"
  description = "Example REST API for demonstration purposes"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "my-api-gw-resource" {
  rest_api_id = aws_api_gateway_rest_api.my-api-gw.id
  parent_id   = aws_api_gateway_rest_api.my-api-gw.root_resource_id
  path_part   = "serverless-api-gw"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.my-api-gw.id
  resource_id   = aws_api_gateway_resource.my-api-gw-resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.my-api-gw.id
  resource_id             = aws_api_gateway_resource.my-api-gw-resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.myfunc.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myfunc.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my-api-gw.execution_arn}/v1/GET/*"
}

resource "aws_api_gateway_stage" "api-gw-stage" {
  rest_api_id   = aws_api_gateway_rest_api.my-api-gw.id
  deployment_id = aws_api_gateway_deployment.api-gw-deployment.id
  stage_name    = "v1"
}

resource "aws_api_gateway_deployment" "api-gw-deployment" {
  rest_api_id = aws_api_gateway_rest_api.my-api-gw.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.my-api-gw.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.integration, aws_api_gateway_method.get_method
  ]

}
