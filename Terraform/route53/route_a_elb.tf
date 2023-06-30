data "aws_elb" "elb-preset" {
  name = "elb-preset"
}

resource "aws_route53_zone" "innfis-dns" {
  name = "innfis.com"
}

resource "aws_route53_record" "initial-record" {
  zone_id = aws_route53_zone.innfis-dns.zone_id
  name = "dev.innfis.com"
  type = "A"

  alias {
    name = aws_elb.elb-preset.dns_name
    zone_id = aws_elb.elb-preset.zone_id
    evaluate_target_health = true
  }
}

