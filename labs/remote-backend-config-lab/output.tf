output "s3_id" {
    value = aws_s3_bucket.bucket.id
}
output "existed_s3-bucket-id" {
    value = aws_s3_bucket.existing_bucket.id
}

output "vpc-id" {
    value = aws_vpc.domain-expansion.id
}