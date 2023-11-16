variable "env" {
  type        = string
  description = "Name of the environment."
}

variable "prefix" {
  type        = string
  description = "Naming prefix."
}

variable "enable_azure_external_deploy" {
  type    = bool
  default = false
}

variable "location" {
  type        = string
  description = "Name of the location (eastus,westus,etc.)."
}

variable "default_node_count" {
  type        = string
  default     = "1"
  description = "The number of Kubernetes machines that are running"
}

variable "default_min_count" {
  type    = string
  default = "1"
}

variable "default_max_count" {
  type    = string
  default = "3"
}


variable "default_node_pool_name" {
  type        = string
  default     = "default_agent"
  description = "name of the default node pool"
}

variable "default_node_size" {
  type        = string
  default     = "Standard_D2_v2"
  description = "The size of the virtual machine used for the Kubernetes linux agents in the cluster."
}

variable "k8s_version" {
  type        = string
  description = "Version of kubernetes."
  default     = "1.19.11"
}

variable "linux_admin_username" {
  type        = string
  description = "User name for authentication to the Kubernetes linux agent virtual machines in the cluster."
  default     = "sightmachine"
}

variable "name" {
  type        = string
  description = "The name suffix of the kube cluster."
  default     = ""
}

variable "default_node_disk_size" {
  type        = string
  default     = "30"
  description = "The size of the node os disk."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the cluster is getting created."
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet that the cluster will use."
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network that the subnet will reference"
}

variable "sa_token" {
  type        = string
  description = "the token service account for vault registration"
}

variable "node_pools" {
  type = map(object({
    node_count        = number
    vm_size           = string
    taints            = list(string)
    min_count         = number
    max_pods          = number
    node_disk_size    = number
    max_count         = number
    spot_max_price    = number
    eviction_policy   = string
    node_pool_type    = string
    node_labels       = map(string)
    node_pool_version = string
    max_surge         = string
  }))

  description = "Map of the node pool that will be created"
}

variable "root_domain" {
  default     = "sightmachine.com"
  description = "Root domain used to allow subdomain be created"
}

variable "list_of_roles" {
  type = map(object({
    service_account = list(string)
    namespace       = list(string)
  }))

  default = {
    rawq = {
      service_account = ["rawq-dev", "rawq-prod"]
      namespace       = ["rawq-dev", "rawq-prod"]
    },
    thanos = {
      service_account = ["prometheus-server"]
      namespace       = ["prometheus"]
    },
    grafana = {
      service_account = ["grafana"]
      namespace       = ["grafana"]
    },
    oauth2-proxy = {
      service_account = ["oauth2-proxy"]
      namespace       = ["oauth2-proxy"]
    },
    velero = {
      service_account = ["velero"]
      namespace       = ["velero"]
    },
    statuscake = {
      service_account = ["statuscake"]
      namespace       = ["statuscake"]
    },
    autoscale-pvc = {
      service_account = ["autoscale-pvc"]
      namespace       = ["autoscale-pvc"]
    },
    external-dns = {
      service_account = ["external-dns"]
      namespace       = ["external-dns"]
    }
  }
}

variable "subscription_id" {
  type        = string
  description = "subscription id where the resources will be deployed"
}

variable "enable_voltron_sp" {
  default     = false
  description = "sp that manage voltron subscription access"
}

variable "register_kube_with_vault" {
  default = false
}

variable "enable_velero_storage" {
  default     = true
  description = "It will create storage class where the backup can be stored"
}

variable "tenant_id" {
  default     = "beb1d7f9-8e2e-4dc4-83be-190ebceb70ea"
  description = "tenant id of the azure subscription"
}

variable "enable_velero_sp" {
  default     = true
  description = "used for restrictive env"
}

variable "enable_autoscaler_sp" {
  default     = true
  description = "create autoscaler service principal and it's role mapping"
}

variable "enable_aad" {
  default     = true
  description = "used by aad owner role to assign network permission to kube"
}

variable "enable_loki_storage" {
  default     = true
  description = "Storage used for logs"
}

variable "default_node_pool_version" {}

variable "default_enable_autoscaler" {
  default     = true
  description = "have the option to disable/enable node autoscaler"
}

variable "enable_master_logs" {
  default     = true
  description = "Enable AKS master logs to be injected in analytics logs"
}

variable "list_of_logs_category" {
  type = map(object({
    enabled = bool
  }))

  default = {
    kube-apiserver = {
      enabled = true
    },
    kube-controller-manager = {
      enabled = true
    },
    kube-scheduler = {
      enabled = true
    },
    cloud-controller-manager = {
      enabled = false
    },
    cluster-autoscaler = {
      enabled = false
    },
    kube-audit-admin = {
      enabled = false
    },
    kube-audit = {
      enabled = false
    },
    kube-audit-admin = {
      enabled = false
    },
    csi-azuredisk-controller = {
      enabled = false
    },
    csi-azurefile-controller = {
      enabled = false
    },
    csi-snapshot-controller = {
      enabled = false
    },
    guard = {
      enabled = false
    }
  }
}

variable "master_logs_retention" {
  type        = number
  default     = 5
  description = "days to keep the logs from the master nodes"
}

variable "enable_kube_api_whitelisting" {
  default = false
}

variable "list_of_ips_whitelist" {
  type    = list(string)
  default = ["0.0.0.0/32"]
}

variable "enable_managed_firewall" {
  type    = bool
  default = false
}

variable "sightmachine_io_zone_id" {
  type    = string
  default = "	ZE8O4FSTZAUU7"
}

variable "list_urls" {
  type    = list(string)
  default = []
}

variable "ip_url_whitelist" {
  type    = list(any)
  default = ["*"]
}

variable "default_max_pod" {
  type    = number
  default = 110
}

variable "default_max_surge" {
  type    = string
  default = "33%"
}

variable "node_os_channel_upgrade" {
  default = "Unmanaged"
  type    = string
}

variable "tags" {
  type = map(string)
  default = {
    "owner"  = "sm"
    "Source" = "Managed by Terraform"
  }
}


variable "temporary_name_for_rotation" {
  default = "changeme"
  type    = string
}
