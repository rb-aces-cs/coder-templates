terraform {
  required_providers {
    coder = { source = "coder/coder", version = ">= 0.15.0" }
    docker = { source = "kreuzwerker/docker", version = ">= 3.0.2" }
  }
}

provider "coder" {}
provider "docker" { host = "unix:///var/run/docker.sock" }

data "coder_workspace" "me" {}

variable "image" {
  type    = string
  default = "ghcr.io/computercodeblue/cpp-dev:latest"
}

variable "cpu_limit" {
  type    = number
  default = 1
}

variable "memory_mb" {
  type    = number
  default = 2048
}

resource "docker_container" "dev" {
  name  = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  image = var.image
  memory = var.memory_mb * 1024 * 1024
  mounts {
    target = "/home/coder/project"
    type   = "volume"
    source = "coder-${data.coder_workspace.me.id}-home"
  }
  command = ["bash", "-lc", "sleep infinity"]
  restart = "unless-stopped"
}

resource "coder_agent" "dev" {
  os   = "linux"
  arch = "amd64"
  startup_script = <<-EOT
    set -eux
    if [ ! -f ~/project/main.cpp ]; then
      cp -r /usr/local/share/template/* ~/project/
    fi
  EOT
}

resource "coder_app" "vscode" {
  agent_id     = coder_agent.dev.id
  slug         = "vscode"
  display_name = "VS Code"
  icon         = "vscode"
  url          = "http://localhost:13337"
  share        = "owner"
}

resource "coder_app_exec" "launch" {
  app_id = coder_app.vscode.id
  command = [
    "bash", "-lc",
    "pkill -f code-server || true; nohup code-server --host 127.0.0.1 --port 13337 --auth none ~/project >/tmp/code.log 2>&1 &"
  ]
  run_on_start = true
}
