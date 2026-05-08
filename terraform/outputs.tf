output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "monitoring_instance_ip" {
  value = aws_instance.monitoring.public_ip
}

output "s3_backup_bucket" {
  value = aws_s3_bucket.backup.id
}
