# CloudWatch Logs グループ作成
resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-aws-study" # スラッシュなし
  retention_in_days = 7
}

# WAF ロギング用 IAM ロール
resource "aws_iam_role" "waf_logging_role" {
  name = "WAFLoggingRole_aws_study"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "wafv2.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM ポリシー
resource "aws_iam_role_policy" "waf_logging_policy_doc" {
  name = "WAFLoggingToCloudWatch"
  role = aws_iam_role.waf_logging_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",    # 追記: LogGroup 内のストリーム作成権限
          "logs:PutLogEvents"       # 追記: LogGroup へのログ書き込み権限
        ]
        #修正: Resource="*" を LogGroup のみに限定
        Resource = "${aws_cloudwatch_log_group.waf.arn}:*"  # 追記: LogGroup 内すべてのストリーム
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",   # 追記: LogGroup 情報参照
          "logs:DescribeLogStreams"   # 追記: ストリーム情報参照
        ]
        Resource = aws_cloudwatch_log_group.waf.arn  # 修正:LogGroup のみに限定
      }
    ]
  })
}

# WAF WebACL
resource "aws_wafv2_web_acl" "web_acl" {
  name  = "aws_study_web_acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "aws_study_web_acl"
  }
}

# WAF ログ設定
resource "aws_wafv2_web_acl_logging_configuration" "cloudwatch_logging" {
  resource_arn = aws_wafv2_web_acl.web_acl.arn

  log_destination_configs = [
    aws_cloudwatch_log_group.waf.arn
  ]

  depends_on = [
    aws_wafv2_web_acl.web_acl,
    aws_cloudwatch_log_group.waf,
    aws_iam_role.waf_logging_role,
    aws_iam_role_policy.waf_logging_policy_doc
  ]

  # ログフィルター例
  logging_filter {
    default_behavior = "DROP"

    filter {
      requirement = "MEETS_ANY"
      behavior    = "KEEP"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      condition {
        action_condition {
          action = "COUNT"
        }
      }
    }
  }

  # ヘッダーのマスク例
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}
