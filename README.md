Included DSC Resources
======================
* cPfxCertificate

These custom Desired State Configuration (DSC) resources utilise .NET x509 certificate objects to
install Personal Information Exchange (PFX) certificate bundles.

cPfxCertificate
===========
###Syntax
```
cPfxCertificate [string]
{
    Thumbprint = [string]
    Location = [string] { LocalMachine | CurrentUser }
    Store = [string] { AddressBook | AuthRoot | CertificateAuthority | Disallowed | My | Root | TrustedPeople | TrustedPublisher }
    Path = [string]
    Credential = [PSCredential] { Password }
    Ensure = [string] { Present | Absent }
}
```
###Properties
* Thumbprint: Certificate thumbprint.
* Location: Destination physical certificate store location.
* Store: Destination certificate store name. Use 'My' for the 'Personal' store.
* Path: Source file system path to the .pfx certificate bundle.
* Credential: PSCredential object containing the certificate password.

###Configuration
```
Configuration cPfxCertificate {
    Import-DscResource -ModuleName cPfxCertificate
    cPfxCertificate MyCertificate {
        Thumbprint = 'A4D8B8E3B1B6910CB54C3B6CDFD6478914327850'
        Location = 'LocalMachine'
        Store = 'My'
        Path = 'C:\Resources\MyCertificate.pfx'
        Credential = (Get-Credential MyCertificateCredentials)
    }
}
```
