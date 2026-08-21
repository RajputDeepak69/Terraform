output "s3_id" {
    value = aws_s3_bucket.bucket.id
}
output "vpc-id" {
    value = aws_vpc.domain-expansion.id
}