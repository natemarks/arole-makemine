import pytest

""" use this exaple test later when we can actuslly run the service

"""


@pytest.mark.parametrize(
    "command,exit_code",
    [
        ("wget --version", 0),
        ("curl --version", 0),
        ("python3 --version", 0),
        ("ansible --version", 0),
        ("makemine https://gist.githubusercontent.com/natemarks/3620f565dc4e775143647d62c151658e/raw/54559a95b3ba58c0cc2ca8889ea12c72adbf7adb/makemine.json", 0),
    ],
)
def test_run_binaries(host, command, exit_code):
    """Try to run  each of binaries we need in the image

    test the exit code for each
    """
    cmd = host.run(command)
    assert cmd.rc == exit_code


def test_makemine(host):
    """Try to run  each of binaries we need in the image

    test the exit code for each
    """
    makemine = host.file("/usr/local/bin/makemine")
    assert makemine.exists
    assert makemine.mode == 0o755

    # check the json output file
    makemine_json= host.file("/etc/makemine/makemine.json")
    makemine_json.contains("\"fullName\": \"Nate Marks\"")
    makemine_json.contains("\"localUser\": \"nmarks\"")
    makemine_json.contains("\"email\": \"npmarks@gmail.com\"")

    # check the yaml output file
    makemine_yaml= host.file("/etc/makemine/makemine.yaml")
    makemine_yaml.contains("full_name: Nate Marks")
    makemine_yaml.contains("local_user: nmarks")
    makemine_yaml.contains("email: npmarks@gmail.com")

    makemine_src= host.file("/etc/makemine/makemine.sh")
    makemine_json.contains("export FULLNAME=\"Nate Marks\"")
    makemine_json.contains("export LOCALUSER=\"nmarks\"")
    makemine_json.contains("export EMAIL=\"npmarks@gmail.com\"")

