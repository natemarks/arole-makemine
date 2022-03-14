import pytest

""" use this exaple test later when we can actuslly run the service

"""


@pytest.mark.skip
def test_td_agent_enabled(host):
    td_agent = host.service("td-agent")
    assert td_agent.is_valid
    assert not td_agent.is_running
    assert not td_agent.is_enabled


@pytest.mark.skip
def test_ulimits(host):
    with host.sudo():
        assert host.check_output("ulimit -n") == "65536"
    with host.sudo("ec2-user"):
        assert host.check_output("ulimit -n") == "65536"


@pytest.mark.parametrize(
    "command,exit_code",
    [
        ("jq --version", 0),
        ("wget --version", 0),
        ("curl --version", 0),
        ("python3 --version", 0),
        ("ansible --version", 0),
    ],
)
def test_run_binaries(host, command, exit_code):
    """Try to run  each of binaries we need in the image

    test the exit code for each
    """
    cmd = host.run(command)
    assert cmd.rc == exit_code


def test_hostfile(host):
    """Try to run  each of binaries we need in the image

    test the exit code for each
    """
    hostfile = host.file("/etc/hosts")
    assert hostfile.contains(
        "10.153.16.15  teamcity-server.imprivata.com teamcity-server"
    )
    assert hostfile.contains("10.153.17.61  stash.imprivata.com stash")
    assert hostfile.user == "root"
    assert hostfile.group == "root"
    assert hostfile.mode == 0o644


def test_limits_conf(host):
    """Try to run  each of binaries we need in the image

    test the exit code for each
    """
    hostfile = host.file("/etc/security/limits.conf")
    assert hostfile.contains("root soft nofile 65536")
    assert hostfile.contains("root hard nofile 65536")
    assert hostfile.contains("* soft nofile 65536")
    assert hostfile.contains("* hard nofile 65536")
    assert hostfile.user == "root"
    assert hostfile.group == "root"
    assert hostfile.mode == 0o644
