# EC2 CPU 使用率 0.1% 超でアラーム
resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name          = "EC2HighCPUAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 0.1
  alarm_description   = "EC2 CPU 使用率が 0.1% を超えた場合に通知"
  dimensions = {
    InstanceId = var.ec2_id
  }
alarm_actions = [aws_sns_topic.cpu_alarm_topic.arn]
}

# SNS トピック作成
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "EC2HighCPUAlarmTopic"
}

# SNS サブスクリプション（あなたのメールアドレスに直接送信）
resource "aws_sns_topic_subscription" "cpu_alarm_sub" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = "29oishi4@gmail.com"  # ←ここに自分のメール
}