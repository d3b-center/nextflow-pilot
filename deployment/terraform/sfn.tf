#
# Step Functions resources
#
resource "aws_sfn_state_machine" "default" {
  name     = "${var.project}-${var.environment}"
  role_arn = aws_iam_role.step_functions_service_role.arn

  definition = templatefile("step-functions/etl.json.tmpl", {
    environment                             = var.environment,
    batch_job_definition_arn                = aws_batch_job_definition.default.arn ,
    batch_job_queue_arn                     = aws_batch_job_queue.default.arn
  })
}