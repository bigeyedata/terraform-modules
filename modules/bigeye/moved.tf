moved {
  from = aws_route53_record.datawatch[0]
  to   = module.datawatch.aws_route53_record.this[0]
}
