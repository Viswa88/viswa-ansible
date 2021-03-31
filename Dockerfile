FROM python:3.9.1-alpine3.12

ENV ANSIBLE_VERSION=2.9.2

ENV KUBE_LATEST_VERSION="v1.15.3"
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
RUN apk --update --no-cache add \
        ca-certificates \
        git \
        aws-cli \
        bash \
        curl \
        openssh-client \
        openssl \
        python3\
        py3-pip \
        py3-cryptography \
        rsync \
        sshpass

RUN apk --update add --virtual \
        .build-deps \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
        curl \
 && pip3 install --upgrade \
        pip \
        cffi \
 && pip3 install \
        ansible==${ANSIBLE_VERSION} \
 && apk del \
        .build-deps \
 && rm -rf /var/cache/apk/*

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN mkdir -p /etc/ansible \
 && echo 'localhost' > /etc/ansible/hosts \
 && echo -e """\
\n\
Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config

COPY src /ansible
WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
