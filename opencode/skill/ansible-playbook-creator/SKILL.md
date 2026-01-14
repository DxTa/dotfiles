# Ansible Playbook Creator

Ansible playbook creator for configuration management and server automation.

## When to Use

Use this skill when:
- Automating server configuration
- Managing application deployments
- Setting up multi-server environments
- Implementing configuration management
- Automating system administration tasks
- Rolling out updates across infrastructure
- Managing configurations at scale

## Key Concepts

### Ansible Architecture
- **Control Node**: Where Ansible runs
- **Managed Nodes**: Servers being configured
- **Inventory**: List of managed nodes
- **Playbooks**: Automation scripts
- **Modules**: Reusable units of work

### Core Principles
- **Idempotency**: Safe to run multiple times
- **Agentless**: Uses SSH, no agents needed
- **Push-based**: Control node pushes configurations
- **Declarative**: Define desired state

## Basic Playbook Structure

```yaml
# site.yml
---
- name: Configure web servers
  hosts: webservers
  become: yes

  vars:
    app_user: webapp
    app_port: 8080

  tasks:
    - name: Install dependencies
      apt:
        name:
          - nginx
          - python3-pip
        state: present
        update_cache: yes

    - name: Create application user
      user:
        name: "{{ app_user }}"
        shell: /bin/bash
        home: "/home/{{ app_user }}"

    - name: Deploy application
      copy:
        src: /app/dist/
        dest: /var/www/html/
        owner: "{{ app_user }}"
        mode: '0644'

    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes

  handlers:
    - name: Reload nginx
      service:
        name: nginx
        state: reloaded
```

## Inventory Management

### INI Format
```ini
# inventory.ini
[webservers]
web1.example.com ansible_user=ubuntu
web2.example.com ansible_user=ubuntu

[databases]
db1.example.com ansible_user=ubuntu
db2.example.com ansible_user=ubuntu

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### YAML Format
```yaml
# inventory.yml
all:
  vars:
    ansible_python_interpreter: /usr/bin/python3

  hosts:
    web1.example.com:
      ansible_user: ubuntu
    web2.example.com:
      ansible_user: ubuntu

  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:

    databases:
      hosts:
        db1.example.com:
        db2.example.com:
```

### Dynamic Inventory
```yaml
# aws.yml
plugin: aws_ec2
regions:
  - us-east-1
keyed_groups:
  - key: tags.Environment
    prefix: env_
  - key: tags.Role
    prefix: role_
filters:
  instance-state-name: running
```

## Common Tasks

### Package Management
```yaml
- name: Install packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - git
    - python3-pip

- name: Remove packages
  apt:
    name: "{{ item }}"
    state: absent
  loop:
    - apache2
    - old-package
```

### User Management
```yaml
- name: Create user with SSH key
  user:
    name: deploy
    shell: /bin/bash
    groups: sudo
    append: yes
    ssh_key_file: ~/.ssh/id_rsa.pub

- name: Ensure user has authorized_keys
  authorized_key:
    user: deploy
    key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
```

### File Operations
```yaml
- name: Copy configuration file
  copy:
    src: config/nginx.conf
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
    backup: yes
  notify: Reload nginx

- name: Create directory with permissions
  file:
    path: /var/log/app
    state: directory
    owner: app
    group: app
    mode: '0755'

- name: Template configuration
  template:
    src: templates/app.conf.j2
    dest: /etc/app/app.conf
    owner: root
    mode: '0644'
```

### Service Management
```yaml
- name: Ensure service is running
  service:
    name: nginx
    state: started
    enabled: yes

- name: Restart service
  service:
    name: nginx
    state: restarted

- name: Stop service
  service:
    name: apache2
    state: stopped
    enabled: no
```

### Database Setup
```yaml
- name: Install PostgreSQL
  apt:
    name: postgresql
    state: present

- name: Start PostgreSQL
  service:
    name: postgresql
    state: started
    enabled: yes

- name: Create database
  postgresql_db:
    name: appdb
    owner: appuser

- name: Create database user
  postgresql_user:
    db: appdb
    name: appuser
    password: "{{ db_password }}"
    priv: "ALL"
```

## Advanced Features

### Handlers
```yaml
handlers:
  - name: Reload nginx
    service:
      name: nginx
      state: reloaded

  - name: Restart application
    systemd:
      name: app
      state: restarted

tasks:
  - name: Update configuration
    template:
      src: app.conf.j2
      dest: /etc/app/app.conf
    notify: Restart application
```

### Conditionals
```yaml
- name: Install package (Debian)
  apt:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"

- name: Install package (RedHat)
  yum:
    name: nginx
    state: present
  when: ansible_os_family == "RedHat"

- name: Run task if variable is defined
  debug:
    msg: "Variable is set"
  when: my_var is defined
```

### Loops
```yaml
- name: Create multiple users
  user:
    name: "{{ item.name }}"
    groups: "{{ item.groups }}"
  loop:
    - { name: alice, groups: developers }
    - { name: bob, groups: developers }
    - { name: charlie, groups: admins }

- name: Install packages from list
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - python3-pip
    - git
```

### Variables
```yaml
# vars.yml
app_name: myapp
app_version: "1.0.0"
app_port: 8080

env_vars:
  NODE_ENV: production
  PORT: "{{ app_port }}"
  DATABASE_URL: postgresql://localhost/app

# Use in playbook
- name: Set environment variables
  copy:
    dest: /etc/environment
    content: |
      {% for key, value in env_vars.items() %}
      {{ key }}={{ value }}
      {% endfor %}
```

### Roles
```yaml
# roles/nginx/tasks/main.yml
---
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Configure nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Reload nginx

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes

# roles/nginx/handlers/main.yml
---
- name: Reload nginx
  service:
    name: nginx
    state: reloaded

# Use role in playbook
- name: Configure web server
  hosts: webservers
  roles:
    - nginx
```

## Jinja2 Templates

```jinja2
# templates/nginx.conf.j2
server {
    listen {{ app_port }};
    server_name {{ server_name }};

    location / {
        root {{ app_root }};
        index index.html;
    }

    {% if enable_ssl %}
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/{{ ssl_cert }};
    ssl_certificate_key /etc/ssl/private/{{ ssl_key }};
    {% endif %}
}
```

## Patterns and Practices

### Multi-Stage Deployment
```yaml
- name: Deploy to staging
  hosts: staging
  roles:
    - app-deploy
  tags: staging

- name: Deploy to production
  hosts: production
  roles:
    - app-deploy
  tags: production
```

### Rolling Updates
```yaml
- name: Rolling update
  hosts: webservers
  serial: 1
  become: yes

  tasks:
    - name: Stop service
      service:
        name: app
        state: stopped

    - name: Deploy new version
      copy:
        src: app/
        dest: /opt/app/
      notify: Start service
```

### Vault for Secrets
```bash
# Encrypt variable file
ansible-vault encrypt secrets.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Use with playbook
ansible-playbook site.yml --ask-vault-pass
```

### Error Handling
```yaml
- name: Task with error handling
  block:
    - name: Potentially failing task
      command: /bin/false
  rescue:
    - name: Handle error
      debug:
        msg: "Task failed, but playbook continues"
  always:
    - name: Always run
      debug:
        msg: "This runs regardless of success or failure"
```

## Best Practices

### Playbook Design
- Use roles for organization
- Separate variables from playbooks
- Use handlers for service restarts
- Add descriptive names for tasks
- Use tags for selective execution

### Idempotency
- Always check before changing
- Use appropriate modules
- Test playbooks on staging first
- Use --check mode (dry run)

### Security
- Use SSH keys for authentication
- Encrypt sensitive variables with ansible-vault
- Use least-privilege access
- Rotate credentials regularly
- Review and audit playbooks

## File Patterns

Look for:
- `**/*.yml`
- `**/*.yaml`
- `**/roles/**/*`
- `**/inventory/**/*`
- `**/group_vars/**/*`
- `**/host_vars/**/*`
- `**/playbooks/**/*`

## Keywords

Ansible, configuration management, automation, playbook, inventory, role, deployment, server automation, idempotency, SSH, Jinja2, template, handler, variable, vault
