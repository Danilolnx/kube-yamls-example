---
- name: Instalar repositorio Epel
  yum:
    name: epel-release
    state: present

- name: Instalar Multipath
  yum:
    name: device-mapper-multipath
    state: present

- name: Desinstalar pacotes de docker antigos
  yum:
    name:
      - docker
      - docker-client
      - docker-client-latest
      - docker-common
      - docker-latest
      - docker-latest-logrotate
      - docker-logrotate
      - docker-engine  
    state: absent

- name: Criar arquivo mpath.conf
  shell: mpathconf --enable --with_multipathd y

- name: Iniciar e habilitar servico Multipath
  systemd:
    name: multipathd.service
    state: started
    enabled: yes

- name: Instalar pacote parted
  package:
    name: parted
    state: present

- name: Criar uma partição a partir de um disco apresentado
  parted:
    device: /dev/sdb
    number: 1
    flags: [ lvm ]
    state: present

- name: Criar Volume Group vg_dados
  lvg:
    vg: vg_dados
    pvs: /dev/sdb1
    pesize: 8

- name: Criar Logical Volume para vg_dados
  lvol:
    vg: vg_dados
    lv: lv_docker
    size: 100%FREE

- name: Formatar o volume com a opcao ftype=1
  filesystem:
    fstype: xfs
    dev: /dev/mapper/vg_dados-lv_docker
    opts: -n ftype=1

- name: Criar diretorio /var/lib/docker se não existir
  file:
    path: /var/lib/docker
    state: directory
    mode: '0755'

- name: Montar diretorio /var/lib/docker e adiciona-lo ao fstab
  mount:
    path: /var/lib/docker
    src: /dev/mapper/vg_dados-lv_docker
    fstype: xfs
    opts: defaults
    state: mounted

- name: Instalar dependencias
  yum:
    name:
      - python-devel
      - libffi-devel
      - openssl-devel
      - gcc
      - glibc-devel
      - make
      - python-pip
      - yum-utils
      - device-mapper-persistent-data
      - lvm2
    state: present

- name: Criar repositorio docker-ce
  copy:
    src: /etc/ansible/roles/aeb/templates/docker-ce.repo
    dest: /etc/yum.repos.d
    owner: root
    group: root
    mode: 0644
    state: present

- name: Instalar docker-ce e compose
  yum:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-compose
    state: present

- name: Iniciar serviço do Docker
  systemd:
    name: docker.service
    state: started
    enabled: yes

- name: Testar funcionamento docker
  shell: docker run hello-world
  register: result_docker

- name:
  debug:
    var: result_docker.stdout_lines
