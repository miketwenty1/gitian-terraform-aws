data "template_file" "shell-script" {
  template = file("${path.module}/cloud-init.sh")

  vars = {
    DOCKER_FINGERPRINT  = var.docker_fingerprint
    VERIFIER_NAME       = var.gpg_signer
    VERSION             = var.bitcoin_version
    MEMORY              = lookup(local.instance_options, replace(var.instance_size,".",""), "instance_size not supported").memory
    CORES               = lookup(local.instance_options, replace(var.instance_size,".",""), "instance_size not supported").cores
  }
}

data "template_cloudinit_config" "cloud-init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}
