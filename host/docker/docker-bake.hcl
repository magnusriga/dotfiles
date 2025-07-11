target "nfront" {
  context = "../.."
  dockerfile = "./host/docker/Dockerfile"
  tags = ["127.0.0.1:5000/nfront-dev"]
  args = {
    DISTRO = try(env("DISTRO"), "arch")
    TARGETARCH = try(env("TARGETARCH"), "amd64")
    ARCH_IMAGE_AMD64 = try(env("ARCH_IMAGE_AMD64"), "archlinux:latest")
    ARCH_IMAGE_ARM64 = try(env("ARCH_IMAGE_ARM64"), "menci/archlinuxarm")
    UBUNTU_IMAGE = try(env("UBUNTU_IMAGE"), "ubuntu:24.04")
  }
  allow = ["security.insecure"]
}
