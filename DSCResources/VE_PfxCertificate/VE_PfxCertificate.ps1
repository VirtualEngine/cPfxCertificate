function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Path,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Thumbprint,
        [Parameter(Mandatory)] [ValidateSet('LocalMachine','CurrentUser')] [System.String] $Location,
        [Parameter(Mandatory)] [ValidateSet('AddressBook','AuthRoot','CertificateAuthority','Disallowed','My','Root','TrustedPeople','TrustedPublisher')] [System.String] $Store,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter()] [ValidateSet('Present','Absent')] [System.String] $Ensure = 'Present',
        [Parameter()] [System.Boolean] $Exportable
    )
    process {
        $certificatePath = 'Cert:\{0}\{1}' -f $Location, $Store;
        $isCertificatePresent = (Get-ChildItem -Path $certificatePath | Where Thumbprint -eq $Thumbprint) -ne $null;
        $targetResource = @{
            Path = $Path;
            Thumbprint = $Thumbprint;
            Location = $Location;
            Store = $Store;
            Credential = $Credential;
            Ensure = 'Absent';
            Exportable = $Exportable;
        }
        if ($isCertificatePresent) {
            $targetResource['Ensure'] = 'Present';
        }
        return $targetResource;
    } #end process
} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Path,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Thumbprint,
        [Parameter(Mandatory)] [ValidateSet('LocalMachine','CurrentUser')] [System.String] $Location,
        [Parameter(Mandatory)] [ValidateSet('AddressBook','AuthRoot','CertificateAuthority','Disallowed','My','Root','TrustedPeople','TrustedPublisher')] [System.String] $Store,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter()] [ValidateSet('Present','Absent')] [System.String] $Ensure = 'Present',
        [Parameter()] [System.Boolean] $Exportable
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        return $targetResource['Ensure'] -eq $Ensure;
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Path,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Thumbprint,
        [Parameter(Mandatory)] [ValidateSet('LocalMachine','CurrentUser')] [System.String] $Location,
        [Parameter(Mandatory)] [ValidateSet('AddressBook','AuthRoot','CertificateAuthority','Disallowed','My','Root','TrustedPeople','TrustedPublisher')] [System.String] $Store,
        [Parameter(Mandatory)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter()] [ValidateSet('Present','Absent')] [System.String] $Ensure = 'Present',
        [Parameter()] [System.Boolean] $Exportable
    )
    process {
        $certificatePath = 'Cert:\{0}\{1}' -f $Location, $Store;
        $isCertificatePresent = (Get-ChildItem -Path $certificatePath | Where Thumbprint -eq $Thumbprint) -ne $null;
        Write-Verbose $isCertificatePresent;
        if ($Ensure -eq 'Present') {
            $certificatePath = Resolve-Path -Path $Path;
            $certificate = New-Object -TypeName 'Security.Cryptography.X509Certificates.X509Certificate2' -ArgumentList $certificatePath, $Credential.GetNetworkCredential().Password;
            if ($Location -eq 'LocalMachine') {
                $flags = [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet;
            }
            elseif ($Location -eq 'CurrentUser') {
                $flags = [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::UserKeySet;
            }
            if ($Exportable) {
                $flags = $flags -bor [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable;
            }
            $certificateStore = New-Object -TypeName 'Security.Cryptography.X509Certificates.X509Store' -ArgumentList $Store, $Location;
            $certificateStore.Open(([Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite));
            [ref] $null = $certificateStore.Add($certificate);
            [ref] $null = $certificateStore.Close();
        }
        elseif ($Ensure -eq 'Absent') {
            if ($isCertificatePresent) {
                Get-ChildItem -Path $certificatePath | Where Thumbprint -eq $Thumbprint | Remove-Item -Force;
            }
        }
    } #end process
} #end function Set-TargetResource
