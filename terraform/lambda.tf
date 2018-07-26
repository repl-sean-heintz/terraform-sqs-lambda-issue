resource "aws_lambda_function" "worker" {
  function_name = "sqs-worker"
  role          = "${aws_iam_role.worker.arn}"
  handler       = "index.handler"
  runtime       = "nodejs8.10"
  filename      = "../lambda/lambda.zip"
  timeout       = 30
}

resource "aws_lambda_event_source_mapping" "worker" {
  batch_size       = 1
  event_source_arn = "${aws_sqs_queue.test_queue.arn}"
  enabled          = true
  function_name    = "${aws_lambda_function.worker.arn}"
}

resource "aws_lambda_permission" "platform_operations" {
  statement_id  = "AllowSQSInvoke"
  function_name = "${aws_lambda_function.worker.arn}"
  principal     = "sqs.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_sqs_queue.test_queue.arn}"
}

resource "aws_iam_role" "worker" {
  name = "sqs-worker-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "worker" {
  name = "sqs-worker-policy"
  role = "${aws_iam_role.worker.name}"

  # https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-configure-lambda-function-trigger.html
  policy = <<EOF
{
    "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "lambda:InvokeFunction",
                "Resource": [
                  "${aws_lambda_function.worker.arn}"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                  "sqs:ReceiveMessage",
                  "sqs:DeleteMessage",
                  "sqs:ChangeMessageVisibility",
                  "sqs:GetQueueAttributes"
                ],
                "Resource": "${aws_sqs_queue.test_queue.arn}"
            }
        ]
}
EOF
}
