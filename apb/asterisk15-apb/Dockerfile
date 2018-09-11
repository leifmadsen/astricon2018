FROM ansibleplaybookbundle/apb-base

LABEL "com.redhat.apb.spec"=\
"dmVyc2lvbjogMS4xNQpuYW1lOiBhc3RlcmlzazE1LWFwYgpkZXNjcmlwdGlvbjogQXN0ZXJpc2sg\
MTUgRGVwbG95bWVudApiaW5kYWJsZTogRmFsc2UKYXN5bmM6IG9wdGlvbmFsCm1ldGFkYXRhOgog\
IGRpc3BsYXlOYW1lOiBhc3RlcmlzazE1LWFwYgpwbGFuczoKICAtIG5hbWU6IGRlZmF1bHQKICAg\
IGRlc2NyaXB0aW9uOiBUaGlzIGRlZmF1bHQgcGxhbiBkZXBsb3lzIEFzdGVyaXNrIDE1CiAgICBm\
cmVlOiBUcnVlCiAgICBtZXRhZGF0YToge30KICAgIHBhcmFtZXRlcnM6IFtdCg=="

COPY playbooks /opt/apb/project
COPY . /opt/ansible/roles/asterisk15-apb
RUN chmod -R g=u /opt/{ansible,apb}
USER apb
