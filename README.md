# gitian-terraform-aws

This module will deploy an ec2 instance with a mounted EBS. There are many variable options if more is needed PR's are welcome.
The method used for this gitian build process is docker. Bitcoin binaries are tar.gz/zipped up for linux and windows. These will be dropped into `/gitian/bitcoin/bitcoin-binaries/${VERSION}/`
You can then check the hash of these files to the ones you would download off of https://bitcoin.org/en/download or https://bitcoincore.org/en/download/.

Example usage:
```
module "gitian" {
  source = "git@github.com:miketwenty1/gitian-terraform-aws.git"

  env               = var.env  # arbitary environment name
  region            = var.region # AWS region
  vpc_id            = data.aws_vpc.env.id 
  subnet_id         = data.aws_subnet.priv_a.id # choose a private subnet
  ssh_key_name      = var.ssh_key_name
  sg_for_access_id  = data.aws_security_group.vpn.id # optional sg for usage with other sg's
  gpg_signer        = var.gpg_signer # name for your gpg signing name
  bitcoin_version   = var.bitcoin_version # ex: 0.21.0rc1
  instance_size     = var.instance_size # (supported sizes c4.4xlarge, c4.2xlarge, c4.xlarge, t3.medium)

  providers = {
    aws.env = aws.env
  }
}
```

### NOTES:
- The purpose of this module is to easily check the gitian build checksums for yourself extra manual steps are required if you want to be a gitian signer:
  - https://github.com/bitcoin-core/docs/blob/master/gitian-building.md
- If you want to run subsequent builds from the same server `ssh/cd` into `/gitian/bitcoin` and run:
```
# your name
export SIGNER=satoshi 
# tag on github.com/bitcoin/bitcoin repo
export VERSION=0.21.0rc3 
# memory in MB
export MEMORY_MB=25000 
# number of cpu cores for faster builds
export THREADS=15 
# method
export USE_DOCKER=1

cd /gitian/
bitcoin/contrib/gitian-build.py -j ${THREADS} -m ${MEMORY_MB} -Ddnb ${SIGNER} ${VERSION}
```
Ex: `bitcoin/contrib/gitian-build.py -j 4 -m 3000 -Ddnb Satoshi 0.21.0rc1`

### GPG/PGP Signing:
```
pushd ./gitian.sigs
gpg --output ${VERSION}-win-unsigned/${SIGNER}/bitcoin-core-win-${VERSION%\.*}-build.assert.sig --detach-sign ${VERSION}-win-unsigned/$SIGNER/bitcoin-core-win-${VERSION%\.*}-build.assert
gpg --output ${VERSION}-linux/${SIGNER}/bitcoin-core-linux-${VERSION%\.*}-build.assert.sig --detach-sign ${VERSION}-linux/$SIGNER/bitcoin-core-linux-${VERSION%\.*}-build.assert
popd
```

### Verify:
```
pushd ./gitian-builder
./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-linux ../bitcoin/contrib/gitian-descriptors/gitian-linux.yml
./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-win-unsigned ../bitcoin/contrib/gitian-descriptors/gitian-win.yml
./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-osx-unsigned ../bitcoin/contrib/gitian-descriptors/gitian-osx.yml
popd
```
### Push unsigned binary sigs
```
pushd gitian.sigs
git add ${VERSION}-linux/"${SIGNER}"
git add ${VERSION}-win-unsigned/"${SIGNER}"
git add ${VERSION}-osx-unsigned/"${SIGNER}"
git commit -m "Add ${VERSION} unsigned sigs for ${SIGNER}"
git push  # Assuming you can push to the gitian.sigs tree
popd
```
# signed builds for OSX and Windows (When they are ready)
Once signed builds are available you may want to go back and sign those as well
### OSX
notice that these commands use "signature" flag instead of "bitcoin"
```
pushd ./gitian-builder
./bin/gbuild -i --commit signature=v${VERSION} ../bitcoin/contrib/gitian-descriptors/gitian-osx-signer.yml
./bin/gsign --signer "$SIGNER" --release ${VERSION}-osx-signed --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-osx-signer.yml
./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-osx-signed ../bitcoin/contrib/gitian-descriptors/gitian-osx-signer.yml
mv build/out/bitcoin-osx-signed.dmg ../bitcoin-${VERSION}-osx.dmg
popd
```
### Windows
notice that these commands use "signature" flag instead of "bitcoin"
```
pushd ./gitian-builder
bin/gbuild --num-make ${THREADS} --memory ${MEMORY_MB} --commit signature=v${VERSION} ../bitcoin/contrib/gitian-descriptors/gitian-win-signer.yml
./bin/gsign --signer "$SIGNER" --release ${VERSION}-win-signed --destination ../gitian.sigs/ ../bitcoin/contrib/gitian-descriptors/gitian-win-signer.yml
./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-win-signed ../bitcoin/contrib/gitian-descriptors/gitian-win-signer.yml
mv build/out/bitcoin-*win64-setup.exe ../bitcoin-${VERSION}-win64-setup.exe
popd
```
### Push signed binary sigs
```
pushd gitian.sigs
git add ${VERSION}-win-signed/"${SIGNER}"
git add ${VERSION}-osx-signed/"${SIGNER}"
git commit -m "Add ${VERSION} unsigned sigs for ${SIGNER}"
git push  # Assuming you can push to the gitian.sigs tree
popd
```


Docs/resources:
- https://github.com/devrandom/gitian-builder
- https://github.com/bitcoin/bitcoin/blob/master/doc/release-process.md
- https://github.com/bitcoin-core/docs/blob/master/gitian-building.md
