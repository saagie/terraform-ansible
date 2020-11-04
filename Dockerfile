FROM centos:centos7

ADD files/init.sh .
ADD files/vimrc /root/.vimrc
ADD files/kubernetes.repo /etc/yum.repos.d/kubernetes.repo
ADD files/mongorepo.repo /etc/yum.repos.d/mongorepo.repo
ADD files/google-cloud-sdk.repo /etc/yum.repos.d/google-cloud-sdk.repo

ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8

ARG KUBE_VERSION="1.19.3"

RUN yum install epel-release -y \
    && yum install -y https://repo.ius.io/ius-release-el7.rpm \
    && yum install -y bc \
                    jq \
                    pwgen \
                    python-pip \
                    python-devel \
                    gcc \
                    git \
                    libselinux-python \
                    wget \
                    vim \
                    bash-completion \
                    python36u \
                    openssl \
                    sshpass \
                    autoconf \
                    automake \
                    libtool \
                    python-devel \
                    telnet \
                    nc \
                    mongodb-org-tools-3.6.14 \
                    mongodb-org-shell-3.6.14 \
                    google-cloud-sdk \
                    curl \
                    unzip \
                    which \
                    python3-pip \
                    groff \
                    kubectl-${KUBE_VERSION} \
    && yum clean all

RUN pip install --upgrade --no-cache-dir --upgrade pip setuptools==44.1.0 \
    && pip install --no-cache-dir \
        ansible==2.7.12 \
        netaddr==0.7.19 \
        pycrypto==2.6.1 \
        httpie==0.9.9 \
        google-auth-httplib2==0.0.3 \
        ipaddress \
        httplib2==0.10.3 \
        ansible-modules-hashivault==3.9.4 \
        ansible-vault==1.1.1 \
        apache-libcloud==2.6.0 \
        asn1crypto==0.24.0 \
        backports.ssl-match-hostname==3.5.0.1 \
        bcrypt==3.1.4 \
        cachetools==2.1.0 \
        certifi==2018.8.13 \
        cffi==1.11.5 \
        chardet==3.0.4 \
        cryptography==2.3 \
        docker \
        enum34==1.1.6 \
        google-api-python-client==1.7.11 \
        google-auth==1.6.3 \
        hvac==0.8.2 \
        idna==2.7 \
        jinja2==2.10.1 \
        jmespath==0.9.4 \
        MarkupSafe==1.0 \
        netaddr==0.7.19 \
        oauth2client==4.1.2 \
        openshift==0.9.2 \
        paramiko==2.4.1 \
        pbr==5.2.0 \
        pyasn1==0.4.4 \
        pyasn1-modules==0.2.2 \
        pycparser==2.18 \
        Pygments==2.2.0 \
        pyjq==2.3.1 \
        PyNaCl==1.2.1 \
        PyYAML==3.13 \
        requests==2.19.1 \
        rsa==3.4.2 \
        ruamel.yaml==0.15.96 \
        selinux==0.1.6 \
        six==1.11.0 \
        uritemplate==3.0.0 \
        urllib3==1.23 \
        ovh==0.5.0 \
        proxmoxer==1.0.3 \
        websocket-client==0.54.0 \
        passlib==1.7.2 \
        mitogen==0.2.9

# google-api required for gce_delete.py to work
RUN pip3 install --no-cache-dir \
        awscli \
        google-api-python-client==1.7.11

RUN  yum remove -y autoconf automake libtool python-devel \
    && rm -rf /var/lib/rpm/*

RUN  kubectl completion bash > /etc/bash_completion.d/kubectl

ARG TERRAFORM_VERSION="0.13.5"
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
 && unzip terraform.zip -d /usr/local/bin \
 && rm terraform.zip

RUN curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/1.17.9/2019-08-14/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
 && chmod +x /usr/local/bin/aws-iam-authenticator

ARG VERSION=v3.3.4
ARG FILENAME=helm-${VERSION}-linux-amd64.tar.gz
ARG HELM_URL=https://get.helm.sh/${FILENAME}
RUN echo $HELM_URL\
   && curl -o /tmp/${FILENAME} ${HELM_URL} \
   && tar -zxvf /tmp/${FILENAME} -C /tmp \
   && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
   && rm /tmp/${FILENAME}

WORKDIR /
ENTRYPOINT ["/init.sh"]