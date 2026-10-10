#!/bin/bash
set -e

echo "🌩️  Deploying Cloudy Agent to AWS..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "❌ AWS CLI could not be found. Please install it first: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Get AWS Account ID to create a unique bucket
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    REGION="us-east-1"
    echo "⚠️  No default region set. Defaulting to $REGION"
fi

BUCKET_NAME="cloudy-agent-deploy-${ACCOUNT_ID}-${REGION}"

echo "📦 Ensuring S3 bucket $BUCKET_NAME exists for deployment..."
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket --bucket "$BUCKET_NAME"
    else
        aws s3api create-bucket --bucket "$BUCKET_NAME" --create-bucket-configuration LocationConstraint="$REGION"
    fi
fi

echo "🏗️  Packaging SAM template..."
aws cloudformation package \
    --template-file template.yaml \
    --s3-bucket "$BUCKET_NAME" \
    --output-template-file packaged.yaml

echo "🚀 Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file packaged.yaml \
    --stack-name cloudy-agent-stack \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND

echo "✅ Deployment complete!"
echo "Fetching API Gateway URL..."
API_URL=$(aws cloudformation describe-stacks --stack-name cloudy-agent-stack --query "Stacks[0].Outputs[?OutputKey=='CloudyApiUrl'].OutputValue" --output text)

echo ""
echo "==========================================================="
echo "🎉 Cloudy is now live at:"
echo "$API_URL"
echo "==========================================================="
echo ""
echo "👉 NEXT STEPS:"
echo "1. Copy the URL above."
echo "2. Open frontend/index.html and replace 'YOUR_API_GATEWAY_URL_HERE' with the URL."
echo "3. Open frontend/index.html in your browser and chat with Cloudy!"
