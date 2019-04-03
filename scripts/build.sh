#!/bin/bash

BASE_DIR="/tmp/layer"

cd "/opt" || exit 1

cp "${BASE_DIR}/bootstrap" .
chmod 755 'bootstrap'

mkdir bundle
cp -r "${BASE_DIR}/lib" bundle/lib

zip -r "${BASE_DIR}/lambda-layer-perl-${TAG}.zip" . -x \*.pod -x man/\* -x html/\* -x lib/perl5/site_perl/5.28.1/Paws/\* -x lib/perl5/site_perl/5.28.1/Paws.pm

zip -r "${BASE_DIR}/lambda-layer-perl-${TAG}-paws.zip" lib/perl5/site_perl/5.28.1/Paws lib/perl5/site_perl/5.28.1/Paws.pm