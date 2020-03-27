provider "packet" {
  auth_token = var.auth_token
}

# Provisioning Packet servers
resource "packet_device" "servers" {
  count = var.amount
  hostname = format(
    "%s%s-ESXi-node-%d",
    var.hostname_prefix,
    var.facility,
    count.index,
  )
  plan             = var.plan
  facilities       = [var.facility]
  operating_system = "vmware_esxi_6_5"
  billing_cycle    = "hourly"
  project_id       = var.project_id
  tags             = [var.esxi_update_filename]
}

# Waiting for the post provision reboot process to complete
resource "null_resource" "rebooting" {
  depends_on = [packet_device.servers]

  provisioner "local-exec" {
    command = "sleep 250"
  }
}

# Generating update script file
data "template_file" "upgrade-script" {
  count    = var.amount
  template = file("${path.module}/templates/update_esxi.sh.tpl")
  vars = {
    esxi_update_filename = var.esxi_update_filename
  }
}

# Running the update script file in each server.
# If you make changes to the shell script, you need to update the sed command line number to get rid of te { at the end of the file which gets created by Terraform for some reason.
resource "null_resource" "upgrade-nodes" {
  depends_on = [null_resource.rebooting]

  count = var.amount

  connection {
    user        = "root"
    private_key = file(var.private_key_filename)
    host        = element(packet_device.servers.*.access_public_ipv4, count.index)
  }

  provisioner "file" {
    content     = "${element(data.template_file.upgrade-script.*.rendered, count.index)}}"
    destination = "/tmp/update_esxi.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i '27d' /tmp/update_esxi.sh",
      "echo 'Running update script on remote host.'",
      "chmod +x /tmp/update_esxi.sh",
      "/tmp/update_esxi.sh",
    ]
  }
}
