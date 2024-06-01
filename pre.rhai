// we can see existing variables.
// note that template and Rhai variables are separate!
let crate_name = variable::get("project-name");
let user = crate_name;
user.replace("_", "");
user.replace("-", "");
user.to_lower();

fn get_port() {
  let ports = variable::prompt("What port number should the server use?", "8765");
  ports.trim();
  let port = 0;
  for ch in ports {
    let n = switch ch {
      '0' => 0,
      '1' => 1,
      '2' => 2,
      '3' => 3,
      '4' => 4,
      '5' => 5,
      '6' => 6,
      '7' => 7,
      '8' => 8,
      '9' => 9,
      _ => abort(`Unexpected port, must be a number found '${ch}' in '${ports}'`),
    };
    port = port * 10;
    port += n;
  }
  
  if port > 65535 {
    abort(`Unexpected port, must be smaller than 65535: ${port}`)
  }
  
  if port <= 1023 {
    if variable::prompt(
      "port numbers below 1024 are often reserved are you sure?", 
      "n", 
      ["y", "n"]
    ) != "y" {
      abort("abandonded job")
    }
  }
  return ports
}

variable::set("port", get_port());

let lan_url = variable::prompt("What hostname would you like for your url?", user);

variable::set("lan_url", lan_url);


let unit_file = `[Unit]
Description=${crate_name}
ConditionPathExists=/usr/bin/${crate_name}
After=network.target
 
[Service]
Type=simple
User=${user}
Group=${user}
LimitNOFILE=1024

Restart=on-failure
RestartSec=10

WorkingDirectory=/usr/share/${crate_name}/
ExecStart=/usr/bin/${crate_name}

# make sure log directory exists and owned by syslog
PermissionsStartOnly=true
ExecStartPre=/bin/mkdir -p /var/log/${crate_name}
ExecStartPre=/bin/chown syslog:adm /var/log/${crate_name}
ExecStartPre=/bin/chmod 755 /var/log/${crate_name}
SyslogIdentifier=${crate_name}
 
[Install]
WantedBy=multi-user.target
`;
file::write(`./${crate_name}.service`, unit_file);

let bash = `#! /bin/bash

cargo build --release \
  && sudo cp ./target/release/${crate_name} /usr/bin \
  && sudo cp ./${crate_name}.service /lib/systemd/system/ \
  && sudo useradd -s /sbin/nologin -M ${user} \
  && sudo systemctl enable ${crate_name} \
  && sudo systemctl start ${crate_name} \
  && sudo cat ./${lan_url}.toml >> /usr/usr/share/home-services/home-service.toml \
  && cat ./${lan_url}.conf > ~/nginx/${lan_url}.conf \
  && sudo service nginx restart \
  && sudo echo "$(hostname -I | cut -d' '  -f 1) ${lan_url}.lan" >> /etc/hosts \
  && sudo service dnsmasq restart

`;
file::write("./install.sh", bash);

let nginx = `
server {
    listen 80;
    server_name ${lan_url}.lan;
        location / {
                proxy_pass http://0.0.0.0:${port}$uri$is_args$args;
        }
}
`;
file::write(`${lan_url}.conf`, nginx);

let desc = variable::prompt("Project description?", crate_name);

let toml = `[[service]]
name = "${crate_name}"
desc = "${desc}"
url = "http://${lan_url}.lan"
`;
file::write(`${lan_url}.toml`, toml);

file::write("README.md", `# ${to_title_case(crate_name)}

${desc}

`);