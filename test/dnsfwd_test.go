package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAzureLoadBalancer(t *testing.T) {
	t.Parallel()

	// subscriptionID is overridden by the environment variable "ARM_SUBSCRIPTION_ID"

	// Configure Terraform setting up a path to Terraform code.
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../dnsfwd",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	lbName := terraform.Output(t, terraformOptions, "lb_name")
	subscriptionId := terraform.Output(t, terraformOptions, "subscription_id")
	//dnsServer := terraform.Output(t, terraformOptions, "lb_public_ip_address")

	t.Run("LoadBalancer", func(t *testing.T) {
		// Check if Load Balancer exists.
		actualLbExists := azure.LoadBalancerExists(t, lbName, resourceGroupName, subscriptionId)

		// r := &net.Resolver{
		// 	PreferGo: true,
		// 	Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
		// 		d := net.Dialer{
		// 			Timeout: time.Millisecond * time.Duration(10000),
		// 		}
		// 		return d.DialContext(ctx, network, dnsServer+":53")
		// 	},
		// }
		// ip, _ := r.LookupHost(context.Background(), "test.test.com")

		// print(ip[0])
		// assert.Equal(t, ip[0], "192.1.2.3")
		assert.True(t, actualLbExists)
	})
}
