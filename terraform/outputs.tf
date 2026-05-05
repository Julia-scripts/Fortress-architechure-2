output "alb_dns_name" {
  description = "The URL of your website"
  value       = aws_lb.fortress_alb.dns_name
}