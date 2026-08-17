variable "CIDR" {
    description = "cidr for the main vpc"
    default = "10.0.0.0/20"
}
variable "CIDRs" {
    description = "list of CIDRs for security groups ..."
    default = ["10.0.0.0/20"]
}
