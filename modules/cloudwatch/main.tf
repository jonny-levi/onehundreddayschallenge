resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "ec2-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # CPU Utilization Widget
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for id in var.ec2_instance_id : ["AWS/EC2", "CPUUtilization", "InstanceId", id]
          ]
          period = 60
          stat   = "Average"
          region = "us-east-1"
          title  = "CPU Utilization"
        }
      },

      # Disk Read/Write Widget
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "DiskReadBytes", "InstanceId", var.ec2_instance_id],
            ["AWS/EC2", "DiskWriteBytes", "InstanceId", var.ec2_instance_id]
          ]
          period = 60
          stat   = "Average"
          region = "us-east-1"
          title  = "Disk IO (Read/Write Bytes)"
        }
      },

      # Network In Widget
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            for id in var.ec2_instance_id : ["AWS/EC2", "NetworkIn", "InstanceId", id]
          ]
          period = 60
          stat   = "Average"
          region = "us-east-1"
          title  = "Network In"
        }
      },

      # Network Out Widget
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            for id in var.ec2_instance_id : ["AWS/EC2", "NetworkOut", "InstanceId", id]
          ]
          period = 60
          stat   = "Average"
          region = "us-east-1"
          title  = "Network Out"
        }
      }
    ]
  })
}


resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  tags                      = var.default_tags
}

resource "aws_cloudwatch_log_group" "cwlg" {
  name = "cwlg"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}

resource "aws_cloudwatch_log_stream" "foo" {
  name           = "SampleLogStream1234"
  log_group_name = aws_cloudwatch_log_group.cwlg.name
}
