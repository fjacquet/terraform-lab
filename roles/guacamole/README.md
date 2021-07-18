# Ansible role guacamole_exporter

![Molecule Test](https://github.com/tschoonj/ansible-role-guacamole-exporter/workflows/Molecule%20Test/badge.svg?branch=master&event=push)
[![Ansible Role](https://img.shields.io/badge/ansible%20role-tschoonj.ansible_role_guacamole_exporter-blue.svg)](https://galaxy.ansible.com/tschoonj/ansible_role_guacamole_exporter/)
[![GitHub tag](https://img.shields.io/github/tag/tschoonj/ansible-role-guacamole-exporter.svg)](https://github.com/tschoonj/ansible-role-guacamole-exporter/tags)


## ansible-guacamole-exporter

This role installs and configures [guacamole_exporter](https://github.com/tschoonj/guacamole_exporter) to collect usage metrics from a [Guacamole](https://guacamole.apache.org) clientless remote desktop gateway, and can be scraped by a [Prometheus](https://prometheus.io) instance.

## Requirements

* Ansible >= 2.10 (Earlier versions may work, but I haven't tested)

## Role Variables

The user is _required_ to define the following variables.

| Name                 | Description                        |
|----------------------|------------------------------------|
|`guacamole_exporter_endpoint`   | The address of the Guacamole instance |
|`guacamole_exporter_username`   | A user with sufficient privileges to access the REST API |
|`guacamole_exporter_password`   | The corresponding password |
|`guacamole_exporter_datasource` | The datasource to use in the REST API calls. This may differ from the authentication datasource, and will typically be an SQL implementation |


All variables in [default/main.yml](defaults/main.yml) can be overridden

| Name           | Default Value | Description                        |
| -------------- | ------------- | -----------------------------------|
|`guacamole_exporter_version`| 0.1.1 | the version to install, _latest_ is also accepted|
|`guacamole_exporter_binary_local_dir`| ""| To allow to use local packages from controller machine instead of github packages|
|`guacamole_exporter_web_listen_address`| "0.0.0.0:9623"| guacamole_exporter listen addrress|
|`guacamole_exporter_web_telemetry_path`| "/metrics" | path that will be used to export the metrics |

## Dependencies

Nil

## Usage

### From galaxy

```python
ansible-galaxy install tschoonj.ansible_role_guacamole_exporter
```

### git submodule

To add as submodule to your project instead of pulling from galaxy

```bash
git submodule add -b main https://github.com/tschoonj/ansible-role-guacamole-exporter.git roles/guacamole-exporter
```

To get role updates

```bash
git submodule update --remote
```

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: tschoonj.ansible_role_guacamole_exporter
      vars:
        guacamole_endpoint: guacamole.example.com
        guacamole_username: admin
        guacamole_password: admin
        guacamole_datasource: mysql
```

## Contributing

* Fork the project on GitHub
* Clone the project
* Add changes (and tests)
* Commit and push
* Create a pull request

## Acknowledgements

This role is inspired by [ansible-node-exporter](https://github.com/cloudalchemy/ansible-node-exporter) and [ansible-prometheus-msteams](https://github.com/slashpai/ansible-prometheus-msteams).

## License

[MIT](LICENSE)
