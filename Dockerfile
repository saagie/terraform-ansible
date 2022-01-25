FROM quay.io/centos/centos:stream8

ADD files/init.sh .
ADD files/vimrc /root/.vimrc
ADD files/mongorepo.repo /etc/yum.repos.d/mongorepo.repo
ADD files/google-cloud-sdk.repo /etc/yum.repos.d/google-cloud-sdk.repo

ARG KUBE_VERSION="1.21.8"

RUN dnf install epel-release -y \
    && dnf install -y ansible \
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

ARG TERRAFORM_VERSION="1.0.5"
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
 && unzip terraform.zip -d /usr/local/bin \
 && rm terraform.zip

RUN curl -L https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
 && chmod +x /usr/local/bin/aws-iam-authenticator

ARG VERSION=v3.7.0
ARG FILENAME=helm-${VERSION}-linux-amd64.tar.gz
ARG HELM_URL=https://get.helm.sh/${FILENAME}
RUN echo $HELM_URL\
   && curl -o /tmp/${FILENAME} ${HELM_URL} \
   && tar -zxvf /tmp/${FILENAME} -C /tmp \
   && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
   && rm /tmp/${FILENAME}

WORKDIR /
ENTRYPOINT ["/init.sh"]