 We need to run ansible from the packer ansible-local provisioner:
```hcl
  provisioner "ansible-local" {
    playbook_file   = "./ansible/build_azure_agent_ami.yml"
    playbook_dir   = "./ansible/"
    staging_directory = "/ansible"
    extra_arguments = ["-vvv", "--extra-vars", "\"foo=bar\""]
  }
```

and from the command line in the packer build instance:

```shell
ansible-playbook /ansible/build_azure_agent_ami.yml
```

and have it be exactly the same so we cna use the packer temporary instance as a ast-interatin dev environment and be confident that a the  automation will work the same when invoked from packer

ansible uses /usr/bin/python by default and I tried to switch to /usr/bin/python3 and it  lost some dependencies it needs.  I **could** track those down, but I don't think I cna change the packer ansible-local provisioner behavior to use find the ansible instalaled in the python3 site.  I suspect it just shells the command 'ansible' and thaat's only in the path if I install it in the system default python2 site




