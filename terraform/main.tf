# Create a resource group for below resources
resource "azurerm_resource_group" "rgsa" {
  name     = "stream-analytics-rg"
  location = var.location
}

data "azurerm_storage_account" "jobstorage" {
  name                = "iotdevstrgcore"
  resource_group_name = "iot-dev-rg-core"
}

data "azurerm_iothub_shared_access_policy" "iothubinput" {
  name                = "iothubowner"
  resource_group_name = "iot-dev-rg-terraformTesting"
  iothub_name         = "iot-dev-ioth-terraformTestingIoTHub"
}

data "azurerm_cosmosdb_account" "cosdb" {
  name                = "iot-dev-cdb-core"
  resource_group_name = "iot-dev-rg-core"
}

# Define ARM deployment template for the Azure Stream Analytics deployment
resource "azurerm_resource_group_template_deployment" "azure_stream_analytics" {
  depends_on = [azurerm_resource_group.rgsa]
  name                = "azure_stream_analytics"
  resource_group_name = azurerm_resource_group.rgsa.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    ASAApiVersion = { value = "2017-04-01-preview" }

    StreamAnalyticsJobName = { value = "ASACICD" }

    Location = { value = var.location }

    OutputStartMode = { value = "JobStartTime" }

    OutputStartTime = { value = "2019-01-01T00:00:00Z" }

    DataLocale = { value = "en-GB" }

    OutputErrorPolicy : { "value" : "Drop" }

    EventsLateArrivalMaxDelayInSeconds = { value = 5 }

    EventsOutOfOrderMaxDelayInSeconds = { value = 0 }

    EventsOutOfOrderPolicy = { value = "Adjust" }

    StreamingUnits = { value = 1 }

    CompatibilityLevel = { value = "1.2" }

    TagValues = { value = { "ENV" : "Dev", "Created By" : "tasos" } }

    ContentStoragePolicy = { value = "SystemAccount" },

    JobStorageAccountName = { value = "iotstrggithub" }

    JobStorageAccountKey = { value = data.azurerm_storage_account.jobstorage.primary_connection_string },

    JobStorageAuthMode = { value = "ConnectionString" }

    Input_Input_iotHubNamespace = { value = "iot-dev-ioth-terraformTestingIoTHub" }

    Input_Input_consumerGroupName = { value = "$Default" }

    Input_Input_endpoint = { value = "messages/events" }

    Input_Input_sharedAccessPolicyName = { value = "iothubowner" }

    Input_Input_sharedAccessPolicyKey = { value = data.azurerm_iothub_shared_access_policy.iothubinput.primary_key }

    Output_Output_accountId = { value = "iot-dev-cdb-core" }

    Output_Output_accountKey = { value = data.azurerm_cosmosdb_account.cosdb.primary_master_key }

    Output_Output_database = { value = "database1" }

    Output_Output_collectionNamePattern = { value = "terraformtesting" }

    Output_Output_partitionKey = { value = "" }

  })

  template_content = file("${path.module}/build/ASACICD.JobTemplate.json")

}