variable "kind_cluster_name" {
  type = string
  description = "Kind cluster name"
  default = "scoolee-local"
}

variable "kind_node_image" {
  type = string
  description = "Kind node image"
  default = "kindest/node:v1.31.1"
}

variable "kind_cluster_config_path" {
  type        = string
  description = "The location where this cluster's kubeconfig will be saved to"
  default     = "~/.kube/config"
}
