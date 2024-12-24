package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCEInstance(t *testing.T) {
	t.Parallel()

	// Define Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/simple", // Path to example
		Vars: map[string]interface{}{
			"instance_name": "test-instance",
			"machine_type":  "e2-micro",
			"zone":          "us-central1-a",
			"image":         "debian-cloud/debian-11",
		},
	}

	// Ensure resources are destroyed at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`
	terraform.InitAndApply(t, terraformOptions)

	// Get output values
	vmName := terraform.Output(t, terraformOptions, "vm_name")
	vmIP := terraform.Output(t, terraformOptions, "vm_internal_ip")

	// Verify VM exists in GCP
	computeClient := gcp.NewComputeClient(t)
	instance := gcp.GetInstance(t, computeClient, "my-gcp-project", "us-central1-a", vmName)

	assert.Equal(t, vmName, instance.Name)
	assert.NotNil(t, vmIP)
	assert.NotEmpty(t, instance.NetworkInterfaces)
}
func TestGCEInstanceWithAdvancedFeatures(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/advanced",
		Vars: map[string]interface{}{
			"instance_name":                   "test-advanced-instance",
			"enable_iap":                      true,
			"enable_confidential_vm":          true,
			"enable_shielded_secure_boot":     true,
			"enable_shielded_vtpm":            true,
			"enable_shielded_integrity_monitoring": true,
			"sole_tenancy_node_groups":        []string{"my-node-group"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	// Apply Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs
	vmName := terraform.Output(t, terraformOptions, "vm_name")
	vmInternalIP := terraform.Output(t, terraformOptions, "vm_internal_ip")

	// Check the VM exists in GCP
	computeClient := gcp.NewComputeClient(t)
	instance := gcp.GetInstance(t, computeClient, "my-gcp-project", "us-central1-a", vmName)

	assert.Equal(t, vmName, instance.Name)
	assert.NotNil(t, instance)
	assert.NotEmpty(t, vmInternalIP)

	// Verify Shielded VM and Confidential VM configurations
	assert.True(t, instance.ShieldedInstanceConfig.EnableSecureBoot)
	assert.True(t, instance.ShieldedInstanceConfig.EnableVtpm)
	assert.True(t, instance.ShieldedInstanceConfig.EnableIntegrityMonitoring)
	assert.True(t, instance.ConfidentialInstanceConfig.EnableConfidentialCompute)
}

func TestConfidentialVMValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/advanced",
		Vars: map[string]interface{}{
			"instance_name":          "test-confidential-vm",
			"enable_confidential_vm": true,
			"machine_type":           "n1-standard-1", // Invalid machine type
		},
	}

	// Run Terraform plan and expect it to fail due to validation error
	_, err := terraform.PlanE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "Confidential VMs are only supported with machine types starting with 'n2d', 'n2', or 'e2'.")

	// Change to a valid machine type
	terraformOptions.Vars["machine_type"] = "n2-standard-4"
	terraform.InitAndApply(t, terraformOptions)

	// Cleanup
	defer terraform.Destroy(t, terraformOptions)

	// Verify the instance was created successfully
	vmName := terraform.Output(t, terraformOptions, "vm_name")
	assert.Equal(t, "test-confidential-vm", vmName)
}

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

func TestGCEInstanceWithSoleTenancy(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/advanced",
		Vars: map[string]interface{}{
			"instance_name":                   "test-advanced-instance",
			"sole_tenancy_node_groups":        []string{"my-node-group"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	// Apply Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs
	vmName := terraform.Output(t, terraformOptions, "vm_name")
	vmInternalIP := terraform.Output(t, terraformOptions, "vm_internal_ip")

	// Check the VM exists in GCP
	computeClient := gcp.NewComputeClient(t)
	instance := gcp.GetInstance(t, computeClient, "my-gcp-project", "us-central1-a", vmName)

	assert.Equal(t, vmName, instance.Name)
	assert.NotNil(t, instance)
	assert.NotEmpty(t, vmInternalIP)

	// Verify Shielded VM and Confidential VM configurations
	assert.Contains(t, instance.Scheduling.NodeAffinities, gcp.NodeAffinity{
	    Key:      "compute.googleapis.com/node-group-name",
	    Operator: "IN",
	    Values:   []string{"my-node-group"},
	})
}

