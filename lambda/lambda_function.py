import json
import time
import urllib3
import boto3
from datetime import datetime
import os
from decimal import Decimal

# HTTP pool manager
http = urllib3.PoolManager()

# AWS resources
dynamodb = boto3.resource("dynamodb")
cloudwatch = boto3.client("cloudwatch")

# DynamoDB table name (env var recommended)
TABLE_NAME = os.environ.get("UPTIME_TABLE", "UptimeMonitor")

# List of URLs to monitor from AWS SSM Parameter Store
# Expected: parameter name in env var UPTIME_SSM_PARAM (StringList or comma-separated string)
ssm = boto3.client("ssm")
PARAM_NAME = os.environ.get("UPTIME_SSM_PARAM")
print("PARAM_NAME", PARAM_NAME)

def get_urls():
    URLS = []
    if PARAM_NAME:
        try:
            param = ssm.get_parameter(Name=PARAM_NAME)
            print("param", param)
            raw_value = param["Parameter"]["Value"]
            print("raw_value", raw_value)
            URLS = [u.strip() for u in raw_value.split(",") if u.strip()]
        except Exception as e:
            print(f"Error fetching SSM parameter {PARAM_NAME}: {e}")
    else:
        print(f"No SSM parameter specified")
    return URLS

# Request timeout in seconds
REQUEST_TIMEOUT = float(os.environ.get("REQUEST_TIMEOUT", "5.0"))


def check_url(url):
    start = time.time()
    status = None

    try:
        response = http.request("GET", url, timeout=REQUEST_TIMEOUT)
        latency = round((time.time() - start) * 1000, 2)  # ms
        status = response.status
        is_up = 1 if status == 200 else 0

    except Exception as e:
        latency = None
        is_up = 0

    return {
        "url": url,
        "is_up": is_up,
        "latency": latency,
        "status_code": status,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }


def publish_metrics(url, is_up, latency):
    metric_data = [{
        "MetricName": "availability",
        "Dimensions": [{"Name": "url", "Value": url}],
        "Value": is_up,
        "Unit": "Count"
    }, {
        "MetricName": "latency_ms",
        "Dimensions": [{"Name": "url", "Value": url}],
        "Value": latency if latency is not None else 0,
        "Unit": "Milliseconds"
    }]

    # latency metric - put 0 if latency is None so dimension exists but you can filter it

    try:
        cloudwatch.put_metric_data(Namespace="UptimeMonitor", MetricData=metric_data)
    except Exception as e:
        # CloudWatch failures should not fail the whole function
        print(f"Error publishing metrics: {e}")


def save_to_dynamodb(table_name, item):
    try:
        table = dynamodb.Table(table_name)

        table.put_item(Item=item)
    except Exception as e:
        print(f"Error saving to DynamoDB: {e}")


def lambda_handler(event, context):

    URLS = get_urls()
    if len(URLS) == 0:
        print("No URLs configured")

    results = []
    for url in URLS:
        result = check_url(url)
        results.append(result)

        # Persist to DynamoDB
        latency_value = (
            Decimal(str(result["latency"]))
            if result["latency"] is not None
            else Decimal("-1")
        )

        dynamo_item = {
            "url": result["url"],
            "timestamp": result["timestamp"],
            "is_up": int(result["is_up"]),
            "latency_ms": latency_value,
            "status_code": result.get("status_code")
        }
        save_to_dynamodb(TABLE_NAME, dynamo_item)

        # Publish CloudWatch metrics
        publish_metrics(result["url"], result["is_up"], result["latency"])

    return {
        "statusCode": 200,
        "body": json.dumps({"results": results})
    }
