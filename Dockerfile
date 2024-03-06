FROM quay.io/centos/centos:stream8

RUN groupadd \
        --gid 1000 \
        user \
    && \
    useradd \
        --uid 1000 \
        --gid 1000 \
        --no-create-home \
        --shell /bin/bash \
        user

ADD files/init.sh .
ADD files/vimrc /root/.vimrc
ADD files/mongorepo.repo /etc/yum.repos.d/mongorepo.repo
ADD files/google-cloud-sdk.repo /etc/yum.repos.d/google-cloud-sdk.repo

ARG KUBE_VERSION="1.27.3"

RUN dnf install epel-release -y \
    && dnf install -y https://cbs.centos.org/kojifiles/packages/ansible/2.9.27/5.el8/noarch/ansible-2.9.27-5.el8.noarch.rpm \
                    python3-pip \
                    python3-netaddr \
                    git \
                    wget \
                    vim \
                    bash-completion \
                    libtool \
                    telnet \
                    nc \
                    mongodb-org-tools-4.2.12 \
                    mongodb-org-shell-4.2.12 \
                    google-cloud-sdk \
                    curl \
                    unzip \
                    which \
                    groff-base \
    && yum clean all


# google-api required for gce_delete.py to work
RUN pip3 install --no-cache-dir \
        awscli \
        google-api-python-client==1.7.11

RUN  yum remove -y autoconf automake libtool python-devel \
    && rm -rf /var/lib/rpm/*


RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN kubectl completion bash > /etc/bash_completion.d/kubectl

ARG TERRAFORM_VERSION="1.7.2"
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
 && unzip terraform.zip -d /usr/local/bin \
 && rm terraform.zip

RUN curl -Lo /usr/local/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64 \
 && chmod +x /usr/local/bin/aws-iam-authenticator

ARG VERSION=v3.12.2
ARG FILENAME=helm-${VERSION}-linux-amd64.tar.gz
ARG HELM_URL=https://get.helm.sh/${FILENAME}
RUN echo $HELM_URL\
   && curl -o /tmp/${FILENAME} ${HELM_URL} \
   && tar -zxvf /tmp/${FILENAME} -C /tmp \
   && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
   && rm /tmp/${FILENAME}

WORKDIR /
ENTRYPOINT ["/init.sh"]