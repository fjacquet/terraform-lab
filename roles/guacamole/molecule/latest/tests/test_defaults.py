import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_files(host):
    files = [
        "/etc/systemd/system/guacamole_exporter.service",
        "/usr/local/bin/guacamole_exporter",
        "/etc/guacamole_exporter.conf",
    ]
    for file in files:
        f = host.file(file)
        assert f.exists
        assert f.is_file


def test_permissions_didnt_change(host):
    dirs = [
        "/etc",
        "/root",
        "/usr",
        "/var"
    ]
    for file in dirs:
        f = host.file(file)
        assert f.exists
        assert f.is_directory
        assert f.user == "root"
        assert f.group == "root"


def test_user(host):
    assert host.group("guacamole-exp").exists
    assert "guacamole-exp" in host.user("guacamole-exp").groups
    assert host.user("guacamole-exp").shell == "/usr/sbin/nologin"
    assert host.user("guacamole-exp").home == "/"


def test_service(host):
    s = host.service("guacamole_exporter")
#    assert s.is_enabled
    assert s.is_running


def test_socket(host):
    sockets = [
        "tcp://127.0.0.1:9623"
    ]
    for socket in sockets:
        s = host.socket(socket)
        assert s.is_listening
