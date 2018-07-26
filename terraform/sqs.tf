resource "aws_sqs_queue" "test_queue" {
  name = "repro_bad_event_source_mapping"
}
