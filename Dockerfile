FROM lambci/lambda:build

ARG PERL_VERSION
RUN yum install -y zip curl \
  && curl -L https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build > /tmp/perl-build \
  && perl /tmp/perl-build ${PERL_VERSION} /opt/ \
  && curl -L https://cpanmin.us | /opt/bin/perl - App::cpanminus
COPY cpanfile /tmp/cpanfile
RUN /opt/bin/cpanm -n --installdeps /tmp/

