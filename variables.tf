variable "resource_group_location" {
  default     = "westus2"
  description = "WestUS2"
}

variable "resource_group_name_prefix" {
  default     = "TMEauto"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}