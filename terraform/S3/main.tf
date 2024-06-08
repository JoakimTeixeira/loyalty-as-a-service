resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.s3_bucket_name
  force_destroy = true // destroy bucket even if it's not empty
}

# Enables state locking for terraform state files with DynamoDB
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    # Defines the name of the hash key
    name = "LockID"
    # Hash key type must be a string
    type = "S"
  }
}
