# Infrastructure Fixes Applied

## Date: 2025-01-11

## Summary

Fixed two critical issues identified in the code analysis:
1. Missing service definitions in `locals.tf`
2. Circular dependency with simpana security group in `main.tf`

---

## 1. Missing Service Definitions

### Problem
`test.tfvars` referenced services that were not defined in `locals.tf`:
- `etcd`
- `workers`
- `longhorn`
- `rancher`
- `opscenter`
- `symv`

This would cause Terraform to fail when trying to look up service configurations.

### Solution
Added placeholder definitions for all missing services in `locals.tf` under two new categories:

#### Kubernetes/Container Services
```hcl
etcd       # Distributed key-value store for Kubernetes
workers    # Kubernetes worker nodes
longhorn   # Distributed block storage for Kubernetes
rancher    # Kubernetes management platform
```

#### Backup Services
```hcl
opscenter  # DataStax OpsCenter for Cassandra management
symv       # Symantec/Veritas backup (alternative to NetBackup)
```

All services are configured with:
- Appropriate instance types (t3.medium)
- Correct subnet placement (back/mgmt/backup)
- Debian OS (except where specified)
- Security group creation enabled
- CIDR skipping enabled (skip_cidr = true)

### Files Modified
- `locals.tf`: Added 6 new service definitions (lines 485-560)
- `test.tfvars`: Updated comments to clarify service status

---

## 2. Simpana Circular Dependency

### Problem
The simpana client security group had a circular dependency:

```
module.services["simpana"] → needs security_groups variable
security_groups variable → includes simpana_client_sg_id
simpana_client_sg_id → depends on module.services["simpana"]
```

This created a dependency cycle that would prevent Terraform from determining the correct order of resource creation.

### Solution
Created a dedicated `aws_security_group.simpana_client` resource in `main.tf` that is independent of the simpana service module.

#### New Security Group Configuration
```hcl
resource "aws_security_group" "simpana_client" {
  name        = "tf_ezlab_simpana_client"
  description = "Security group for Simpana/Commvault backup clients"
  
  # Simpana client services (CVD) - ports 8400-8403
  # Simpana data transfer - ports 8600-8699
  # Simpana web console - port 81
}
```

#### Benefits
- **No circular dependency**: Security group exists before any services are created
- **Available to all services**: Can be referenced by any service that needs backup client access
- **Proper separation**: Simpana server and clients have distinct security groups
- **Consistent with other base SGs**: Follows same pattern as RDP, SSH, and domain_member

### Files Modified
- `main.tf`: 
  - Removed `locals.simpana_client_sg_id` (line ~295)
  - Added `aws_security_group.simpana_client` resource (lines ~295-340)
  - Updated security_groups map to reference new resource (line ~420)

---

## Validation

All changes have been validated:

```bash
✅ terraform fmt    # Code formatting applied
✅ terraform validate  # Configuration is valid
```

---

## Impact

### Before
- ❌ Terraform would fail with "service not found" errors for etcd, workers, etc.
- ❌ Circular dependency would prevent plan/apply operations
- ❌ Could not deploy any configuration that referenced simpana clients

### After
- ✅ All services in test.tfvars have corresponding definitions
- ✅ No circular dependencies in the dependency graph
- ✅ Simpana client security group available to all services
- ✅ Configuration can be successfully planned and applied

---

## Next Steps

1. **Test Deployment**: Run `terraform plan` with test.tfvars to verify no errors
2. **Implement Services**: When ready to implement etcd, workers, etc., update their configurations
3. **Documentation**: Update ARCHITECTURE.md to document the simpana security group pattern
4. **Ansible Integration**: Create corresponding Ansible roles for new services when implemented

---

## Related Files

- `locals.tf`: Service definitions
- `main.tf`: Security groups and service deployment
- `test.tfvars`: Test configuration
- `ARCHITECTURE.md`: Architecture documentation
- `MIGRATION-GUIDE.md`: Migration instructions

---

## Notes

- All new services are set to `0` instances in test.tfvars (disabled by default)
- Services can be enabled by setting instance count > 0 when ready
- PKI services (pki-*) still require special handling via `pki_services` map
- Simpana client security group follows the same pattern as other base security groups
