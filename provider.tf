#Google
provider "google" {
  credentials = "${file("google_account.json")}"
  project="home-depot-191805"
  region="us-west1"
}
