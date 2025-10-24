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
  default = "ghcr.io/rb-aces-cs/cpp-dev:latest"
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
  name  = "coder-${data.coder_workspace.me.name}"
  image = var.image
  memory = var.memory_mb * 1024 * 1024
  mounts {
    target = "/home/coder/project"
    type   = "volume"
    source = "coder-${data.coder_workspace.me.id}-home"
  }
  entrypoint = ["/bin/sh", "-lc"]
  command    = [coder_agent.dev.init_script]
  restart = "unless-stopped"
}

resource "coder_agent" "dev" {
  os   = "linux"
  arch = "amd64"

  # Runs after the agent connects
  startup_script = <<-EOT
    set -eux

    # Seed a starter project if empty
    if [ ! -f ~/project/main.cpp ]; then
      cat > ~/project/main.cpp <<'CPP'
#include <bits/stdc++.h>
using namespace std;
int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout << "Hello, C++ from Coder!\\n";
    return 0;
}
CPP
      printf "cmake_minimum_required(VERSION 3.10)\\nproject(HelloCpp LANGUAGES CXX)\\nset(CMAKE_CXX_STANDARD 20)\\nadd_executable(app main.cpp)\\n" > ~/project/CMakeLists.txt
    fi

    # Start VS Code (code-server) bound to localhost so Coder can proxy it
    pkill -f code-server || true
    nohup code-server --host 127.0.0.1 --port 13337 --auth none ~/project \
      >/tmp/code.log 2>&1 &
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
