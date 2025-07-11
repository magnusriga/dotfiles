target "nfront" {
  context = "../.."
  dockerfile = "./host/docker/Dockerfile"
  tags = ["127.0.0.1:5000/nfront-dev"]
  args = {
    DISTRO = "${DISTRO:-arch}"
    TARGETARCH = "${TARGETARCH:-amd64}"
    ARCH_IMAGE_AMD64 = "${ARCH_IMAGE_AMD64:-archlinux:latest}"
    ARCH_IMAGE_ARM64 = "${ARCH_IMAGE_ARM64:-menci/archlinuxarm}"
    UBUNTU_IMAGE = "${UBUNTU_IMAGE:-ubuntu:24.04}"
  }
  allow = ["security.insecure"]
}