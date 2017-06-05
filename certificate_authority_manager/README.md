Role Name
=========

The purpose of this Ansible role is to allow you to manage a
private Certification Authority inside your private network

With this role you will be able to generate your Root CA.
Share it and let people generate intermediate CA and certificates depending on their credentials

This role is freely inspired by the configuration described by Jamie Nguyen on [jamielinux.com](https://jamielinux.com/docs/openssl-certificate-authority/introduction.html)


Requirements
------------

The following packages have to be installed and well configured on the host :
- [Docker-ce](https://docs.docker.com/engine/installation/)
- Python-pip

Role Variables
--------------

###User defined variables
The following vars have to be defined on each execution by the user to configure the issued certificate

####Mandatory - Certificat fields values
- ca_manager_cn_name: "MyCA"
  - The value of certificat CN field (by default used to name the certificat itself)
- ca_manager_subject_without_cn: "/C=FR/ST=IdF/L=Paris/O=CloudCustom"
  - The values of certificate fields except the CN field specifically setted in ca_manager_cn_name)

####Mandatory and mutually exclusives - Type of issued certificate
- ca_manager_issue_root_ca: true
  - Issue Root CA signed by itself
- ca_manager_issue_intermediate_ca: false
  - Issue Intermediate CA signed by an other CA (Root or Intermediate)
- ca_manager_issue_certificate: false
  - Issue basic server certificat

####Mandatory if ca_manager_issue_intermediate_ca or ca_manager_issue_certificate
- ca_manager_signin_ca_cn_name: "RootCA"
  - CN of previously generated CA that will be used to sign the issued certificate

#### Optional parameters: Certificate key protection
##### Either protection by passphrase
- ca_manager_key_pass: "s3cret p@ss phrase"
  - The passphrase of the certificate key. If not defined (nor ca_manager_encrypt_by_ssh_pub) the key is not encrypted (Not recomanded for CA certificates)
- ca_manager_signin_ca_key_pass: "s3cret p@ss phrase"
  - The passphrase of the CA used to sign the issued certificate (if required).
##### Either protection by ssh key ciphering
- ca_manager_encrypt_by_ssh_pub: "/home/user/.ssh/id_rsa.pub"
  - The public ssh key to use to cipher the certificate. If not defined (nor ca_manager_key_pass) the key is not encrypted (Not recomanded for CA certificates)
- ca_manager_signin_ca_decrypt_by_ssh_priv: "/home/user/.ssh/id_rsa"
  - The private ssh key to use to decipher the CA used to sign the issued certificate (if required).
- ca_manager_signin_ca_decrypt_by_ssh_priv_passphrase: "id_rsa s3cret p@ssphrase"
  - The passphrase of the private ssh key to use to decipher the CA used to sign the issued certificate (if required).

###Overridable default variables

- ca_manager_output_location: "{{ role_path }}/../certificates"
  - Location of all issued certificates
- ca_manager_certificate_location: "{{ ca_manager_output_location }}/{{ ca_manager_cn_name }}"
  - Location of issued certificate files

- ca_manager_signin_ca_cert_location: "{{ ca_manager_output_location }}/{{ ca_manager_signin_ca_cn_name|default('default') }}"
  - Root location of CA files used to sign issued certificate

- ca_manager_validation_policy: "{{ (ca_manager_issue_root_ca|default(false)|bool) | ternary('policy_strict', 'policy_loose') }}"
  - CA Policy of validation of issued certificate subject fields.
  - If policy_strict then the certificate has to have the same countryName, stateOrProvinceName and organizationName
  - Default to policy_strict for certificates issued by root CA and policy_loose for thoses issued by intermediate CA
- ca_manager_key_length: "{{ (ca_manager_issue_ca) | ternary('4096', '2048') }}"
  - The lenght in bits of the issued certificate key
  - default to 4096 for issued CA and 2048 for server certificates

Dependencies
------------

--

Example Playbook
----------------

See tests/test.yml (ansible-playbook -i certificate_authority_manager/tests/inventory certificate_authority_manager/tests/test.yml --connection=local)

    ---
    - hosts: localhost
      serial: 1
      roles:
        - {
            role: certificate_authority_manager,
            ca_manager_issue_root_ca: true,
            ca_manager_cn_name: "MyCompany_RootCA",
            ca_manager_subject_without_cn: "/C=FR/ST=IdF/L=Paris/O=MyCompany",
            ca_manager_key_pass: "s3cret p@ss phrase"
          }
        - {
            role: certificate_authority_manager,
            ca_manager_issue_intermediate_ca: true,
            ca_manager_cn_name: "MarketingDpt_CA",
            ca_manager_subject_without_cn: "/C=FR/ST=IdF/L=Paris/O=MyCompany",
            ca_manager_key_pass: "s3cret p@ss phrase",
            ca_manager_signin_ca_cn_name: "MyCompany_RootCA",
            ca_manager_signin_ca_key_pass: "s3cret p@ss phrase"
          }
        - {
            role: certificate_authority_manager,
            ca_manager_issue_certificate: true,
            ca_manager_cn_name: "www.good-deal.com",
            ca_manager_subject_without_cn: "/C=FR/ST=IdF/L=Paris/O=MyCompany",
            ca_manager_signin_ca_cn_name: "MarketingDpt_CA",
            ca_manager_signin_ca_key_pass: "s3cret p@ss phrase"
          }
        - {
            role: certificate_authority_manager,
            ca_manager_issue_certificate: true,
            ca_manager_cn_name: "www.black-friday-special.com",
            ca_manager_subject_without_cn: "/C=US/ST=CA/L=Los Angeles/O=MyCompany",
            ca_manager_signin_ca_cn_name: "MarketingDpt_CA",
            ca_manager_signin_ca_key_pass: "s3cret p@ss phrase"
          }

License
-------

MIT

Author Information
------------------

https://github.com/BastienF/MyPrivateCAManager
