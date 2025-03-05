module "network" {
  source = "./modules/network"
}

module "compute1" {
  source     = "./modules/compute"
  network_id = module.network.network_id
  subnet_id  = module.network.subnet_id
  name       = "mavoyan1"
  zones = ["us-east1-d", "us-east1-b"]
  startup_script = "sudo apt update\nsudo apt install -y apache2\nsudo systemctl start apache2\nsudo systemctl enable apache2\nsudo apt install php libapache2-mod-php -y\nsudo rm /var/www/html/index.html\nsudo touch /var/www/html/index.php\necho \"<?php echo 'Hostname: ' . gethostname(); ?>\" | sudo tee /var/www/html/index.php\nsudo systemctl restart apache2"
  depends_on = [module.network]
}


module "compute2" {
  source     = "./modules/compute"
  name       = "mavoyan2"
  zones = ["us-east1-c", "us-east1-d"]
  startup_script = "sudo apt update\nsudo apt install -y apache2\nsudo systemctl start apache2\nsudo systemctl enable apache2\nsudo apt install php libapache2-mod-php -y\nsudo rm /var/www/html/index.html\nsudo touch /var/www/html/index.php\necho \"<?php echo 'Script2 - Hostname: ' . gethostname(); ?>\" | sudo tee /var/www/html/index.php\nsudo systemctl restart apache2"
  network_id = module.network.network_id
  subnet_id  = module.network.subnet_id
  depends_on = [module.network]
}


resource "google_storage_bucket" "default" {
  name     = "mavoyan-terraform-remote-backend"
  location = "US"

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

