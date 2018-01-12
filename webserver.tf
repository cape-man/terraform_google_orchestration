resource "google_compute_instance_template" "webserver" {
  name="standard-webserver"
  machine_type="n1-standard-1"
  metadata_startup_script="apt-get update && apt-get install -y nginx"

  network_interface {
    network="default"
  }

 disk {
    source_image="debian-cloud/debian-8"
    auto_delete=true
    boot=true
 }
}




resource "google_compute_instance_group_manager" "webserver" {
  name="my-webserver"
  instance_template="${google_compute_instance_template.webserver.self_link}"
  base_instance_name="webserver"
  zone="us-west1-a"
  target_size=3

  named_port {
    name="httpd"
    port=80
  }
}

module "gcp-lb-http" {
  source="GoogleCloudPlatform/lb-http/google"
  name="webserver"
  target_tags=["http"]
  backends={
  "0" = [ {group="${google_compute_instance_group_manager.webserver.instance_group}"}]
  }

  backend_params=[
    "/,http,80,10"
  ]
}

resource "google_compute_health_check" "default" {
  name = "internal-service-health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "80"
  }
}


resource "google_compute_global_address" "default" {
  name = "global-appserver-ip"
}


resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}