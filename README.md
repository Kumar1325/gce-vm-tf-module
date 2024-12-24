# GCE VM Terraform Module

This Terraform module creates Google Compute Engine (GCE) Virtual Machines (VMs) on Google Cloud Platform (GCP) with advanced configurations, including support for:

- IAP Tunneling
- Sole Tenancy
- Confidential VMs
- Shielded VMs
- Mandatory encryption with Customer-Managed Encryption Keys (CMEK)

---

## Features

- Flexible configuration for VM instance creation
- Support for advanced security and isolation features
- Mandatory CMEK encryption for VM disks
- Variable validations to enforce valid configurations
- Ready-to-use examples for basic and advanced setups

---

## Inputs

| **Variable**                       | **Description**                                               | **Type**          | **Default**                | **Required** |
|------------------------------------|---------------------------------------------------------------|-------------------|----------------------------|--------------|
| `project_id`                       | The GCP project ID                                            | `string`         | n/a                        | Yes          |
| `credentials_file`                 | Path to the GCP credentials file                             | `string`         | n/a                        | Yes          |
| `region`                           | The region where the VM will be deployed                     | `string`         | n/a                        | Yes          |
| `zone`                             | The zone where the VM will be deployed                       | `string`         | n/a                        | Yes          |
| `instance_name`                    | The name of the VM instance                                  | `string`         | n/a                        | Yes          |
| `machine_type`                     | The machine type of the VM                                    | `string`         | n/a                        | Yes          |
| `image`                            | The image to use for the VM                                   | `string`         | n/a                        | Yes          |
| `network`                          | The network to attach to the VM                              | `string`         | `default`                  | No           |
| `subnetwork`                       | The subnetwork to attach to the VM                           | `string`         | `default`                  | No           |
| `enable_iap`                       | Enable IAP tunneling for secure access                       | `bool`           | `false`                    | No           |
| `enable_confidential_vm`           | Enable Confidential VM                                        | `bool`           | `false`                    | No           |
| `enable_shielded_secure_boot`      | Enable secure boot for Shielded VM                           | `bool`           | `true`                     | No           |
| `enable_shielded_vtpm`             | Enable vTPM for Shielded VM                                   | `bool`           | `true`                     | No           |
| `enable_shielded_integrity_monitoring` | Enable integrity monitoring for Shielded VM                  | `bool`           | `true`                     | No           |
| `sole_tenancy_node_groups`         | List of node group names for sole tenancy                    | `list(string)`   | `[]`                       | No           |
| `tags`                             | List of network tags for the VM                              | `list(string)`   | `[]`                       | No           |
| `metadata`                         | Metadata key-value pairs to add to the instance              | `map(string)`    | `{}`                       | No           |
| `cmek_key_name`                    | The name of the Customer-Managed Encryption Key (CMEK)       | `string`         | n/a                        | Yes          |

### Variable Validation for Region
The allowed GCP regions for GCE VM are:
- US-CENTRAL1
- US-EAST4
- US-WEST3

Attempting to use other regions will result in a validation error during `terraform plan` or `terraform apply`.

### Variable Validation for Confidential VMs

If `enable_confidential_vm` is set to `true`, the `machine_type` must start with one of the following:
- `n2d`
- `n2`
- `e2`

Attempting to use other machine types will result in a validation error during `terraform plan` or `terraform apply`.

---

## Outputs

| **Output**        | **Description**                                   |
|--------------------|---------------------------------------------------|
| `vm_name`          | The name of the created VM instance               |
| `vm_self_link`     | The self-link of the created VM instance          |
| `vm_external_ip`   | The external IP address of the VM (if applicable) |

---

## Example Usage

### Basic Example

```hcl
module "gce_vm" {
  source = "../gce-vm-module"

  project_id       = "my-gcp-project"
  credentials_file = "path/to/credentials.json"
  region           = "us-central1"
  zone             = "us-central1-a"

  instance_name    = "basic-vm"
  machine_type     = "n1-standard-1"
  image            = "debian-cloud/debian-11"
  cmek_key_name    = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
}
```

### Advanced Example with IAP, Confidential VM, and Shielded VM

```hcl
module "gce_vm" {
  source = "../gce-vm-module"

  project_id       = "my-gcp-project"
  credentials_file = "path/to/credentials.json"
  region           = "us-central1"
  zone             = "us-central1-a"

  instance_name    = "advanced-vm"
  machine_type     = "n2-standard-4"
  image            = "debian-cloud/debian-11"
  cmek_key_name    = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"

  enable_iap                      = true
  enable_confidential_vm          = true
  enable_shielded_secure_boot     = true
  enable_shielded_vtpm            = true
  enable_shielded_integrity_monitoring = true

  tags = ["web", "iap-enabled"]

  metadata = {
    startup-script = "echo Advanced GCP VM setup!"
  }
}
```

---

## Terratest Example

The module includes a `gce_test.go` Terratest test file in the `tests/` folder. Below is a simplified example of how it validates the advanced configurations:

```go
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCEInstanceWithCMEK(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/advanced",
		Vars: map[string]interface{}{
			"instance_name":          "test-advanced-vm",
			"enable_confidential_vm": true,
			"machine_type":           "n2-standard-4",
			"cmek_key_name":          "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key",
		},
	}

	// Ensure resources are cleaned up after test
	defer terraform.Destroy(t, terraformOptions)

	// Run Terraform init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	vmName := terraform.Output(t, terraformOptions, "vm_name")
	assert.Equal(t, "test-advanced-vm", vmName)
}
```

---

## Testing Instructions

1. **Run Terraform Plan**:
   ```bash
   terraform plan
   ```

2. **Apply Configuration**:
   ```bash
   terraform apply
   ```

3. **Run Tests**:
   ```bash
   go test -v tests/gce_test.go
   ```

---

## Best Practices

- Use separate environments (e.g., staging, production) for testing.
- Validate variable inputs for correctness.
- Leverage Terratest to automate infrastructure validation.
- Enable GCP monitoring and logging for Shielded and Confidential VMs.
- Ensure CMEK keys are properly managed and have sufficient IAM permissions.

---

## References

- [Google Cloud Platform: Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Terraform: Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

