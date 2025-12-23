# Дипломный практикум в Yandex.Cloud -Мельник С В

* [Цели:](#цели)
* [Этапы выполнения:](#этапы-выполнения)
  * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
  * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
  * [Создание тестового приложения](#создание-тестового-приложения)
  * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
  * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
* [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
* [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---

## Цели

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

## Этапы выполнения

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

* Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/Снимок%20экрана%20от%202025-12-14%2015-41-28.png)

* так как нельзя настроить удаленное хранение состояния конфигурации терраформ в бакете, не создав при этом сам бакет на первом этапе создал сервисный аккаунт, бакет, ключи и сеть, затем перенес стейт в бакет.
* при создании секретных ключей для бакета, для передачи на этап переноса стейта в бакет, в файле output.tf создал шаблон файла provider.tf с секретными ключами и при успешном создании сервисного аккаунта, бакета, и ключей в директории /backend/ создасться файл provider.tf для переноса стейта в s3 с секретными ключами.

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/Снимок%20экрана%20от%202025-12-14%2015-43-54.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/Снимок%20экрана%20от%202025-12-14%2015-45-59.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/Снимок%20экрана%20от%202025-12-14%2015-46-21.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/Снимок%20экрана%20от%202025-12-14%2015-46-38.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/Снимок%20экрана%20от%202025-12-14%2015-47-29.png)

---

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

* сделал 2й вариант развертывания K8s с помощью terraform resource для yandex-cloud, развернул,увидел цену такого варианта, удалил и сделал вариант 1.

#### шаги

* "cd /k8s-ansible"

* terraform init -upgrade
* git clone <git@github.com>:kubernetes-sigs/kubespray.git
* cd kubespray
* git checkout release-2.26
* pip install -r requirements.txt --break-system-packages
* pip install --ignore-installed ruamel.yaml --break-system-packages
* cp -rfp inventory/sample inventory/k8s
* declare -a IPS=("$(cat ../hosts.ini)")
* CONFIG_FILE=inventory/k8s/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
* nano inventory/k8s/hosts.yaml
* Настройки будущего кластера находятся в папке group_vars. Чтобы не устанавливать Helm вручную на каждом мастер-узле, установил в файле addons.yaml параметр helm_enable равным true: helm_enabled: true
* В том же файле addons.yaml раскомментировал и активировал nginx-ingress, а также параметр ingress_nginx_host_network, благодаря которому, к каждому узлу будет привязана пода nginx-ingress: ingress_nginx_enabled: true ingress_nginx_host_network: true, metrics_server_enabled: true
* Добавиk в конфигурацию Ansible пользователя, под которым логинимся по SSH: nano ansible.cfg
* В группе ssh_connection параметр remote_user, равный root: remote_user=ubuntu
* local_volume_provisioner_enabled: true # активируем local volume provisioner
* Выполнил её в корне директории kubespray: ansible-playbook -i inventory/k8s/hosts.yaml --become --become-user=root cluster.yml

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image2.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image3.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image4.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image5.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image6.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image7.png)

* исправил ошибку добавлением зеркала host: <https://mirror.gcr.io> в containerd.yml

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image8.png)

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image11.png)

* исправил ошибку:

* kubectl config get-contexts

* kubectl get nodes -v=10
* mkdir -p $HOME/.kube
* sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
* sudo chown $(id -u):$(id -g) $HOME/.kube/config

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image9.png)

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image10.png)

---

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.
   б. Подготовьте Dockerfile для создания образа приложения.
2. Альтернативный вариант:
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.

* [Github](https://github.com/DeluxWebSite/app-nginx-static)

1. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

* [DockerHub](https://hub.docker.com/r/sergeymeljnick78/myapp/tags)

---

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:

1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:

1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

---

* шаги 3го этапа:

* kubectl create namespace monitoring

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image13.png)

* helm repo add prometheus-community <https://prometheus-community.github.io/helm-charts>
* helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image14.png)

* kubectl get pods -n monitoring

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image13.png)

* kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo //пароль от графана
* доступ к Grafana по внешнему ip адресу, для чего создаем файл values.yml:
grafana:
  service:
    type: NodePort
    nodePort: 32000
* helm upgrade prometheus prometheus-community/kube-prometheus-stack -n monitoring -f values.yml

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image15.png)

* nginx-deployment.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-static
  labels:
    app: nginx-static
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-static
  template:
    metadata:
      labels:
        app: nginx-static
    spec:
      containers:
        - name: myapp
          image: sergeymeljnick78/myapp:1.0
          ports:
            - containerPort: 80

* nginx-service.yml

apiVersion: v1
kind: Service
metadata:
  name: nginx-static
  labels:
    app: nginx-static
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 32001
  selector:
    app: nginx-static

* kubectl apply -f nginx-deployment.yml
* kubectl apply -f nginx-service.yml
* kubectl get pods -l app=nginx-static

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image16.png)

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image17.png)

---

### Деплой инфраструктуры в terraform pipeline

1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform

---

* ci/cd-terraform сделал в GitHub Actions -- /github/workflows/cicd.yaml

---

### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---

* Для настройки CI/CD процессов выбран Jenkins как наиболее широко применяемое open-source решение.

* git clone <https://github.com/scriptcamp/kubernetes-jenkins>
* kubectl create namespace devops-tools
* kubectl apply -f serviceAccount.yaml

* в deployment.yaml тома постоянного хранения данных (настройки пользователя, пайплайны и т.д., так как наш кластер использует ради экономии прерываемые виртуальные машины).

volumeMounts:
            - name: jenkins-data
              mountPath: /var/jenkins_home
            - name: docker-socket
              mountPath: /var/run/docker.sock
            - name: docker-bin
              mountPath: /tmp/docker-bin

volumes:
        - name: jenkins-data
          persistentVolumeClaim:
            claimName: jenkins-pvc
        - name: docker-socket
          hostPath:
            path: /var/run/docker.sock
        - name: docker-bin
          emptyDir: {}

* И соответственно требуемый persistent volume

apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: "/var/jenkins_home"

* А также persistent volume claim

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: devops-tools
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

* Для корректной работы необходимо создать директорию /var/jenkins_home на всех нодах нашего кластера, для чего необходимо в deployment.yaml добавить инитконтейнер, устанавливающий docker и git

initContainers:
        - name: install-docker-git
          image: ubuntu:22.04
          command:
          - sh
          - -c
          - |
            apt-get update && \
            apt-get install -y curl gnupg && \
            curl -fsSL <https://download.docker.com/linux/debian/gpg> | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] <https://download.docker.com/linux/debian> bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
            apt-get update && \
            apt-get install -y docker-ce-cli && \
            mkdir -p /tmp/docker-bin && \
            cp /usr/bin/docker /tmp/docker-bin/docker
            apt-get install -y git
          volumeMounts:
          - name: docker-bin
            mountPath: /tmp/docker-bin
          - name: jenkins-data
            mountPath: /var/jenkins_home
          - name: docker-socket
            mountPath: /var/run/docker.sock

*Применяю изменения и проверяю успешный запуск Jenkins

* kubectl apply -f pv.yml
* kubectl apply -f pvc.yml
* kubectl apply -f deployment.yaml
* kubectl get deployments -n devops-tools
* kubectl get pods -n devops-tools

* Далее сервис- дефортный файл service.yaml из скачанного репозитория, указав nodePort: 32002, так как дефолтный порт 32000 уже занят мониторингом (Grafana), а на порту 32001 работает сервер nginx.

* kubectl apply -f service.yaml

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image18.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image20.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image23.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image21.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image22.png)

* перезапустил несколько раз этот шаг и все вольюмы заработали, но стал падать под(

![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image24.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image25.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image26.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image27.png)
![](https://github.com/DeluxWebSite/devops-diplom-yandexcloud/blob/master/screenshots/image28.png)

---

## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)
