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

moved {
  from = aws_route53_record.indexwork[0]
  to   = module.indexwork.aws_route53_record.this[0]
}

moved {
  from = aws_route53_record.lineagework[0]
  to   = module.lineagework.aws_route53_record.this[0]
}

moved {
  from = aws_route53_record.metricwork[0]
  to   = module.metricwork.aws_route53_record.this[0]
}

moved {
  from = aws_route53_record.rootcause[0]
  to   = module.rootcause.aws_route53_record.this[0]
}

moved {
  from = aws_route53_record.internalapi[0]
  to   = module.internalapi.aws_route53_record.this[0]
}