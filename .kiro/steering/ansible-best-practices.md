## Ansible Best Practices

### Project Structure

**Standard Directory Layout**

```
production                # inventory file for production
staging                   # inventory file for staging

group_vars/
   group1.yml            # variables for specific groups
   group2.yml
host_vars/
   hostname1.yml         # variables for specific hosts
   hostname2.yml

library/                 # custom modules (optional)
module_utils/            # custom module utilities (optional)
filter_plugins/          # custom filter plugins (optional)

site.yml                 # main playbook
webservers.yml          # playbook for webserver tier
dbservers.yml           # playbook for dbserver tier

roles/
    common/
        tasks/
            main.yml
        handlers/
            main.yml
        templates/
            ntp.conf.j2
        files/
            bar.txt
        vars/
            main.yml
        defaults/
            main.yml
        meta/
            main.yml
```

### Role Structure

**Standard Role Layout**

```
roles/
    role_name/
        tasks/           # Main task list
            main.yml
        handlers/        # Handlers triggered by tasks
            main.yml
        templates/       # Jinja2 templates (*.j2)
            config.j2
        files/           # Static files for copy/script
            script.sh
        vars/            # Role variables (higher priority)
            main.yml
        defaults/        # Default variables (lower priority)
            main.yml
        meta/            # Role dependencies and metadata
            main.yml
        library/         # Custom modules (optional)
        module_utils/    # Custom module utilities (optional)
```

### Playbook Best Practices

**Basic Playbook Structure**

```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  gather_facts: yes
  
  vars:
    http_port: 80
    max_clients: 200
  
  tasks:
    - name: Install Apache
      ansible.builtin.package:
        name: httpd
        state: present
      notify: Restart Apache
  
  handlers:
    - name: Restart Apache
      ansible.builtin.service:
        name: httpd
        state: restarted
```

**Using Roles in Playbooks**

```yaml
---
- name: Configure infrastructure
  hosts: all
  roles:
    - common
    - { role: apache, http_port: 8080 }
    - role: postgres
      vars:
        db_name: myapp
```

**Dynamic Role Inclusion**

```yaml
---
- name: Configure servers
  hosts: webservers
  tasks:
    - name: Print message before role
      ansible.builtin.debug:
        msg: "Starting configuration"
    
    - name: Include role dynamically
      ansible.builtin.include_role:
        name: webserver
      vars:
        app_port: 5000
    
    - name: Print message after role
      ansible.builtin.debug:
        msg: "Configuration complete"
```

**Static Role Import**

```yaml
---
- name: Configure servers
  hosts: webservers
  tasks:
    - name: Import role statically
      ansible.builtin.import_role:
        name: webserver
      vars:
        app_port: 5000
```

### Variables and Facts

**Variable Precedence (lowest to highest)**

1. Role defaults (`defaults/main.yml`)
2. Inventory file or script group vars
3. Inventory `group_vars/all`
4. Playbook `group_vars/all`
5. Inventory `group_vars/*`
6. Playbook `group_vars/*`
7. Inventory file or script host vars
8. Inventory `host_vars/*`
9. Playbook `host_vars/*`
10. Host facts / cached set_facts
11. Play vars
12. Play vars_prompt
13. Play vars_files
14. Role vars (`vars/main.yml`)
15. Block vars
16. Task vars
17. Extra vars (`-e` on command line)

**Using Variables**

```yaml
---
- name: Use variables
  hosts: all
  vars:
    app_name: myapp
    app_version: "1.0"
  
  tasks:
    - name: Install application
      ansible.builtin.package:
        name: "{{ app_name }}"
        state: present
    
    - name: Register command output
      ansible.builtin.command: /usr/bin/get-version
      register: version_output
    
    - name: Use registered variable
      ansible.builtin.debug:
        msg: "Version is {{ version_output.stdout }}"
```

**Loading Variables Dynamically**

```yaml
---
- name: Load variables based on OS
  hosts: all
  tasks:
    - name: Include OS-specific variables
      ansible.builtin.include_vars: "{{ ansible_facts.distribution }}.yml"
    
    - name: Use loaded variables
      ansible.builtin.debug:
        msg: "Package name: {{ package_name }}"
```

### Handlers

**Defining and Using Handlers**

```yaml
---
- name: Configure web server
  hosts: webservers
  tasks:
    - name: Update configuration
      ansible.builtin.copy:
        src: httpd.conf
        dest: /etc/httpd/conf/httpd.conf
      notify:
        - Restart Apache
        - Clear cache
  
  handlers:
    - name: Restart Apache
      ansible.builtin.service:
        name: httpd
        state: restarted
    
    - name: Clear cache
      ansible.builtin.command: /usr/local/bin/clear-cache
```

**Using Variables in Handlers**

```yaml
tasks:
  - name: Load OS-specific variables
    ansible.builtin.include_vars: "{{ ansible_facts.distribution }}.yml"

handlers:
  - name: Restart web service
    ansible.builtin.service:
      name: "{{ web_service_name | default('httpd') }}"
      state: restarted
```

### Conditionals and Loops

**Conditional Execution**

```yaml
---
- name: Conditional tasks
  hosts: all
  tasks:
    - name: Install Apache on RedHat
      ansible.builtin.yum:
        name: httpd
        state: present
      when: ansible_facts['os_family'] == "RedHat"
    
    - name: Install Apache on Debian
      ansible.builtin.apt:
        name: apache2
        state: present
      when: ansible_facts['os_family'] == "Debian"
    
    - name: Run command and check result
      ansible.builtin.command: /usr/bin/check-status
      register: status_result
      ignore_errors: yes
    
    - name: Handle failure
      ansible.builtin.debug:
        msg: "Status check failed"
      when: status_result.rc != 0
```

**Loops**

```yaml
---
- name: Loop examples
  hosts: all
  tasks:
    - name: Install multiple packages
      ansible.builtin.package:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - php
        - mysql
    
    - name: Create users with properties
      ansible.builtin.user:
        name: "{{ item.name }}"
        state: present
        groups: "{{ item.groups }}"
      loop:
        - { name: 'alice', groups: 'wheel' }
        - { name: 'bob', groups: 'users' }
    
    - name: Safe loop with undefined variables
      ansible.builtin.command: echo {{ item }}
      loop: "{{ mylist | default([]) }}"
      when: item > 5
```

### Blocks and Error Handling

**Using Blocks**

```yaml
---
- name: Block example
  hosts: webservers
  tasks:
    - name: Configuration block
      block:
        - name: Update config
          ansible.builtin.copy:
            src: app.conf
            dest: /etc/app/app.conf
          notify: Restart app
        
        - name: Verify config
          ansible.builtin.command: /usr/bin/validate-config
      
      rescue:
        - name: Handle configuration error
          ansible.builtin.debug:
            msg: "Configuration failed, rolling back"
        
        - name: Restore backup
          ansible.builtin.copy:
            src: /etc/app/app.conf.bak
            dest: /etc/app/app.conf
      
      always:
        - name: Log attempt
          ansible.builtin.lineinfile:
            path: /var/log/config-changes.log
            line: "Config update attempted at {{ ansible_date_time.iso8601 }}"
```

### Windows-Specific Best Practices

**Windows Connection Configuration**

```yaml
---
- name: Configure Windows servers
  hosts: windows
  gather_facts: yes
  
  vars:
    ansible_connection: winrm
    ansible_winrm_transport: ntlm
    ansible_winrm_server_cert_validation: ignore
  
  tasks:
    - name: Install Windows feature
      ansible.windows.win_feature:
        name: Web-Server
        state: present
      register: feature_result
    
    - name: Reboot if required
      ansible.windows.win_reboot:
      when: feature_result.reboot_required
```

**PowerShell Execution**

```yaml
---
- name: Execute PowerShell
  hosts: windows
  tasks:
    - name: Run PowerShell script
      ansible.windows.win_powershell:
        script: |
          Get-Process | Where-Object {$_.Name -eq 'notepad'}
          $PSVersionTable.PSVersion
      register: ps_output
    
    - name: Display output
      ansible.builtin.debug:
        var: ps_output.output
    
    - name: Run script from file
      ansible.windows.win_shell: |
        powershell.exe -File C:\scripts\configure.ps1
      args:
        chdir: C:\scripts
```

**Windows File Operations**

```yaml
---
- name: Windows file operations
  hosts: windows
  tasks:
    - name: Copy file to Windows
      ansible.windows.win_copy:
        src: files/config.ini
        dest: C:\ProgramData\MyApp\config.ini
    
    - name: Manage registry
      ansible.windows.win_regedit:
        path: HKLM\SOFTWARE\MyApp
        name: Version
        data: "1.0.0"
        type: string
        state: present
    
    - name: Download file
      ansible.windows.win_get_url:
        url: https://example.com/installer.msi
        dest: C:\Temp\installer.msi
        checksum: sha256:abc123...
```

**Active Directory Operations**

```yaml
---
- name: Manage Active Directory
  hosts: domain_controllers
  tasks:
    # Use microsoft.ad collection (preferred)
    - name: Create domain
      microsoft.ad.domain:
        dns_domain_name: example.com
        safe_mode_password: "{{ admin_password }}"
        state: present
    
    - name: Promote domain controller
      microsoft.ad.domain_controller:
        dns_domain_name: example.com
        domain_admin_user: "administrator@example.com"
        domain_admin_password: "{{ admin_password }}"
        safe_mode_password: "{{ safe_mode_password }}"
        state: present
```

### Inventory Management

**Dynamic AWS EC2 Inventory**

```yaml
# inventory/aws_ec2.yaml
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
  - us-west-2
filters:
  tag:Environment: production
keyed_groups:
  - key: tags.Type
    prefix: tag_type
  - key: tags.System
    prefix: tag_system
hostnames:
  - dns-name
  - private-ip-address
compose:
  ansible_host: private_ip_address
```

**Static Inventory with Groups**

```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com
db2.example.com

[production:children]
webservers
dbservers

[production:vars]
ansible_user=admin
environment=production
```

### Performance Optimization

**Ansible Configuration**

```ini
[defaults]
forks = 100
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/facts_cache
fact_caching_timeout = 7200
host_key_checking = False
pipelining = True
retry_files_enabled = False

[ssh_connection]
pipelining = True
control_path = ~/.ssh/cp/ssh-%%r@%%h:%%p
```

**Parallel Execution**

```bash
# Use ansible-parallel for faster execution
ansible-parallel playbooks/system/*.yml
ansible-parallel playbooks/apps/*.yml

# Standard ansible with increased forks
ansible-playbook -f 50 site.yml
```

**Fact Gathering Optimization**

```yaml
---
- name: Optimize fact gathering
  hosts: all
  gather_facts: no  # Disable if not needed
  
  tasks:
    - name: Gather minimal facts
      ansible.builtin.setup:
        gather_subset:
          - '!all'
          - '!min'
          - network
```

### Security Best Practices

**Using Ansible Vault**

```bash
# Create encrypted file
ansible-vault create group_vars/production/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/production/vault.yml

# Run playbook with vault
ansible-playbook site.yml --ask-vault-pass

# Use vault password file
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

**Vault Variables in Playbooks**

```yaml
---
- name: Use vault variables
  hosts: all
  vars_files:
    - group_vars/production/vault.yml
  
  tasks:
    - name: Use encrypted password
      ansible.builtin.user:
        name: admin
        password: "{{ vault_admin_password | password_hash('sha512') }}"
```

**Privilege Escalation**

```yaml
---
- name: Tasks requiring privilege escalation
  hosts: all
  become: yes
  become_method: sudo
  become_user: root
  
  tasks:
    - name: Install package
      ansible.builtin.package:
        name: httpd
        state: present
```

### Testing and Validation

**Syntax Check**

```bash
# Check playbook syntax
ansible-playbook --syntax-check site.yml

# Check with specific inventory
ansible-playbook -i production --syntax-check site.yml
```

**Dry Run**

```bash
# Check mode (dry run)
ansible-playbook --check site.yml

# Show differences
ansible-playbook --check --diff site.yml
```

**Linting**

```bash
# Use ansible-lint
ansible-lint playbooks/site.yml

# Lint all playbooks
ansible-lint playbooks/*.yml
```

### Debugging

**Debug Tasks**

```yaml
---
- name: Debug examples
  hosts: all
  tasks:
    - name: Display variable
      ansible.builtin.debug:
        var: ansible_facts.distribution
    
    - name: Display message
      ansible.builtin.debug:
        msg: "Host {{ inventory_hostname }} is {{ ansible_facts.os_family }}"
    
    - name: Display complex data
      ansible.builtin.debug:
        var: hostvars[inventory_hostname]
        verbosity: 2
```

**Verbose Output**

```bash
# Increase verbosity
ansible-playbook -v site.yml   # verbose
ansible-playbook -vv site.yml  # more verbose
ansible-playbook -vvv site.yml # debug
ansible-playbook -vvvv site.yml # connection debug
```

**Step Through Playbook**

```bash
# Execute playbook step by step
ansible-playbook --step site.yml

# Start at specific task
ansible-playbook --start-at-task="Install packages" site.yml
```

### Collections

**Using Collections**

```yaml
---
- name: Use collections
  hosts: all
  collections:
    - community.general
    - ansible.windows
  
  tasks:
    - name: Use module from collection
      community.general.timezone:
        name: America/New_York
```

**Installing Collections**

```bash
# Install from requirements file
ansible-galaxy collection install -r requirements.yml

# Install specific collection
ansible-galaxy collection install community.general

# List installed collections
ansible-galaxy collection list
```

### Common Patterns

**Idempotency**

```yaml
---
- name: Ensure idempotent operations
  hosts: all
  tasks:
    - name: Ensure package is present
      ansible.builtin.package:
        name: httpd
        state: present  # Not 'latest' unless needed
    
    - name: Ensure service is running
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: yes
```

**Tags for Selective Execution**

```yaml
---
- name: Tagged tasks
  hosts: all
  tasks:
    - name: Install packages
      ansible.builtin.package:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - php
      tags:
        - packages
        - install
    
    - name: Configure service
      ansible.builtin.template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      tags:
        - config
```

```bash
# Run only specific tags
ansible-playbook site.yml --tags "packages"

# Skip specific tags
ansible-playbook site.yml --skip-tags "config"
```
