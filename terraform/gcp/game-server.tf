terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.23.0"
    }
  }
}

provider "google" {
  credentials = file("credential.json")
  project     = "game-server-352313"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_network" "game_server_network" {
  name                    = "game-server-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "game_server_firewall" {
  name    = "game-server-firewall"
  network = google_compute_network.game_server_network.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "game_server" {
  name                      = "game-server"
  machine_type              = "e2-standard-2"
  allow_stopping_for_update = true
  labels                    = { purpose = "game-server-prod" }

  scheduling {
    automatic_restart = false
  }

  boot_disk {
    initialize_params {
      size  = 30
      image = "windows-cloud/windows-2022"
    }
  }

  network_interface {
    network = google_compute_network.game_server_network.self_link
    access_config {}
  }
}
