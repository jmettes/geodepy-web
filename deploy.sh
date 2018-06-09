#!/usr/bin/env bash

set -e

script="$(basename "${BASH_SOURCE[0]}")"
unset dryRun

function printUsage {
    cat << EOF
Usage: $script OPTIONS
where OPTIONS are
   -d, --dry-run
        run terraform plan, but not apply
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run )
            dryRun=true
            shift
            ;;
        * )
            echo "Unknown option: $1"
            printUsage
            exit 1
        ;;
    esac
done


export TF_VAR_region=ap-southeast-2
export TF_VAR_application=geodepy-web

export TF_VAR_tf_state_bucket=geodepy-web-terraform-state
export TF_VAR_tf_state_table=geodepy-web-terraform-state

pushd terraform
terraform init \
    -backend-config "bucket=${TF_VAR_tf_state_bucket}" \
    -backend-config "dynamodb_table=${TF_VAR_state_table}" \
    -backend-config "region=${TF_VAR_region}" \
    -backend-config "key=${TF_VAR_application}/terraform.tfstate}" \
    -reconfigure
terraform get
terraform plan

if [ -z "$dryRun" ]; then
    terraform apply -auto-approve

    endpoint=$(terraform output endpoint)
    echo "var endpoint = \"${endpoint}\";" > ../frontend/endpoint.js

    source_bucket=$(terraform output source_bucket)
    pushd ../frontend
    aws s3 sync . s3://${source_bucket}
    popd

fi

popd
