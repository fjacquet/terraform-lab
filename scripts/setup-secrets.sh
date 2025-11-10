#!/bin/bash
#
# Setup AWS Secrets Manager secrets for terraform-lab infrastructure
# This script creates the required secrets with secure random passwords
#
# Usage: ./scripts/setup-secrets.sh [--region REGION] [--dry-run]
#

set -euo pipefail

# Default values
REGION="${AWS_REGION:-eu-west-1}"
DRY_RUN=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --region)
            REGION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--region REGION] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --region REGION   AWS region (default: eu-west-1 or \$AWS_REGION)"
            echo "  --dry-run         Show what would be created without creating"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        log_error "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials are not configured or invalid."
        log_error "Run 'aws configure' or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Generate secure random password
generate_password() {
    local length=${1:-32}
    # Generate password with letters, numbers, and special characters
    # Exclude characters that might cause issues: " ' ` \ /
    openssl rand -base64 48 | tr -d "\"'\`\\/" | head -c "$length"
}

# Create or update secret
create_secret() {
    local secret_name=$1
    local secret_description=$2
    local secret_value=$3
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create secret: $secret_name"
        return 0
    fi
    
    log_info "Creating secret: $secret_name"
    
    # Check if secret already exists
    if aws secretsmanager describe-secret \
        --secret-id "$secret_name" \
        --region "$REGION" &> /dev/null; then
        
        log_warn "Secret $secret_name already exists. Updating value..."
        
        if aws secretsmanager update-secret \
            --secret-id "$secret_name" \
            --secret-string "$secret_value" \
            --region "$REGION" &> /dev/null; then
            log_info "Successfully updated secret: $secret_name"
        else
            log_error "Failed to update secret: $secret_name"
            return 1
        fi
    else
        # Create new secret
        if aws secretsmanager create-secret \
            --name "$secret_name" \
            --description "$secret_description" \
            --secret-string "$secret_value" \
            --region "$REGION" &> /dev/null; then
            log_info "Successfully created secret: $secret_name"
        else
            log_error "Failed to create secret: $secret_name"
            return 1
        fi
    fi
    
    return 0
}

# Main execution
main() {
    log_info "Starting AWS Secrets Manager setup for terraform-lab"
    log_info "Region: $REGION"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "DRY-RUN MODE: No changes will be made"
    fi
    
    check_prerequisites
    
    # Define secrets to create
    declare -A secrets=(
        ["ez-lab.xyz/ansible/localadmin"]="Password for local administrator account used by Ansible"
        ["ez-lab.xyz/ad/joinuser"]="Password for Active Directory domain join account"
        ["ez-lab.xyz/ad/admin"]="Password for Active Directory administrator account"
    )
    
    local failed=0
    local created=0
    
    # Create each secret
    for secret_name in "${!secrets[@]}"; do
        secret_description="${secrets[$secret_name]}"
        secret_value=$(generate_password 32)
        
        if create_secret "$secret_name" "$secret_description" "$secret_value"; then
            ((created++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    log_info "Summary:"
    log_info "  Secrets processed: ${#secrets[@]}"
    log_info "  Successfully created/updated: $created"
    
    if [[ $failed -gt 0 ]]; then
        log_error "  Failed: $failed"
        exit 1
    fi
    
    echo ""
    log_info "Setup complete!"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        log_warn "IMPORTANT: Secrets have been created with random passwords."
        log_warn "To retrieve a secret value, use:"
        log_warn "  aws secretsmanager get-secret-value --secret-id SECRET_NAME --region $REGION --query SecretString --output text"
        echo ""
        log_warn "Store these passwords securely in your password manager!"
    fi
}

# Run main function
main "$@"
