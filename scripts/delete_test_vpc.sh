#!/usr/bin/env bash
aws cloudformation delete-stack --stack-name "test-arole-makemine"

echo "Waiting for delete-stack to finish"
aws cloudformation wait stack-delete-complete --stack-name "test-arole-makemine"

echo "Stack deleted: test-arole-makemine"