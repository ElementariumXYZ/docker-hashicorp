FROM registry.fedoraproject.org/fedora-minimal:38

ENV NOMAD_VERSION=1.4.3 \
  LEVANT_VERSION=0.3.2 \
  HASHICORP_RELEASES=https://releases.hashicorp.com

LABEL maintainer "Elementarium"
LABEL version "1.0.0"
LABEL description "Hashicorp agents as DOcker Image"

RUN microdnf -y --nodocs install iproute systemd-libs unzip shadow-utils && \
  case "$(arch)" in \
    aarch64|arm64|arm64e) \
      ARCHITECTURE='arm64'; \
      ;; \
    x86_64|amd64|i386) \
      ARCHITECTURE='amd64'; \
      ;; \
    *) \
      echo "Unsupported architecture"; \
      exit 1; \
      ;; \
  esac; \
  # Install Nomad
  useradd -u 100 -r -d /nomad nomad && \
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 51852D87348FFC4C 34365D9472D7468F && \
  mkdir -p /tmp/build /nomad/data/plugins /nomad/config && \
  cd /tmp/build && \
  curl -s -O ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip && \
  curl -s -O ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS && \
  curl -s -O ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig && \
  gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS && \
  grep nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c && \
  unzip -d /bin nomad_${NOMAD_VERSION}_linux_${ARCHITECTURE}.zip && \
  # Install Levant
  curl -s -O ${HASHICORP_RELEASES}/levant/${LEVANT_VERSION}/levant_${LEVANT_VERSION}_linux_${ARCHITECTURE}.zip && \
  curl -s -O ${HASHICORP_RELEASES}/levant/${LEVANT_VERSION}/levant_${LEVANT_VERSION}_SHA256SUMS && \
  curl -s -O ${HASHICORP_RELEASES}/levant/${LEVANT_VERSION}/levant_${LEVANT_VERSION}_SHA256SUMS.sig && \
  gpg --batch --verify levant_${LEVANT_VERSION}_SHA256SUMS.sig levant_${LEVANT_VERSION}_SHA256SUMS && \
  grep levant_${LEVANT_VERSION}_linux_${ARCHITECTURE}.zip levant_${LEVANT_VERSION}_SHA256SUMS | sha256sum -c && \
  unzip -d /bin levant_${LEVANT_VERSION}_linux_${ARCHITECTURE}.zip && \
  # Cleanup
  microdnf -y remove unzip shadow-utils libsemanage && microdnf clean all && \
  rm -f /etc/fedora-release /etc/redhat-release /etc/system-release /etc/system-release-cpe && \
  rm -rf /tmp/* /var/tmp/* /var/log/*.log /var/cache/yum/* /var/lib/dnf/* /var/lib/rpm/* /root/.gnupg && \
  chown -R nomad:nomad /nomad

EXPOSE 4646 4647 4648 4648/udp

CMD tail -f /dev/null
