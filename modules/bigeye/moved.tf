# This file will be deleted with the next major version release of this module

moved {
  from = aws_route53_record.datawatch[0]
  to   = module.datawatch.aws_route53_record.this[0]
}

moved {
  from = aws_route53_record.datawork[0]
  to   = module.datawork.aws_route53_record.this[0]
}

moved {
  from = aws_route53_record.backfillwork[0]
  to   = module.backfillwork.aws_route53_record.this[0]
}
