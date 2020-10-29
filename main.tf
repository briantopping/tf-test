terraform {
  required_providers {
    kubernetes-alpha = {
      version = "0.2.1"
    }
  }
}

provider "kubernetes-alpha" {
  version = "~> 0.2.1"
  config_path = "~/.kube/config" // path to kubeconfig
//  config_context = var.config_context
}

provider "kubernetes" {
  config_path = "~/.kube/config" // path to kubeconfig
//  config_context = var.config_context
}

//resource "kubernetes_namespace" "vm_ns" {
//  provider = kubernetes
//  metadata {
//    name = var.vm_namespace
//  }
//}

resource "kubernetes_manifest" "virtualmachine-dv" {
  provider = kubernetes-alpha
//  depends_on = [kubernetes_namespace.vm_ns]
  manifest = {
    "apiVersion" = "kubevirt.io/v1alpha3"
    "kind" = "VirtualMachine"
    "metadata" = {
      "name" = var.image_name
      "namespace" = var.vm_namespace
    }
    "spec" = {
      "dataVolumeTemplates" = [
        {
          "metadata" = {
            "creationTimestamp" = null
            "name" = "dataVolume-dv"
          }
          "spec" = {
            "pvc" = {
              "accessModes" = [
                "ReadWriteOnce",
              ]
              "resources" = {
                "requests" = {
                  "storage" = var.image_size
                }
              }
            }
            "source" = {
              "http" = {
                "url" = var.image_url
              }
            }
          }
        },
      ]
      "running" = true
      "template" = {
        "metadata" = {
          "creationTimestamp" = null
          "labels" = {
            "kubevirt.io/vm" = "testvm1"
          }
        }
        "spec" = {
          "domain" = {
            "cpu" = {
              "cores" = 4
            }
            "devices" = {
              "disks" = [
                {
                  "disk" = {
                    "bus" = "virtio"
                  }
                  "name" = "test-datavolume"
                },
                {
                  "cdrom" = {
                    "bus" = "sata"
                  }
                  "name" = "cloudinitvolume"
                },
              ]
              "interfaces" = [
                {
                  "bridge" = {}
                  "name" = "default_net"
                },
              ]
            }
            "machine" = {
              "type" = "q35"
            }
            "resources" = {
              "requests" = {
                "memory" = "24Gi"
              }
            }
          }
          "networks" = [
            {
              "multus" = {
                "default" = true
                "networkName" = "testvm/host-conf"
              }
              "name" = "default_net"
            },
          ]
          "volumes" = [
            {
              "dataVolume" = {
                "name" = "dataVolume-dv"
              }
              "name" = var.image_name
            },
            {
              "cloudInitNoCloud" = {
                "userData" = "#cloud-config\nssh_pwauth: true\nhostname: testvm1\nusers:\n  - default\nchpasswd:\n  list: |\n    centos:centos\n"
              }
              "name" = "cloudinitvolume"
            },
          ]
        }
      }
    }
  }
}


