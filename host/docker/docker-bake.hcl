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
