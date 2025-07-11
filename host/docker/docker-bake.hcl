variable "DISTRO" {
  default = "arch"
}

variable "TARGETARCH" {
  default = "amd64"
}

variable "ARCH_IMAGE_AMD64" {
  default = "archlinux:latest"
}

variable "ARCH_IMAGE_ARM64" {
  default = "menci/archlinuxarm"
}

variable "UBUNTU_IMAGE" {
  default = "ubuntu:24.04"
}

target "nfront" {
  context = "../.."
  dockerfile = "host/docker/Dockerfile"
  tags = ["127.0.0.1:5000/nfront-dev"]
  args = {
    DISTRO = "${DISTRO}"
    TARGETARCH = "${TARGETARCH}"
    ARCH_IMAGE_AMD64 = "${ARCH_IMAGE_AMD64}"
    ARCH_IMAGE_ARM64 = "${ARCH_IMAGE_ARM64}"
    UBUNTU_IMAGE = "${UBUNTU_IMAGE}"
  }
  allow = ["security.insecure"]
}