"""Write log entries to cloudwatch logs."""

import logging
import os

import environs
import structlog
import watchtower

env = environs.Env()
log = structlog.stdlib.get_logger()


def main(event, context):
    # Debug logging
    log_level = env.log_level("log_level", logging.INFO)
    structlog.configure(wrapper_class=structlog.make_filtering_bound_logger(log_level))

    cwLogger = logging.getLogger("cloudwatch")
    cwLogger.setLevel(logging.INFO)
    cloudwatch_log_group = env.str("log_group")
    cloudwatch_log_stream = os.getenv("log_stream")
    cloudwatch_handler = watchtower.CloudWatchLogHandler(
        log_group=cloudwatch_log_group, stream_name=cloudwatch_log_stream
    )
    cwLogger.addHandler(cloudwatch_handler)

    try:
        # FIXME: What if there are more than one record?
        message_source = event["Records"][0]["EventSource"]
    except KeyError:
        log.warn("Unexpected event format", lambda_event=event)
        return

    if message_source == "aws:sns":
        body = event["Records"][0]["Sns"]["Message"]
        cwLogger.info(body)
        cloudwatch_handler.flush()
    else:
        log.warn("Message source is not aws:sns", event=event)

    # FIXME: What should we return?
    return
