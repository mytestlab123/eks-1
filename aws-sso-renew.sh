#!/bin/bash

# Check if AWS credentials are valid
if ! aws sts get-caller-identity &>/dev/null; then
    echo "AWS SSO session expired. Renewing..."
    aws sso login
else
    echo "AWS SSO session is still valid"
fi
