package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

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
	vmExternalIP := terraform.Output(t, terraformOptions, "vm_external_ip")

	// Check the VM exists in GCP
	computeClient := gcp.NewComputeClient(t)
	instance := gcp.GetInstance(t, computeClient, "my-gcp-project", "us-central1-a", vmName)

	assert.Equal(t, vmName, instance.Name)
	assert.NotNil(t, instance)

	// Verify if IAP is enabled (no external IP)
	if terraformOptions.Vars["enable_iap"].(bool) {
		assert.Empty(t, vmExternalIP)
	} else {
		assert.NotEmpty(t, vmExternalIP)
	}

	// Verify Shielded VM and Confidential VM configurations
	assert.True(t, instance.ShieldedInstanceConfig.EnableSecureBoot)
	assert.True(t, instance.ShieldedInstanceConfig.EnableVtpm)
	assert.True(t, instance.ShieldedInstanceConfig.EnableIntegrityMonitoring)
	assert.True(t, instance.ConfidentialInstanceConfig.EnableConfidentialCompute)
}
