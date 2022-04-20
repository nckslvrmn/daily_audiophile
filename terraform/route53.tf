data "aws_route53_zone" "zone" {
  name = var.dns_domain
}

resource "aws_route53_record" "rss_grid" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.rss_grid.domain_name]
}
