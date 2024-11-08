terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.6.0"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "default" {
  name = var.kind_cluster_name
  wait_for_ready = true
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  node_image = var.kind_node_image

  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]
      extra_port_mappings {
        container_port = 80
        host_port = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port = 443
      }
    }

    node {
      role = "worker"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kind_cluster_config_path)
  }
}

resource "helm_release" "argocd" {
  name = "argocd"
  depends_on = [kind_cluster.default]

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  namespace = "argocd"
  version = "7.6.12"
  create_namespace = true
  values = [
    "${file("argocd/argocd/values.yaml")}"
  ]
}

resource "helm_release" "argocd-apps" {
  name  = "argocd-apps"
  depends_on = [helm_release.argocd]

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argocd-apps"
  namespace = "argocd"
  version = "1.6.2"
  values = [
    file("argocd/applications.yaml")
  ]
}
