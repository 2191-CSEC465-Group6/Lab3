#Author: Robert Ellegate
#Attributions: References code from Chris Warwick <https://github.com/ChrisWarwick/PowerShell-NTP-Time>
#Lab 3 Question

Function Get-NtpRoute {
    Param (
        [String]$Server = 'ntp.rit.edu',
        [Switch]$NoDns, # Do not attempt to lookup V3 secondary-server referenceIdentifier
        [Switch]$NoGetList # Do not attempt to send MON_GETLIST command to $Server
    )

    # Construct a 48-byte client NTP time packet to send to the specified server
    # (Request Header: [00=No Leap Warning; 011=Version 3; 011=Client Mode]; 00011011 = 0x1B)

    [Byte[]]$NtpData = , 0 * 48
    $NtpData[0] = 0x1B    # NTP Request header in first byte

    $Socket = New-Object Net.Sockets.Socket([Net.Sockets.AddressFamily]::InterNetwork, [Net.Sockets.SocketType]::Dgram, [Net.Sockets.ProtocolType]::Udp)
    $Socket.SendTimeOut = 2000  # ms
    $Socket.ReceiveTimeOut = 2000   # ms

    Try {
        $Socket.Connect($Server, 123)
    }
    Catch {
        Write-Error "Failed to connect to server $Server"
        Throw
    }

    # NTP Transaction -------------------------------------------------------

    Try {
        [Void]$Socket.Send($NtpData)
        [Void]$Socket.Receive($NtpData)
    }
    Catch {
        Write-Error "Failed to communicate with server $Server"
        Throw
    }

    # We now have an NTP response packet in $NtpData to decode.

    $VN = ($NtpData[0] -band 0x38) -shr 3

    If (-Not $NoGetList) {
        Switch ($VN) {
            2 {
                [Byte[]]$MruData = 0x17, 0x00, 0x03, 0x2a, 0x00, 0x00, 0x00, 0x00

                Try {
                    [Void]$Socket.Send($MruData)
                    [Void]$Socket.Receive($MruData)
                }
                Catch {
                    Write-Error "MON_GETLIST failed with server $Server"
                }
            }

            3 {
                [Byte[]]$MruData = 0x1b, 0x00, 0x03, 0x2a, 0x00, 0x00, 0x00, 0x00

                Try {
                    [Void]$Socket.Send($MruData)
                    [Void]$Socket.Receive($MruData)
                }
                Catch {
                    Write-Error "MON_GETLIST failed with server $Server"
                }
            }
        }
    }

    # End of NTP Transaction ------------------------------------------------

    $Socket.Shutdown("Both")
    $Socket.Close()

    $Stratum = [UInt16]$NtpData[1]   # Actually [UInt8] but we don't have one of those...
    $Stratum_text = Switch ($Stratum) {
        0 { 'unspecified or unavailable' }
        1 { 'primary reference (e.g., radio clock)' }
        { $_ -ge 2 -and $_ -le 15 } { 'secondary reference (via NTP or SNTP)' }
        { $_ -ge 16 } { 'reserved' }
    }

    # Determine the format of the ReferenceIdentifier field and decode

    If ($Stratum -le 1) {
        # Response from Primary Server.  RefId is ASCII string describing source
        $ReferenceIdentifier = [String]([Char[]]$NtpData[12..15] -join '')
    }
    Else {

        # Response from Secondary Server; determine server version and decode

        Switch ($VN) {
            3 {
                # Version 3 Secondary Server, RefId = IPv4 address of reference source
                $ReferenceIdentifier = $NtpData[12..15] -join '.'

                If (-Not $NoDns) {
                    If ($DnsLookup = Resolve-DnsName $ReferenceIdentifier -QuickTimeout -ErrorAction SilentlyContinue) {
                        $ReferenceIdentifier = "$ReferenceIdentifier <$($DnsLookup.NameHost)>"
                    }
                }
                Break
            }

            4 {
                # Version 4 Secondary Server, RefId = low-order 32-bits of
                # latest transmit time of reference source
                $ReferenceIdentifier = [BitConverter]::ToUInt32($NtpData[15..12], 0) * 1000 / 0x100000000
                Break
            }

            Default {
                # Unhandled NTP version...
                $ReferenceIdentifier = $Null
            }
        }
    }
    # Create output object and return

    $NtpTimeObj = [PSCustomObject]@{
        NtpServer           = $Server
        NtpVersionNumber    = $VN
        Stratum             = $Stratum
        Stratum_text        = $Stratum_text
        ReferenceIdentifier = $ReferenceIdentifier
    }

    $NtpTimeObj

    # Recursively call when Stratum is not primary

    If ($Stratum -gt 1) {
        Switch ($VN) {
            3 {
                # Version 3 Secondary Server, RefId = IPv4 address of reference source
                $ReferenceIdentifier = $NtpData[12..15] -join '.'

                Get-NtpRoute -Server $ReferenceIdentifier -NoGetList
            }

            4 {
                # Version 4 Secondary Server, RefId = low-order 32-bits of
                # latest transmit time of reference source
                $ReferenceIdentifier = [BitConverter]::ToUInt32($NtpData[15..12], 0) * 1000 / 0x100000000
                Get-NtpRoute -Server $ReferenceIdentifier -NoGetList
            }
        }
    }
}

Get-NtpRoute -Server 'ntp.rit.edu' -NoGetList